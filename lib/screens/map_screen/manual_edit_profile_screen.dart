// lib/screens/map_screen/manual/manual_edit_profile_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ← League Spartan用


class ManualEditProfileScreen extends StatelessWidget {
  const ManualEditProfileScreen({super.key});

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EDIT PROFILEとは',
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
              'プロフィール設定マニュアル',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'こちらはプロフィール設定のマニュアルになります。'
                  'あなた（作成したアカウント）のニックネームや紹介文を登録することができます。'
                  'プロフィール設定をしないと、HMLMアプリのメイン機能である「TEACH」を利用することができません。'
                  '設定したプロフィールは、あなたが登録した場所を他のアプリユーザーがWATCH（観覧）する際に表示されます。',
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
              ),
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 6),

            // --------------------
            // プロフィール設定方法
            // --------------------
            Text(
              'プロフィール設定方法',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),

            // STEP 1
            _StepBlock(
              stepNumber: 1,
              title: 'メインマップ画面右上の人型アイコンをタップする',
              imagePath: 'assets/images/manual_1.png',
              imageCaption: '画像1：メインマップ画面',
            ),

            // STEP 2
            _StepBlock(
              stepNumber: 2,
              title: 'PROFILE画面の「EDIT PROFILE」ボタンをタップする',
              imagePath: 'assets/images/manual_2.png',
              imageCaption: '画像2：PROFILE画面',
            ),

            // STEP 3
            _StepBlock(
              stepNumber: 3,
              title: '各入力内容を記載して「SAVE」ボタンをタップする',
              imagePath: 'assets/images/manual_3.png',
              imageCaption: '画像3：EDIT PROFILE画面',
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
      // STEP 同士の間隔
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 「1. 〜〜」の行
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
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          // ★ 文言と画像の間の余白をかなり小さく
          const SizedBox(height: 4),

          // ★ 画像は幅だけ 2/3 に縮める（Transform.scale は使わない）
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.66, // 画面幅の 2/3
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

          // 画像とキャプションの距離も少なめに
          const SizedBox(height: 4),

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
