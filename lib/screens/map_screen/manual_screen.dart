import 'dart:ui'; // ★ ぼかしに必要
import 'package:flutter/material.dart';

// ↓ 遷移先画面のファイルを同じフォルダに作る想定のimport
import 'manual_edit_profile_screen.dart';
import 'manual_teach_screen.dart';
import 'manual_watch_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // ← League Spartan 追加


class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MANUAL',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 3,
            color: Colors.black,
          ),
        ),
        backgroundColor: _themeGreen,
        elevation: 4,
        // ★ M3の色変化を防止
        surfaceTintColor: Colors.transparent,
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
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _ManualMenuItem(
            title: '手順01.EDIT PROFILEとは',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ManualEditProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ManualMenuItem(
            title: '手順02.TEACHとは',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ManualTeachScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ManualMenuItem(
            title: '手順03.WATCHとは',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ManualWatchScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ===============================
// 行型ボタン用の共通ウィジェット
// ===============================
class _ManualMenuItem extends StatelessWidget {
  const _ManualMenuItem({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // タップ時に遷移処理を実行
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左側：タイトル文字
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // 右側：→ アイコン（遷移感を出す）
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
