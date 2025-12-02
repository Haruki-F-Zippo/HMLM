import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのMaterialデザイン用ウィジェットを使用するためのパッケージをインポート

class CloseModalButton extends StatelessWidget { // モーダル（ダイアログ）を閉じるためのボタンを定義するStatelessWidgetクラス
  const CloseModalButton({super.key}); // コンストラクタ（キー指定のみで初期化）

  @override
  Widget build(BuildContext context) { // ウィジェットのUIを構築するbuildメソッド
    return Container( // 子ウィジェットのレイアウトや配置を制御するためのコンテナ
      width: double.infinity, // 幅を画面いっぱいに広げる設定
      alignment: Alignment.centerLeft, // 子ウィジェット（ボタン）を左寄せに配置
      child: IconButton( // アイコン付きボタンウィジェット
        onPressed: () => Navigator.of(context).pop(), // ボタンが押されたときにモーダルを閉じる（ナビゲーションスタックから戻る）
        icon: const Icon(Icons.close), // 閉じる（×）アイコンを表示
      ),
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリ内のモーダルウィンドウ（例：ログインやサインアップ画面など）を閉じるためのボタンを定義している。
// 「CloseModalButton」ウィジェットは左上に配置された「×」アイコンボタンを表示し、タップするとNavigator.pop()を呼び出してモーダルを閉じる。
// シンプルながらも共通デザインとして利用され、モーダル画面の閉じる操作を統一的に実現するためのコンポーネント。
