import 'package:flutter/material.dart';

class ManualTeachScreen extends StatelessWidget {
  const ManualTeachScreen({super.key});

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TEACHとは',
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
          'TEACHのマニュアル画面（準備中）',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
