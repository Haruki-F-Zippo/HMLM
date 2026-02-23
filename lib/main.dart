import 'dart:ui'; // ← グローバルエラーハンドラ（PlatformDispatcher）で使用
import 'package:flutter/material.dart'; // ← Flutterの基本UIライブラリをインポート
import 'package:googlemap_api/screens/map_screen/map_screen.dart'; // ← アプリのメイン画面（MapScreen）をインポート
import 'package:googlemap_api/firebase_options.dart'; // ← Firebaseの設定情報をインポート
import 'package:firebase_core/firebase_core.dart'; // ← Firebase初期化に必要なパッケージをインポート
import 'package:firebase_auth/firebase_auth.dart'; // ← Firebase認証の状態（ログイン済みか）を確認するために使用
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // ← Crashlyticsエラーレポート送信用
import 'package:googlemap_api/screens/map_screen/prelogin_screen.dart'; // ← ログイン前に見せる画面

Future<void> main() async { // ← アプリのエントリーポイント（非同期関数）
  WidgetsFlutterBinding.ensureInitialized(); // ← Flutterエンジンとウィジェットのバインディングを初期化
  await Firebase.initializeApp( // ← Firebaseを初期化
    options: DefaultFirebaseOptions.currentPlatform, // ← 現在のプラットフォーム用のFirebase設定を読み込む
  );

  // Flutterフレームワーク起因の致命的エラーをCrashlyticsへ送信
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // 非同期ゾーン外の致命的エラーをCrashlyticsへ送信
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp()); // ← MyAppウィジェットをアプリとして実行
}

class MyApp extends StatelessWidget { // ← アプリ全体を定義するStatelessWidget
  const MyApp({super.key}); // ← コンストラクタ（keyを親に渡す）

  @override
  Widget build(BuildContext context) { // ← UIを構築するメソッド
    return MaterialApp( // ← アプリ全体を包むウィジェット
      title: 'Flutter Demo', // ← アプリタイトル（デバッグなどに使用）
      theme: ThemeData(primarySwatch: Colors.blue), // ← 全体テーマ（青系）
      debugShowCheckedModeBanner: false, // ← デバッグバナー（右上のDEBUG）を非表示
      home: const SplashGate(), // ← 起動時にスプラッシュ画面を最初に表示
    );
  }
}

// ===============================
// 🐬 スプラッシュ画面（1.5秒表示）
// ===============================
class SplashGate extends StatefulWidget { // ← スプラッシュ画面用のStatefulWidget
  const SplashGate({super.key}); // ← コンストラクタ

  @override
  State<SplashGate> createState() => _SplashGateState(); // ← 状態管理クラスを生成
}

class _SplashGateState extends State<SplashGate> { // ← スプラッシュ画面の状態を管理するクラス
  @override
  void initState() { // ← Widget生成時に1回だけ実行される初期化処理
    super.initState();

    // 1.5秒後に「ログイン状態を確認して」遷移先を決定
    Future.delayed(const Duration(milliseconds: 1500), () { // ← 1.5秒（1500ms）待機してから処理を実行
      // FirebaseAuth から現在ログインしているユーザーを取得
      // ・user == null      → 未ログイン
      // ・user != null      → ログイン済み
      final User? user = FirebaseAuth.instance.currentUser; // ← 認証済みユーザー情報（なければ null）

      // ログイン済みなら MapScreen、未ログインなら PreLoginScreen を表示
      final Widget nextScreen = (user == null)
          ? const PreLoginScreen() // ← ログイン前に見せたい画面
          : const MapScreen();     // ← ログイン済みなら従来どおりMapScreenへ

      // ==============================
      // 🎨 フェードで画面遷移する部分
      // ==============================
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(
            milliseconds: 600,
          ), // ← フェードアニメーションの時間
          pageBuilder: (_, animation, __) {
            // animationの値(0.0→1.0)をそのまま不透明度に使う
            return FadeTransition(
              opacity: animation, // ← 透明(0.0) → 不透明(1.0) に変化
              child: nextScreen,  // ← MapScreen or PreLoginScreen
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) { // ← スプラッシュ画面のUIを構築
    return const ColoredBox( // ← 単色背景のウィジェット
      color: Color(0xFF93B5A5), // 背景色をブランドカラー（#93B5A5）に設定
      child: Center( // ← 画面中央に配置
        child: Image( // ← 画像ウィジェット
          image: AssetImage('assets/images/HMLM_Loanch.png'), // ← アプリ起動画面ロゴ画像
          width: 280, // ロゴの横幅
          fit: BoxFit.contain, // ← アスペクト比を維持しつつ収める
        ),
      ),
    );
  }
}



// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリのエントリーポイント（main.dart）であり、
// アプリ起動時の初期処理とスプラッシュ画面表示、そしてログイン状態による画面出し分けを行う。
//
// ■ 主な構成：
// ・Firebase初期化処理（Firebase.initializeApp）
// ・MyAppクラス：全体テーマとルート（最初の画面）を定義
// ・SplashGateクラス：アプリ起動時に1.5秒ロゴを表示し、その後ログイン状態に応じて画面遷移
//    - ログイン済み   → MapScreen へ（フェードで遷移）
//    - 未ログイン     → PreLoginScreen へ（フェードで遷移）
//
// ■ 流れ：
// アプリ起動 → Firebase初期化 → SplashGate表示（1.5秒）
//   → FirebaseAuth.currentUser を確認
//     → user != null（ログイン済） : MapScreenへ自動遷移（フェード）
//     → user == null（未ログイン） : PreLoginScreenへ自動遷移（フェード）
