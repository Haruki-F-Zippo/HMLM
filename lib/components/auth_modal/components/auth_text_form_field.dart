import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのMaterialデザイン用ウィジェットを使用するためのパッケージをインポート

class AuthTextFormField extends StatelessWidget { // 認証画面で使用するテキスト入力フィールドを定義するStatelessWidgetクラス
  const AuthTextFormField({ // コンストラクタ（プロパティを初期化する）
    super.key, // Widgetの一意識別用キー
    this.controller, // 入力値を管理するTextEditingController（任意）
    this.onChanged, // 入力値が変更された際に呼び出されるコールバック関数（任意）
    this.validator, // 入力値のバリデーション（検証）を行う関数（任意）
    this.labelText = '', // テキストフィールド上部に表示されるラベル（デフォルトは空文字）
    this.obscureText = false, // 入力文字を非表示にするかどうか（パスワード入力時などに使用）
  });

  final TextEditingController? controller; // 入力値を制御・取得するためのコントローラ
  final void Function(String)? onChanged; // 入力内容が変化した際の処理を指定する関数
  final String? Function(String?)? validator; // 入力内容を検証してエラーメッセージを返す関数
  final String labelText; // 入力フィールドに表示するラベル文字列
  final bool obscureText; // 入力内容を隠す（パスワード用など）かどうかを示すフラグ

  @override
  Widget build(BuildContext context) { // ウィジェットのUIを構築するbuildメソッド
    return TextFormField( // ユーザーのテキスト入力を受け取るフォームウィジェット
      controller: controller, // テキストの状態を管理するコントローラを設定
      autovalidateMode: AutovalidateMode.onUserInteraction, // ユーザーが操作したタイミングで自動バリデーションを実行
      validator: validator, // 入力内容の検証関数を設定
      obscureText: obscureText, // 入力内容を非表示にする設定
      onChanged: onChanged, // 入力内容が変わるたびに呼び出される関数を設定
      decoration: InputDecoration( // テキストフィールドの外観を設定
        border: const OutlineInputBorder( // 枠線のスタイルを指定
          borderRadius: BorderRadius.all(Radius.circular(24)), // 角を丸く（半径24ピクセル）設定
        ),
        labelText: labelText, // フィールド上に表示するラベル文字
      ),
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリ内の認証（ログイン・新規登録）画面で使用される汎用的な入力フォームウィジェットを定義している。
// 「AuthTextFormField」ウィジェットは、入力値の管理（controller）、変更検知（onChanged）、バリデーション（validator）などに対応しており、
// パスワード入力時の非表示（obscureText）設定やラベル表示（labelText）にも対応している。
// 入力フォームのデザイン統一と再利用性向上を目的として設計されたコンポーネント。
