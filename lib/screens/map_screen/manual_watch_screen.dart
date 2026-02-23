// lib/screens/map_screen/manual/manual_watch_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ★ League Spartan用

class ManualWatchScreen extends StatelessWidget {
  const ManualWatchScreen({super.key});

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WATCHとは',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 2.5,
            color: Colors.black,
          ),
        ),
        backgroundColor: _themeGreen,
        elevation: 4,
        surfaceTintColor: Colors.transparent,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // --------------------
            // タイトル & 概要
            // --------------------
            Text(
              '「WATCH」機能マニュアル',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'こちらは「WATCH」機能のマニュアルになります。\n\n'
                  'HMLMアプリユーザーが「TEACH」機能で登録した、'
                  '都内付近の閑散な魅力的な場所を観覧（「WATCH」）することができます。\n\n'
                  '自身（ログインアカウント）で「TEACH」登録した場所は緑ピン、\n'
                  '他ユーザーが登録した場所は紫ピンでメインマップ画面に表示されるので、\n'
                  'ピンをタップして多くの魅力的な場所を観覧してください。',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 6),

            Text(
              '「WATCH」機能利用方法',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),

            // STEP 1（画像8）
            _StepBlock(
              stepNumber: 1,
              title: 'メインマップ画面に表示される紫ピン（＆緑ピン）をタップする',
              imagePath: 'assets/images/manual_8.png',
              imageCaption: '画像8：メインマップ画面（紫ピン＆緑ピン）',
            ),

            // STEP 2（画像9）
            _StepBlock(
              stepNumber: 2,
              title: 'アプリユーザーが「TEACH」で登録した場所の情報が表示される',
              imagePath: 'assets/images/manual_9.png',
              imageCaption: '画像9：WATCH詳細画面',
            ),

            SizedBox(height: 16),
            Text(
              '※画面デザインや文言は、アプリのアップデートにより変更になる場合があります。',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// ステップ + 画像用の共通ウィジェット
// ===============================
class _StepBlock extends StatelessWidget {
  const _StepBlock({
    required this.stepNumber,
    required this.title,
    required this.imagePath,
    required this.imageCaption,
  });

  final int stepNumber;
  final String title;
  final String imagePath;
  final String imageCaption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 各ステップ間の余白
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 「n. 説明」の行
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$stepNumber.',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          // ★ 文言と画像の間をかなりタイトに
          const SizedBox(height: 4),

          // ★ 画像サイズ：画面幅の 2/3
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.66, // 3分の2
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 9 / 19.5, // 縦長スマホ画面っぽく
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // 画像とキャプションの間も最小限
          const SizedBox(height: 4),

          // キャプション
          Text(
            imageCaption,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
