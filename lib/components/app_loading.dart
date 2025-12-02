import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットを使用するためのパッケージをインポート

class AppLoading extends StatelessWidget { // アプリ内で共通的に使用するローディングインジケータを定義するStatelessWidgetクラス
  const AppLoading({ // コンストラクタ（キーと任意パラメータを受け取る）
    super.key,
    this.dimension = 20, // ローディングインジケータの大きさ（デフォルト20ピクセル）
    this.color = const Color(0xFF93B5A5), // ★ デフォルト色をHMLMテーマカラーに変更！
  });

  final double dimension; // インジケータのサイズを指定する変数
  final Color color; // インジケータの色を指定する変数

  @override
  Widget build(BuildContext context) { // ウィジェットのUIを構築するbuildメソッド
    return SizedBox.square( // 正方形サイズの領域を確保
      dimension: dimension, // 一辺の長さを指定（デフォルト20ピクセル）
      child: CircularProgressIndicator( // ローディングアニメーションを表示するウィジェット
        strokeWidth: 2, // 線の太さを2ピクセルに設定
        color: color, // ★ テーマカラーのぐるぐるが表示される
      ),
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// ・このファイルはHMLMアプリ全体で使用する共通ローディングインジケータを提供する。
// ・「dimension」でサイズ、「color」で色をカスタム可能。
// ・今回、デフォルト色をHMLMブランドカラー (#93B5A5) に変更。
// ・結果として、アプリ全体で統一感のあるローディングアニメーションが使えるようになる。
