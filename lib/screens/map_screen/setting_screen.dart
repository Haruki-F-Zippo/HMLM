import 'dart:ui'; // ぼかし効果（BackdropFilter等）に必要なUIライブラリ
import 'package:flutter/material.dart'; // Materialデザインのウィジェット群
import 'package:firebase_auth/firebase_auth.dart'; // Firebase認証（サインイン/削除等）
import 'package:cloud_firestore/cloud_firestore.dart'; // Cloud Firestore（DB操作）
import 'map_screen.dart'; // 退会後に戻る画面
import 'term_screen.dart'; // 利用規約画面への遷移先
import 'contact_screen.dart'; // お問い合わせ画面への遷移先

class SettingScreen extends StatefulWidget { // 設定画面のルートWidget（状態あり）
  const SettingScreen({super.key}); // コンストラクタ（特別な引数は無し）

  @override
  State<SettingScreen> createState() => _SettingScreenState(); // Stateクラスを生成
}

class _SettingScreenState extends State<SettingScreen> { // 設定画面の状態管理クラス
  Future<void> _deleteAccountAndData() async { // 退会（データ削除＋アカウント削除）処理本体
    final auth = FirebaseAuth.instance; // FirebaseAuthインスタンスを取得
    final firestore = FirebaseFirestore.instance; // Firestoreインスタンスを取得
    final user = auth.currentUser; // 現在ログイン中のユーザー情報を取得

    if (user == null) { // ユーザーが未ログインの場合のガード
      if (!mounted) return; // 画面が既に破棄されていれば何もしない
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログイン情報が見つかりませんでした。')), // エラーメッセージをSnackbarで表示
      );
      return; // 退会処理を中断
    }

    final navigator = Navigator.of(context, rootNavigator: true); // ルートNavigator（ダイアログ表示や画面遷移用）
    final uid = user.uid; // Firestoreドキュメント削除に使うUIDを退避

    // ローディングダイアログを表示（非同期処理中のインジケータ）
    showDialog( // モーダルダイアログとして進行中の状態を表示
      context: context, // 現在のBuildContext
      barrierDismissible: false, // 外側タップで閉じられないように設定
      useRootNavigator: true, // ルートNavigatorを使用してダイアログを表示
      builder: (_) => const Center(child: CircularProgressIndicator()), // 中央にローディングインジケータを表示
    );

