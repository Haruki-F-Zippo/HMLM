import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使うためのFlutterパッケージをインポート
import 'package:flutter/material.dart'; // Flutterの基本的なUIコンポーネントを提供するMaterialデザインパッケージをインポート

class AnimatedErrorMessage extends StatelessWidget { // アニメーション付きエラーメッセージを表示するStatelessWidgetクラス
  const AnimatedErrorMessage({ // コンストラクタ（不変のウィジェットなのでconst指定）
    super.key, // Widgetの一意識別用キー
    required this.errorMessage, // エラーメッセージ文字列を必須パラメータとして受け取る
  });

  final String errorMessage; // 表示するエラーメッセージの文字列を保持する変数

  @override
  Widget build(BuildContext context) { // ウィジェットのUIを構築するbuildメソッド
    return AnimatedOpacity( // 透明度をアニメーション付きで変更できるウィジェット
      opacity: errorMessage.isEmpty ? 0 : 1, // errorMessageが空なら非表示（透明）、空でなければ表示（不透明）
      duration: const Duration(milliseconds: 500), // アニメーションの長さを0.5秒に設定
      child: Container( // 子ウィジェットを囲むレイアウト用コンテナ
        width: double.infinity, // 横幅を親ウィジェットに合わせて最大化
        padding: const EdgeInsets.all(8), // 内側に8ピクセルの余白を設定
        decoration: const BoxDecoration( // 背景や枠線、角丸などの装飾を指定
          borderRadius: BorderRadius.all( // 全ての角を丸める設定
            Radius.circular(8), // 角の丸みを8ピクセルに設定
          ),
          color: Colors.red, // 背景色を赤に設定
        ),
        child: Text( // テキストウィジェットでエラーメッセージを表示
          errorMessage, // 表示する文字列（受け取ったエラーメッセージ）
          style: const TextStyle( // テキストの見た目を指定
            color: Colors.white, // 文字色を白に設定
          ),
        ),
      ),
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリ内でエラーメッセージをユーザーに視覚的に伝えるためのUIコンポーネント。
// 「AnimatedErrorMessage」ウィジェットは、渡された文字列（errorMessage）を赤いボックス内に表示し、
// メッセージがあるときにフェードイン、ないときにフェードアウトするアニメーション効果を実現。
// 主にフォーム入力などでエラーが発生した際に、ユーザーに自然なアニメーションで通知する用途で使われる。
