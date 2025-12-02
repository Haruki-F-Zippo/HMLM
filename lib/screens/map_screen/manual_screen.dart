import 'package:flutter/material.dart';

// ↓ 遷移先画面のファイルを同じフォルダに作る想定のimport
import 'manual_edit_profile_screen.dart';
import 'manual_teach_screen.dart';
import 'manual_watch_screen.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MANUAL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: _themeGreen,
        elevation: 4,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _ManualMenuItem(
            title: 'EDIT PROFILEとは',
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
            title: 'TEACHとは',
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
            title: 'WATCHとは',
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
