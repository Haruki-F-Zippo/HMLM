// lib/screens/teach/teach_place_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:googlemap_api/models/teach_place.dart'; // TeachPlaceモデル
import 'package:googlemap_api/models/app_user.dart';     // AppUserモデル（あれば）

class TeachPlaceDetailScreen extends StatelessWidget {
  const TeachPlaceDetailScreen({
    super.key,
    required this.placeId,
  });

  // teach_places の docId（= ownerUserId にしている想定）
  final String placeId;

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _themeGreen,
        title: const Text(
          'WATCH',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
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

          final place =
          TeachPlace.fromDoc(snapshot.data!); // ← TeachPlace モデル

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      // 投稿者の情報を読み込む
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
              // 画像
              AspectRatio(
                aspectRatio: 16 / 9,
                child: place.imageUrl.isNotEmpty
                    ? Image.network(
                  place.imageUrl,
                  fit: BoxFit.cover,
                )
                    : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Text('画像なし'),
                  ),
                ),
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
                    const SizedBox(height: 8),

                    // 投稿者情報
                    if (owner != null) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: owner.imageUrl != null &&
                                owner.imageUrl!.isNotEmpty
                                ? NetworkImage(owner.imageUrl!)
                                : null,
                            child: (owner.imageUrl == null ||
                                owner.imageUrl!.isEmpty)
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            owner.name ?? 'HMLM USER',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 紹介文
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

                    // 人口密度評価
                    _buildStaticRatingRow(
                      label: 'PEOPLE (混雑度)',
                      value: place.densityScore,
                      filledIcon: Icons.person,
                    ),
                    const SizedBox(height: 8),

                    // 距離評価
                    _buildStaticRatingRow(
                      label: 'DISTANCE (行きやすさ)',
                      value: place.distanceScore,
                      filledIcon: Icons.location_city,
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
  }) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            final score = index + 1;
            final isActive = score <= value;
            return Icon(
              filledIcon,
              size: 22,
              // ★ ここを濃い緑に変更（フォーム画面と揃える）
              color: isActive
                  ? const Color(0xFF2F4F4F)
                  : Colors.grey,
            );
          }),
        ),
      ],
    );
  }
}
