import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットを使用するためのパッケージをインポート

class SubmitButton extends StatelessWidget { // 送信ボタン（サインインや登録ボタンなど）を定義するStatelessWidgetクラス
  final String labelName; // ボタン上に表示するテキスト
  final bool isLoading; // ローディング状態を示すフラグ
  final VoidCallback onTap; // ボタンが押されたときに呼ばれるコールバック関数
  final Color backgroundColor; // ボタンの背景色
  final Color textColor; // ボタンの文字色

  const SubmitButton({ // コンストラクタ
    super.key,
    required this.labelName, // 表示するボタンラベルを受け取る
    required this.isLoading, // ローディング状態を受け取る
    required this.onTap, // タップ時の処理を受け取る
    this.backgroundColor = const Color(0xFF93B5A5), // デフォルト背景: #93B5A5（HMLMテーマカラー）
    this.textColor = Colors.white,                  // デフォルト文字色: 白
  });

  @override
  Widget build(BuildContext context) { // UIを構築するbuildメソッド
    return ElevatedButton( // マテリアルデザインの押し上げボタンウィジェット
      style: ElevatedButton.styleFrom( // ボタンのスタイルをカスタマイズ
        backgroundColor: backgroundColor, // 背景色を指定
        shape: RoundedRectangleBorder( // ボタンの角の形を設定
          borderRadius: BorderRadius.circular(8), // 角を丸く（8ピクセル）する
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), // ボタン内の余白を設定
      ),
      onPressed: onTap, // ボタンが押されたときの処理を設定
      child: isLoading // ローディング中かどうかで表示を分岐
          ? const CircularProgressIndicator(color: Colors.white) // ローディング中は白いインジケータを表示
          : Text( // 通常時はボタンラベルを表示
        labelName, // ボタンに表示するテキスト
        style: TextStyle(
          color: textColor, // テキストカラーを指定
          fontWeight: FontWeight.bold, // 太字に設定
          fontSize: 16, // フォントサイズを16に設定
        ),
      ),
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリ内で共通的に使用される送信ボタン（SubmitButton）コンポーネントを定義している。
// ボタンはラベル名・背景色・文字色・ローディング状態などを動的に変更でき、サインインや新規登録などで再利用される。
// ローディング中はCircularProgressIndicator（インジケータ）を表示し、通常時はテキストを表示する。
// ボタンデザインを統一し、アプリ全体のUI/UXの一貫性を保つための重要な共通ウィジェット。
