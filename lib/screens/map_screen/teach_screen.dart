import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ← ブランドフォント用


class TeachScreen extends StatelessWidget {
  const TeachScreen({super.key});

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TEACH',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2.5, // ← 少し間隔あけてブランド感を統一
            color: Colors.black,
          ),
        ),
        backgroundColor: _themeGreen,
        elevation: 4,
      ),

    );
  }
}