    try {
      // Firestoreの users/{uid} ドキュメントを削除（存在しない場合のエラーは無視）
      await firestore.collection('users').doc(uid).delete().catchError((_) {}); // 失敗しても処理継続

      // Firebase Authのユーザーアカウントを削除
      await user.delete(); // 認証ユーザー自体を削除

      // 念のためsignOutして、アプリ内の認証状態もクリア
      await auth.signOut(); // サインアウト処理

      // ローディングダイアログを閉じる
      if (navigator.canPop()) navigator.pop(); // ダイアログが開いていれば閉じる

      // ログイン前の画面（ここではMapScreen）に戻る（履歴をすべて破棄）
      navigator.pushAndRemoveUntil( // すべての既存ルートを削除してMapScreenに遷移
        MaterialPageRoute(builder: (_) => const MapScreen()), // 遷移先の画面
            (route) => false, // 既存ルートを全削除する条件
      );
    } on FirebaseAuthException catch (e) { // Firebase認証関連の例外をキャッチ
      if (navigator.canPop()) navigator.pop(); // ローディングダイアログを閉じる

      if (!mounted) return; // 画面が破棄されている場合はそれ以上何もしない

      if (e.code == 'requires-recent-login') { // 「直近のログインが必要」な場合
        await auth.signOut(); // サインアウトして再ログインを促す
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('安全のため再ログインが必要です。再ログイン後に退会を再実行してください。')), // 再ログインの必要性を案内
        );
        navigator.pushAndRemoveUntil( // MapScreenへ戻して再ログインの動線を作る
          MaterialPageRoute(builder: (_) => const MapScreen()), // 遷移先
              (route) => false, // 既存ルートを全削除
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('退会に失敗しました（${e.code}）')), // その他の認証エラーコードを表示
        );
      }
    } catch (e) { // 想定外の一般例外をキャッチ
      if (navigator.canPop()) navigator.pop(); // ローディングダイアログを閉じる
      if (!mounted) return; // 画面が破棄されていれば終了
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('退会に失敗しました。しばらくしてからお試しください。')), // 共通的なエラーメッセージ
      );
    }
  }

  void _showWithdrawalDialog() { // 退会確認ダイアログを表示するヘルパー関数
    showDialog( // アラートダイアログを表示
      context: context, // 現在のBuildContext
      builder: (dialogCtx) => AlertDialog( // 確認ダイアログのUI
        title: const Text("本当に退会しますか？"), // ダイアログタイトル
        content: const Text( // ダイアログ本文（注意文）
          '退会するとアカウントが削除されます。', // ユーザへの注意メッセージ
          style: TextStyle(
            fontSize: 13, // やや小さめのフォントサイズ
            color: Colors.black54, // 少し薄めの黒で控えめな表示
            height: 1.3, // 行間
          ),
        ),
        actions: [ // ダイアログ下部のボタン群
          TextButton( // キャンセルボタン
            onPressed: () => Navigator.of(dialogCtx).pop(), // ダイアログを閉じるだけ
            style: TextButton.styleFrom(foregroundColor: Color(0xFF93B5A5)), // ブランドカラーでテキスト色を指定
            child: const Text("キャンセル"), // ボタンラベル
          ),
          TextButton( // 退会実行ボタン
            onPressed: () async { // 退会実行時の処理
              Navigator.of(dialogCtx).pop(); // 先にダイアログを閉じる
              await _deleteAccountAndData();  // 退会処理本体を実行
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red), // 警告の意味で赤色テキスト
            child: const Text("退会"), // ボタンラベル
          ),
        ],
      ),
    );
  }

  void _onSend() { // （将来用）送信ボタン押下時のプレースホルダ処理
    // TODO: メール送信やFirestore保存などの実処理をここに実装予定
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('送信（未実装）')), // 現状は未実装である旨を知らせるSnackbar
    );
  }

  @override
  Widget build(BuildContext context) { // 画面全体のUIツリーを構築するbuildメソッド
    return Scaffold( // 画面の基本レイアウト（AppBar + body）
        appBar: AppBar( // 画面上部のバー（タイトルや戻るボタン）
          title: const Text(
            'SETTING', // AppBarに表示するタイトル文字
            style: TextStyle(
              color: Colors.black, // タイトル文字色を黒に設定
              fontWeight: FontWeight.bold, // タイトルを太字にする
            ),
          ),
          automaticallyImplyLeading: true, // デフォルトの戻る矢印ボタンを表示
          iconTheme: const IconThemeData(color: Colors.black), // AppBar内アイコンの色を黒に統一
          elevation: 4, // AppBar下部に影（ドロップシャドウ）を付ける
          backgroundColor: Color(0xFF93B5A5), // AppBarの背景色をブランドカラー(#93B5A5)に設定
          surfaceTintColor: Colors.transparent, // Material3の自動ティント（色味の上書き）を無効化
          flexibleSpace: ClipRect( // ぼかしの適用範囲をAppBar内に限定するためのラッパー
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // X/Y方向に12pxのぼかしを適用
              child: Container(
                color: Colors.transparent, // 中身は透明で、背景色はbackgroundColorが担当
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white, // 画面全体のベース背景色を白に設定
        body: Stack( // body全体をStackにして、背景画像と前景コンテンツと下部バーを重ねる
          alignment: Alignment.topCenter, // Stack内の基準位置を「上中央」に設定
          children: [
            // ================================
            // 🖼 HMLM_UP.png を「下部バーの上まで」背景として配置
            // ================================
            Positioned.fill( // 画面全体を埋めるが、bottomを指定して下部バー分だけ空ける
              bottom: 60, // ← 下部バーの高さ分だけ背景画像の描画範囲を上に切り上げる
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.10), // 背景を明るく薄く重ねる
                  BlendMode.screen,
                ),
                child: Image.asset(
                  'assets/images/HMLM_UP.png',
                  fit: BoxFit.cover, // 画面を自然にカバーするように拡大縮小
                  alignment: Alignment.topCenter, // 上を基準にして表示
                ),
              ),
            ),

            // ================================
            // 🎛 ボタン群と「何する？」テキスト（背景画像の上に載せる）
            // ================================
            Align( // コンテンツ全体の位置を制御するAlign
              alignment: Alignment.topCenter, // 上中央に揃える
              child: ConstrainedBox( // 横幅の最大値を制限して見やすくする
                constraints: const BoxConstraints(maxWidth: 420), // 最大幅420pxに制限
                child: Padding(
                  padding: const EdgeInsets.only(top: 30), // AppBar直下に余白を入れる
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 子Widgetのサイズに応じた最小限の高さにする
                    children: [
                      // --- ボタン群（退会 / お問い合わせ / 利用規約） ---
                      Row( // 3つのボタンを横並びで表示
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ボタンを均等配置
                        children: [
                          // --- 退会ボタン ---
                          ElevatedButton(
                            onPressed: _showWithdrawalDialog, // 退会確認ダイアログの表示処理を呼び出す
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // ボタン背景色を白に設定
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // 角を8px丸める
                              ),
                              overlayColor: Colors.black54.withOpacity(0.08), // 押下時の軽い波紋色
                              splashFactory: InkRipple.splashFactory, // リップルエフェクトの種類を指定
                            ).copyWith(
                              elevation: MaterialStateProperty.resolveWith<double?>(
                                    (states) =>
                                states.contains(MaterialState.pressed) ? 0 : 2, // 押している間は影0、それ以外は影2
                              ),
                            ),
                            child: const Text(
                              "退会", // ボタンラベル
                              style: TextStyle(
                                color: Colors.black, // 文字色黒
                                fontWeight: FontWeight.bold, // 太字
                              ),
                            ),
                          ),

                          // --- お問い合わせボタン ---
                          ElevatedButton(
                            onPressed: () { // ContactScreenへの遷移処理
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ContactScreen()), // お問い合わせ画面へPush遷移
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // 背景色を白に設定
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // 角を8px丸くする
                              ),
                              overlayColor: Colors.black54.withOpacity(0.08), // 押下時の波紋色
                              splashFactory: InkRipple.splashFactory, // リップルエフェクト
                            ).copyWith(
                              elevation: MaterialStateProperty.resolveWith<double?>(
                                    (states) =>
                                states.contains(MaterialState.pressed) ? 0 : 2, // 押下中は影0、それ以外は2
                              ),
                            ),
                            child: const Text(
                              "お問い合わせ", // ボタンラベル
                              style: TextStyle(
                                color: Colors.black, // テキスト色黒
                                fontWeight: FontWeight.bold, // 太字
                              ),
                            ),
                          ),

                          // --- 利用規約ボタン ---
                          ElevatedButton(
                            onPressed: () { // TermsScreenへの遷移処理
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const TermsScreen()), // 利用規約画面へPush遷移
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // 背景色を白に設定
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // 角丸ボタン
                              ),
                              overlayColor: Colors.black54.withOpacity(0.08), // 押下時の波紋色
                              splashFactory: InkRipple.splashFactory, // リップルエフェクト
                            ).copyWith(
                              elevation: MaterialStateProperty.resolveWith<double?>(
                                    (states) =>
                                states.contains(MaterialState.pressed) ? 0 : 2, // 押下中は影を消す
                              ),
                            ),
                            child: const Text(
                              "利用規約", // ボタンラベル
                              style: TextStyle(
                                color: Colors.black, // テキスト色黒
                                fontWeight: FontWeight.bold, // 太字
                              ),
                            ),
                          ),
                        ],
                      ),
                      // （必要なら「何する？」テキストはここに戻せます）
                      // const SizedBox(height: 400),
                      // const Text(
                      //   '何する？',
                      //   style: TextStyle(
                      //     fontSize: 50,
                      //     fontWeight: FontWeight.w700,
                      //     color: Colors.white,
                      //     letterSpacing: 0.5,
                      //   ),
                      // ),
                      const SizedBox(height: 50), // 下方向の余白
                    ],
                  ),
                ),
              ),
            ),

            // ================================
            // 🟩 画面下部のブランドカラーバー
            // ================================
            Positioned(
              left: 0, // 画面左端から
              right: 0, // 画面右端まで
              bottom: 0, // 画面最下部に固定
              height: 60, // バーの高さ（背景画像の bottom と同じ値にする）
              child: Container(
                color: const Color(0xFF93B5A5), // HMLMブランドカラーのバー
              ),
            ),
          ],
        )
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリの「設定画面（SettingScreen）」を実装している。
// 主な役割は以下の通り。
// 1. アカウント退会フロー：
//    - users/{uid} のFirestoreドキュメント削除
//    - FirebaseAuthユーザー削除
//    - requires-recent-loginエラー時の再ログイン促し
//    - ローディングダイアログとSnackBarによるユーザーへの状態通知。
// 2. サポート・法務導線：
//    - 「お問い合わせ」ボタンからContactScreenへ遷移
//    - 「利用規約」ボタンからTermsScreenへ遷移
// 3. UI構成：
//    - AppBarにブランドカラー(#93B5A5)とぼかし効果(BackdropFilter)を適用。
//    - bodyをStack構造にし、HMLM_UP.pngを背景として画面下のブランドバー手前まで表示。
//    - 背景画像の上に、「退会 / お問い合わせ / 利用規約」のボタン群を重ねて表示。
//    - 画面最下部にはブランドカラー(#93B5A5)のバーを配置し、全体の統一感を高めている。
// 4. デザイン意図：
//    - Belugaイラストを背景として使いながら、下部にブランドカラーバーを設けることで、
//      HMLMらしい世界観とUIのまとまりを両立した設定ハブ画面として構成している。
