import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ← 追加
import '../map_screen/components/sign_in_button.dart';
import '../map_screen/map_screen.dart';

class PreLoginScreen extends StatelessWidget {
  const PreLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(25),
        child: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'HMLM',
              style: GoogleFonts.leagueSpartan( // ← ★ ブランドフォント適用
                fontWeight: FontWeight.w900,
                fontSize: 25,
                letterSpacing: 3, // ← 画像の雰囲気に寄せるポイント
                color: Colors.black,
              ),
            ),
          ),
          backgroundColor: const Color(0xFF93B5A5),
          elevation: 4,
        ),
      ),

      extendBody: true,

      body: SignInButton(
        onSignedIn: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const MapScreen(),
            ),
          );
        },
      ),
    );
  }
}
