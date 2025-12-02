import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットライブラリをインポート

void main() { // アプリのエントリーポイント（最初に実行される関数）
  runApp(const MyApp()); // MyAppウィジェットをアプリ全体として実行
}

class MyApp extends StatelessWidget { // アプリ全体を管理するStatelessWidget（状態を持たない）
  const MyApp({super.key}); // コンストラクタ（keyを親Widgetに渡す）

  @override
  Widget build(BuildContext context) { // UIを構築するメソッド
    return MaterialApp( // アプリ全体のルートWidget（テーマやタイトルを設定）
      title: 'Flutter Demo', // アプリタイトル（デバッグ用などに使用）
      theme: ThemeData( // アプリ全体のテーマ設定
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF93B5A5)), // ← ブランドカラー#93B5A5をシードにしたカラースキームを生成
        useMaterial3: true, // ← Material Design 3（最新デザイン仕様）を有効化
      ),
      home: const MyHomePage(title: 'WELCOME TO HMLM'), // ← 最初に表示する画面（MyHomePage）を指定
    );
  }
}

class MyHomePage extends StatefulWidget { // 状態を持つ画面Widget
  const MyHomePage({super.key, required this.title}); // コンストラクタでタイトルを受け取る

  final String title; // AppBarに表示するタイトル文字列

  @override
  State<MyHomePage> createState() => _MyHomePageState(); // 状態管理クラスを生成
}

class _MyHomePageState extends State<MyHomePage> { // MyHomePageの状態を保持するクラス
  int _counter = 0; // ← 画面に表示するカウンターの変数（初期値0）

  void _incrementCounter() { // カウンターを1増やす関数
    setState(() { // ← 状態を更新しUIを再描画
      _counter++; // カウンターの値を+1
    });
  }

  @override
  Widget build(BuildContext context) { // UIを構築するメソッド
    return Scaffold( // 画面の基本構造（AppBar・Body・FABなどを含む）
      appBar: AppBar( // 画面上部のAppBar
        backgroundColor: Theme.of(context).colorScheme.inversePrimary, // ← テーマの補色を背景色に使用
        title: Text(widget.title), // ← コンストラクタで渡されたタイトルを表示
      ),
      body: Center( // ← 中央寄せ配置
        child: Column( // ← 縦方向にウィジェットを並べる
          mainAxisAlignment: MainAxisAlignment.center, // ← 縦方向中央寄せ
          children: <Widget>[ // 子ウィジェットのリスト
            const Text( // ← 固定テキスト
              'TAP ON "LOGIN"', // 表示文字列
            ),
            Image.asset( // ← アセット（ローカル画像）を表示
              "assets/images/HMLM_Loanch.png", // 画像ファイルのパス
              width: 200, // ← 幅200ピクセル
              height: 200, // ← 高さ200ピクセル
            ),
            Text( // ← カウンター値を表示
              '$_counter', // ← 現在のカウント値を文字列として埋め込み
              style: Theme.of(context).textTheme.headlineMedium, // ← テーマに沿った中サイズのテキストスタイルを適用
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton( // ← 右下のアクションボタン
        onPressed: _incrementCounter, // ← タップ時にカウンター増加関数を呼ぶ
        tooltip: 'Increment', // ← 長押し時に表示されるヒント
        child: const Icon(Icons.add), // ← 「＋」アイコンを表示
      ), // This trailing comma makes auto-formatting nicer for build methods. // Flutter推奨のカンマ（整形をきれいにするため）
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、FlutterアプリのエントリーポイントおよびメインUI構造を定義している。
// ■ 主な構成：
// ・main()：アプリを起動し、MyAppを実行。
// ・MyApp：全体のテーマや最初に表示する画面(MyHomePage)を設定。
// ・MyHomePage：中央に「TAP ON LOGIN」と画像、カウンターを表示する画面。
// ・FloatingActionButton：タップでカウンターがインクリメントし、再描画される。
// ■ 特徴：
// ・ブランドカラー#93B5A5を基調としたシンプルなデザイン構成。
// ・Flutterの基本構造（Scaffold, AppBar, Column, FAB）を学習・確認するサンプルコード。
// ・「HMLM_Loanch.png」を利用したHMLMアプリの起動画面プロトタイプ。
