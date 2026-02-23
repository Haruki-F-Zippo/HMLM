// lib/screens/map_screen/manual/manual_teach_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManualTeachScreen extends StatelessWidget {
  const ManualTeachScreen({super.key});

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TEACHとは',
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
              '「TEACH」機能マニュアル',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'こちらは「TEACH」機能のマニュアルになります。'
                  'あなたが思う都内付近の閑散な魅力的な場所を、このHMLMアプリのユーザーに共有することができます。'
                  '共有する場所は1アカウントにつき1つのみです。\n'
                  '（みなさんの No.1 の場所を教えてほしいから）\n\n'
                  '「TEACH」で登録した場所を削除したい場合は、「DELETE」機能を実施してください。',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
            SizedBox(height: 12),
            Divider(),
            SizedBox(height: 6),

            Text(
              '「TEACH」機能利用方法',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),

            // STEP 1（テキストのみ）
            _StepBlock(
              stepNumber: 1,
              title: '登録したい場所をメインマップ画面中央の赤いピンに合わせる',
            ),

            // STEP 2（画像4）
            _StepBlock(
              stepNumber: 2,
              title: 'メインマップ画面下のタブの「TEACH」をタップする',
              imagePath: 'assets/images/manual_4.png',
              imageCaption: '画像4：メインマップ画面（TEACHタブ）',
            ),

            // STEP 3（画像5）
            _StepBlock(
              stepNumber: 3,
              title: '各入力内容を記載して「SAVE」をタップする',
              imagePath: 'assets/images/manual_5.png',
              imageCaption: '画像5：TEACH入力画面',
            ),

            // STEP 4（テキストのみ）
            _StepBlock(
              stepNumber: 4,
              title: 'あなたが登録した場所は、緑ピンとしてメインマップ画面に表示される',
            ),

            // STEP 5（画像6）
            _StepBlock(
              stepNumber: 5,
              title:
              'あなたが登録した場所（緑ピン）を削除したい場合、\nメインマップ画面下のタブの「DELETE」をタップする',
              imagePath: 'assets/images/manual_6.png',
              imageCaption: '画像6：緑ピンとDELETEタブ',
            ),

            // STEP 6（画像7）
            _StepBlock(
              stepNumber: 6,
              title: '「OK」をタップする',
              imagePath: 'assets/images/manual_7.png',
              imageCaption: '画像7：DELETE確認ダイアログ',
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
// ステップ共通ウィジェット（画像は任意）
// ===============================
class _StepBlock extends StatelessWidget {
  const _StepBlock({
    required this.stepNumber,
    required this.title,
    this.imagePath,
    this.imageCaption,
  });

  final int stepNumber;
  final String title;
  final String? imagePath;
  final String? imageCaption;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // STEP 同士の間隔
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

          // ★ 文言と画像の間の余白をかなり小さく
          if (imagePath != null) ...[
            const SizedBox(height: 4),

            // ★ 画像は幅だけ 2/3 に縮める
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.66, // 画面幅の 2/3
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 9 / 19.5, // 縦長スマホ画面ぽく
                    child: Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // 画像とキャプションの余白も最小限
            const SizedBox(height: 4),

            if (imageCaption != null)
              Text(
                imageCaption!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
