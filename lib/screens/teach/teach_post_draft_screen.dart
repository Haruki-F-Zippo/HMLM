// lib/screens/teach/teach_post_draft_screen.dart
import 'dart:io';
import 'dart:ui'; // ★ ぼかし（BackdropFilter / ImageFilter）用
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/teach_place.dart';
import 'package:google_fonts/google_fonts.dart'; // ★ League Spartan 用


class TeachPostDraftScreen extends StatefulWidget {
  const TeachPostDraftScreen({
    super.key,
    required this.initialLatLng,
  });

  final LatLng initialLatLng;

  @override
  State<TeachPostDraftScreen> createState() => _TeachPostDraftScreenState();
}

class _TeachPostDraftScreenState extends State<TeachPostDraftScreen> {
  static const _themeGreen = Color(0xFF93B5A5);

  /// アイコンのアクティブ色(濃い緑)
  static const _selectedIconColor = Color(0xFF2F4F4F);

  /// PEOPLE / DISTANCE ラベル部分の幅
  static const double _ratingLabelWidth = 110;

  final _formKey = GlobalKey<FormState>();
  final _placeNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _densityScore = 3;
  int _distanceScore = 3;

  File? _imageFile;
  bool _isSaving = false;

  // ✅ 交通手段の選択状態
  String _selectedTransportation = '徒歩';

  // ✅ 選択肢
  final List<String> _transportationOptions = [
    '徒歩',
    '自転車',
    '車',
    '電車',
  ];

  // 🚃 交通手段ごとのアイコン
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

  // 🚩 DISTANCE 評価に使うアイコン（選択中の交通手段に連動）
  IconData _distanceRatingIcon() {
    return _transportationIcon(_selectedTransportation);
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
    });
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像を1枚選択してください')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final uid = user.uid;
      final lat = widget.initialLatLng.latitude;
      final lng = widget.initialLatLng.longitude;

      final imagePath = 'teach_images/$uid.jpg';
      final ref = FirebaseStorage.instance.ref().child(imagePath);
      await ref.putFile(_imageFile!);
      final imageUrl = await ref.getDownloadURL();

      final now = Timestamp.now();
      final place = TeachPlace(
        ownerUserId: uid,
        placeName: _placeNameController.text.trim(),
        description: _descriptionController.text.trim(),
        lat: lat,
        lng: lng,
        densityScore: _densityScore,
        distanceScore: _distanceScore,
        imageUrl: imageUrl,
        imagePath: imagePath,
        createdAt: now,
        updatedAt: now,
        // ✅ 交通手段を保存
        transportation: _selectedTransportation,
      );

      await FirebaseFirestore.instance
          .collection('teach_places')
          .doc(uid)
          .set(place.toMap());

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存に失敗しました')),
      );
    }
  }

  // ⭐ PEOPLE / DISTANCE の評価行
  Widget _buildRatingRow({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    IconData filledIcon = Icons.star,
    String? leftCaption,
    String? rightCaption,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 左ラベル（2行表示でもOK）
        SizedBox(
          width: _ratingLabelWidth,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),

        // 右側：アイコン + 基準テキスト
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // アイコン行
              Row(
                children: List.generate(5, (index) {
                  final score = index + 1;
                  final isActive = score <= value;

                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      filledIcon,
                      size: 24,
                      color: isActive ? _selectedIconColor : Colors.grey,
                    ),
                    onPressed: () => onChanged(score),
                  );
                }),
              ),

              // 基準テキスト行（省略可）
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

  // ✅ 交通手段ボタン（4つを必ず1行で並べる）
  Widget _buildTransportationChips() {
    return Row(
      children: _transportationOptions.map((label) {
        final selected = _selectedTransportation == label;
        final iconData = _transportationIcon(label);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _selectedTransportation = label; // ← これで DISTANCE アイコンも更新される
                });
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: selected ? _themeGreen : Colors.white,
                  border: Border.all(
                    color:
                    selected ? _themeGreen : Colors.grey.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      size: 18,
                      color: selected ? _selectedIconColor : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _themeGreen,
        centerTitle: true,
        elevation: 4, // ★ 他画面と高さ感を合わせる
        surfaceTintColor:
        Colors.transparent, // ★ M3のティントを殺して色味変化を防止
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
          'TEACH',
          style: GoogleFonts.leagueSpartan(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 20, // 他画面と揃えるなら 20〜22 あたりでOK
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 28),
            onPressed:
            _isSaving ? null : () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PLACE NAME
                    const Text(
                      'PLACE NAME',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _placeNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '例）城北中央公園',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '場所名を入力してください'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    // PICTURE
                    const Text(
                      'PICTURE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: _imageFile == null
                            ? const Center(
                          child: Text('画像をタップして選択してください'),
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // EXPLAIN
                    const Text(
                      'EXPLAIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '場所についての説明やその魅力について記載してください',
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TRANSPORTATION
                    const Text(
                      'TRANSPORTATION(新宿駅からの交通手段)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildTransportationChips(),

                    const SizedBox(height: 16),

                    // PEOPLE
                    _buildRatingRow(
                      label: 'PEOPLE\n(混雑度)',
                      value: _densityScore,
                      onChanged: (v) => setState(() => _densityScore = v),
                      filledIcon: Icons.person,
                      leftCaption: '←奥多摩並み(Good)',
                      rightCaption: '新宿並み(Bad)→',
                    ),

                    const SizedBox(height: 12),

                    // DISTANCE（アイコンが交通手段と連動）
                    _buildRatingRow(
                      label: 'DISTANCE\n(行きやすさ)',
                      value: _distanceScore,
                      onChanged: (v) => setState(() => _distanceScore = v),
                      filledIcon: _distanceRatingIcon(),
                      leftCaption: '←ex. 新宿へ(Good)',
                      rightCaption: 'ex. 奥多摩へ(Bad)→',
                    ),

                    const SizedBox(height: 20),

                    // ✅ 追加テキスト
                    const Text(
                      '※新宿駅をスタート地点とした\n 交通手段＆DISTANCE(行きやすさ)を設定してください',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),

            // SAVE ボタン
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white.withOpacity(0.9),
                child: SizedBox(
                  width: 150,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _onSavePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeGreen,
                      foregroundColor: Colors.black,
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : const Text(
                      'SAVE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
