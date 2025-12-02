// lib/screens/teach/teach_post_draft_screen.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/teach_place.dart';

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

  /// ← ★ アイコンのアクティブ色(濃い緑)を追加
  static const _selectedIconColor = Color(0xFF2F4F4F);

  final _formKey = GlobalKey<FormState>();
  final _placeNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _densityScore = 3;
  int _distanceScore = 3;

  File? _imageFile;
  bool _isSaving = false;

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
      );

      await FirebaseFirestore.instance
          .collection('teach_places')
          .doc(uid)
          .set(place.toMap());

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  // ⭐ アイコン評価UI（色変更済み）
  Widget _buildRatingRow({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    IconData filledIcon = Icons.star,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
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

                // 👇 ★ココ変更 → 選択時：濃い緑 / 非選択時：グレー
                color: isActive ? _selectedIconColor : Colors.grey,
              ),
              onPressed: () => onChanged(score),
            );
          }),
        ),
      ],
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
        title: const Text(
          'TEACH',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 28),
            onPressed: _isSaving ? null : () => Navigator.of(context).maybePop(),
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
                    const Text('PLACE NAME', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _placeNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '例）静かな川沿いのベンチ',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '場所名を入力してください'
                          : null,
                    ),

                    const SizedBox(height: 16),

                    const Text('PICTURE', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            ? const Center(child: Text('画像をタップして選択してください'))
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('EXPLAIN', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'どんなところが「HMLM」っぽい静かな場所か教えてください',
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildRatingRow(
                      label: 'PEOPLE (混雑度)',
                      value: _densityScore,
                      onChanged: (v) => setState(() => _densityScore = v),
                      filledIcon: Icons.person,
                    ),

                    const SizedBox(height: 8),

                    _buildRatingRow(
                      label: 'DISTANCE (行きやすさ)',
                      value: _distanceScore,
                      onChanged: (v) => setState(() => _distanceScore = v),
                      filledIcon: Icons.location_city,
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white.withOpacity(0.9),
                child: SizedBox(
                  width: double.infinity,
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
