import 'package:flutter/material.dart';

class ManualEditProfileScreen extends StatelessWidget {
  const ManualEditProfileScreen({super.key});

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EDIT PROFILEとは',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: _themeGreen,
        elevation: 4,
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'EDIT PROFILEのマニュアル画面（準備中）',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
