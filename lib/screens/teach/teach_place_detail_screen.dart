// lib/screens/teach/teach_place_detail_screen.dart
import 'dart:ui'; // ★ ぼかし（BackdropFilter / ImageFilter）用
import 'package:google_fonts/google_fonts.dart'; // ← League Spartan用

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:googlemap_api/models/teach_place.dart';
import 'package:googlemap_api/models/app_user.dart';
// ★ 追加：他人プロフィール表示用の画面
import 'package:googlemap_api/screens/map_screen/profile_screen/public_profile_screen.dart';

class TeachPlaceDetailScreen extends StatelessWidget {
  const TeachPlaceDetailScreen({
    super.key,
    required this.placeId,
  });

  final String placeId;

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _themeGreen,
        elevation: 4,
        surfaceTintColor: Colors.transparent, // ★ M3のティントを無効化
        // ★ AppBarと白背景の境界をふわっとぼかす
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 12,
              sigmaY: 12,
            ),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          'WATCH',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 3,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('teach_places')
            .doc(placeId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('この場所の情報は見つかりませんでした'));
          }

          final place = TeachPlace.fromDoc(snapshot.data!);

          return _TeachPlaceDetailBody(place: place);
        },
      ),
    );
  }
}

class _TeachPlaceDetailBody extends StatelessWidget {
  const _TeachPlaceDetailBody({
    required this.place,
  });

  final TeachPlace place;

  static const _iconColor = Color(0xFF2F4F4F);
  static const double _ratingLabelWidth = 110;

  IconData _transportationIcon(String transportation) {
    switch (transportation) {
      case '徒歩':
        return Icons.directions_walk;
      case '自転車':
        return Icons.directions_bike;
      case '車':
        return Icons.directions_car;
      case '電車':
        return Icons.train;
      default:
        return Icons.directions_walk;
    }
  }

  IconData _distanceRatingIcon() {
    if (place.transportation.isNotEmpty) {
      return _transportationIcon(place.transportation);
    }
    return Icons.location_city;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('app_users')
          .doc(place.ownerUserId)
          .get(),
      builder: (context, snapshot) {
        AppUser? owner;
        if (snapshot.hasData && snapshot.data!.exists) {
          owner = AppUser.fromDoc(
            snapshot.data!.id,
            snapshot.data!.data()! as Map<String, dynamic>,
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================
              // 画像 + 投稿者アイコン
              //   - 画像の下に 24px の余白を作って、
              //     その中にアイコンを収める → 全面タップ可能になる
              // ==========================
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // 画像の下に 24px のパディングを入れて高さを確保
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: place.imageUrl.isNotEmpty
                          ? GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => FullScreenImageScreen(
                                imageUrl: place.imageUrl,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: place.imageUrl,
                          child: Image.network(
                            place.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('画像なし'),
                        ),
                      ),
                    ),
                  ),

                  // 投稿者アイコン（境界に乗せる ＋ 全体にタップ判定）
                  if (owner != null)
                    Positioned(
                      left: 16,
                      bottom: 0, // もう負の値にしない → Stack 内に収まる
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PublicProfileScreen(user: owner!),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: owner.imageUrl != null &&
                                  owner.imageUrl!.isNotEmpty
                                  ? NetworkImage(owner.imageUrl!)
                                  : null,
                              child: (owner.imageUrl == null ||
                                  owner.imageUrl!.isEmpty)
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 場所名
                    Text(
                      place.placeName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // EXPLAIN
                    const Text(
                      'EXPLAIN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),

                    // TRANSPORTATION
                    if (place.transportation.isNotEmpty) ...[
                      const Text(
                        'TRANSPORTATION (交通手段)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _transportationIcon(place.transportation),
                            size: 20,
                            color: _iconColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            place.transportation,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // PEOPLE（混雑度）
                    _buildStaticRatingRow(
                      label: 'PEOPLE\n(混雑度)',
                      value: place.densityScore,
                      filledIcon: Icons.person,
                      leftCaption: '←奥多摩並み(Good)',
                      rightCaption: '新宿並み(Bad)→',
                    ),
                    const SizedBox(height: 12),

                    // DISTANCE（行きやすさ）
                    _buildStaticRatingRow(
                      label: 'DISTANCE\n(行きやすさ)',
                      value: place.distanceScore,
                      filledIcon: _distanceRatingIcon(),
                      leftCaption: '←ex. 新宿へ(Good)',
                      rightCaption: 'ex. 奥多摩へ(Bad)→',
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      '※新宿駅をスタート地点とした\n'
                          ' 交通手段＆DISTANCE(行きやすさ)が設定されています',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaticRatingRow({
    required String label,
    required int value,
    required IconData filledIcon,
    String? leftCaption,
    String? rightCaption,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _ratingLabelWidth,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final score = index + 1;
                  final isActive = score <= value;
                  return Icon(
                    filledIcon,
                    size: 22,
                    color: isActive ? _iconColor : Colors.grey,
                  );
                }),
              ),
              if (leftCaption != null || rightCaption != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (leftCaption != null)
                      Text(
                        leftCaption,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    if (rightCaption != null)
                      Text(
                        rightCaption,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 📸 画像フルスクリーン表示用画面
class FullScreenImageScreen extends StatelessWidget {
  const FullScreenImageScreen({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
