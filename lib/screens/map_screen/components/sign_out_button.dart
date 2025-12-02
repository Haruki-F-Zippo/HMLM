import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットを使用するためのパッケージをインポート
import '../../../components/app_loading.dart'; // 共通ローディングインジケータ(AppLoading)をインポート

class SignOutButton extends StatelessWidget { // サインアウト（ログアウト）ボタンを定義するStatelessWidgetクラス
  const SignOutButton({ // コンストラクタ（キー、押下時処理、ローディング状態を受け取る）
    super.key,
    required this.onPressed, // ボタン押下時のコールバック関数（必須）
    this.isLoading = false, // ローディング状態（デフォルトはfalse）
  });

  final VoidCallback onPressed; // ボタンが押されたときに実行される処理
  final bool isLoading; // 現在ローディング中かどうかを示すフラグ

  @override
  Widget build(BuildContext context) { // ウィジェットのUIを構築するbuildメソッド
    return FloatingActionButton( // 画面上に浮かぶ円形のボタンを作成
      onPressed: onPressed, // 押下時に指定された処理を実行
      child: isLoading // ローディング中かどうかで表示内容を切り替える
          ? const AppLoading() // ローディング中の場合は共通ローディングインジケータを表示
          : const Icon(Icons.logout), // 通常時はログアウトアイコンを表示
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリ内でログアウト機能を実行する「SignOutButton」ウィジェットを定義している。
// FloatingActionButtonをベースにしており、押下時に指定されたonPressed関数を実行してサインアウト処理を行う。
// isLoadingフラグによって状態を切り替え、サインアウト処理中はAppLoadingインジケータを表示してユーザーに処理中であることを知らせる。
// シンプルながらも視覚的なフィードバックを提供し、UXを向上させるための共通ボタンコンポーネント。
