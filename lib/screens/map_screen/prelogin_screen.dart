import 'package:flutter/material.dart'; // FlutterのMaterialデザイン用ウィジェットを使うためのパッケージをインポート
import '../map_screen/components/sign_in_button.dart'; // ログイン前画面で使う、背景画像つきLOG INボタンウィジェットをインポート
import '../map_screen/map_screen.dart'; // サインイン完了後に遷移するMapScreenをインポート

class PreLoginScreen extends StatelessWidget { // ログイン前ユーザーに表示する「プレログイン画面」を表すStatelessWidget
  const PreLoginScreen({super.key}); // コンストラクタ（特に追加パラメータなし、親クラスにkeyを渡すだけ）

  @override
  Widget build(BuildContext context) { // 画面に表示するウィジェットツリーを構築するbuildメソッド
    return Scaffold( // 画面全体の基本レイアウト構造（AppBarやbodyなど）を提供するウィジェット
      // ===========================
      // 🧭 ★ AppBar 修正版（高さ縮小 + 左寄せ）
      // ===========================
      appBar: PreferredSize( // デフォルトよりAppBarの高さをカスタマイズしたいときに使うラッパー
        preferredSize: const Size.fromHeight(25), // ← ★ AppBarの高さを25ピクセルに指定（標準より低くする）
        child: AppBar(// 実際のAppBarウィジェット（タイトルや背景色などを定義）
          automaticallyImplyLeading: false, // ← これで消える！
          centerTitle: false, // ← Androidでデフォルト中央寄せになる挙動を無効化し、左寄せを優先させるフラグ
          title: const Align( // AppBar内タイトルの位置を細かく制御するためにAlignでラップ
            alignment: Alignment.centerLeft, // ← ★ タイトルを左側に寄せて配置する指定
            child: Text( // 表示するテキスト（アプリ名 HMLM）
              'HMLM',
              style: TextStyle(
                fontWeight: FontWeight.bold, // 太字でタイトルを強調
                color: Colors.black, // タイトル文字色を黒に設定
                fontSize: 25, // タイトル文字サイズを25に設定（やや大きめだがAppBar低めなのでバランス調整）
              ),
            ),
          ),
          backgroundColor: const Color(0xFF93B5A5), // AppBar全体の背景色をHMLMテーマカラー(#93B5A5)に設定
          elevation: 4, // AppBarの下に影（シャドウ）をつけて、コンテンツとの境界を少し強調
        ),
      ),

      extendBody: true, // body領域をBottomNavigationBar等の裏まで描画可能にするフラグ（背景画像などをフルスクリーン表示したいときに使う）

      // ===========================
      // 🧩 背景＋LOG IN ボタン
      // ===========================
      body: SignInButton( // 画面のメインコンテンツとして、背景画像＋ガラス風LOG INボタンを表示するカスタムウィジェット
        onSignedIn: () async { // サインイン処理が成功したあとに呼び出されるコールバック関数
          Navigator.of(context).pushReplacement( // 現在のPreLogin画面をスタックから置き換えて、次の画面に遷移する
            MaterialPageRoute( // 典型的な画面遷移用のルート（左右スライド等の標準トランジション付き）
              builder: (_) => const MapScreen(), // 遷移先として、アプリのメインとなるMapScreenウィジェットを生成
            ),
          );
        },
      ),
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// ・このファイルは、HMLMアプリの「ログイン前トップ画面（PreLoginScreen）」を定義している。
// ・Scaffoldを使って画面の骨組みを作成し、上部には高さを低めに調整したAppBarを表示している。
//   - AppBarのタイトルには 'HMLM' を表示し、左寄せ＆テーマカラー(#93B5A5)の背景でブランド感を演出。
// ・bodyにはSignInButtonウィジェットを配置しており、背景画像＋ガラス風の「LOG IN」ボタンUIを全画面に表示する。
// ・SignInButtonのonSignedInコールバックには、Firebase Authなどでサインインが成功したタイミングで
//   MapScreenへ画面遷移する処理を渡しており、pushReplacementを使うことでPreLogin画面に戻らないフローを実現している。
// ・結果として、アプリの起動フローは以下のような構成になる想定：
//   1) スプラッシュ（別ファイル）
//   2) 未ログインなら PreLoginScreen（このファイルの画面）
//   3) LOG IN ボタンから認証モーダル → サインイン成功
//   4) MapScreen へ遷移し、以降はマップベースのメイン機能を利用する流れになる。
