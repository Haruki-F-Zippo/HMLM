import 'dart:ui'; // ぼかし効果（BackdropFilter等）に必要なUIライブラリ
import 'package:flutter/material.dart'; // Materialデザインのウィジェット群
import 'package:firebase_auth/firebase_auth.dart'; // Firebase認証（サインイン/削除等）
import 'package:cloud_firestore/cloud_firestore.dart'; // Cloud Firestore（DB操作）

// import 'map_screen.dart'; // ← もう使わないので削除
import 'prelogin_screen.dart'; // ★ 退会後/再ログイン誘導後に戻るログイン前画面
import 'term_screen.dart'; // 利用規約画面への遷移先
import 'contact_screen.dart'; // お問い合わせ画面への遷移先
import 'package:google_fonts/google_fonts.dart'; // ← ブランドフォント


class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Future<void> _deleteAccountAndData() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final user = auth.currentUser;

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログイン情報が見つかりませんでした。')),
      );
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    final uid = user.uid;

    // ローディングダイアログを表示
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Firestore users/{uid} を削除（失敗しても継続）
      await firestore.collection('users').doc(uid).delete().catchError((_) {});

      // Firebase Authユーザー削除
      await user.delete();

      // 念のため signOut
      await auth.signOut();

      // ローディングダイアログを閉じる
      if (navigator.canPop()) navigator.pop();

      // ★ 退会完了後：ログイン前トップ(PreLoginScreen)へ
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PreLoginScreen()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (navigator.canPop()) navigator.pop();

      if (!mounted) return;

      if (e.code == 'requires-recent-login') {
        // 直近ログインが必要な場合：いったんサインアウトして再ログインを促す
        await auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('安全のため再ログインが必要です。再ログイン後に退会を再実行してください。'),
          ),
        );

        // ★ 再ログイン導線として PreLoginScreen へ
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PreLoginScreen()),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('退会に失敗しました（${e.code}）')),
        );
      }
    } catch (e) {
      if (navigator.canPop()) navigator.pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('退会に失敗しました。しばらくしてからお試しください。')),
      );
    }
  }

  void _showWithdrawalDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("本当に退会しますか？"),
        content: const Text(
          '退会するとアカウントが削除されます。',
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
            height: 1.3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF93B5A5),
            ),
            child: const Text("キャンセル"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await _deleteAccountAndData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("退会"),
          ),
        ],
      ),
    );
  }

  void _onSend() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('送信（未実装）')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTING',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 3,
            color: Colors.black,
          ),
        ),
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 4,
        backgroundColor: const Color(0xFF93B5A5),
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 背景画像（下部バーの上まで）
          Positioned.fill(
            bottom: 60,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.10),
                BlendMode.screen,
              ),
              child: Image.asset(
                'assets/images/HMLM_UP.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // ボタン群
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 退会ボタン
                        ElevatedButton(
                          onPressed: _showWithdrawalDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            overlayColor:
                            Colors.black54.withOpacity(0.08),
                            splashFactory: InkRipple.splashFactory,
                          ).copyWith(
                            elevation:
                            MaterialStateProperty.resolveWith<double?>(
                                  (states) => states
                                  .contains(MaterialState.pressed)
                                  ? 0
                                  : 2,
                            ),
                          ),
                          child: const Text(
                            "退会",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // お問い合わせボタン
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ContactScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            overlayColor:
                            Colors.black54.withOpacity(0.08),
                            splashFactory: InkRipple.splashFactory,
                          ).copyWith(
                            elevation:
                            MaterialStateProperty.resolveWith<double?>(
                                  (states) => states
                                  .contains(MaterialState.pressed)
                                  ? 0
                                  : 2,
                            ),
                          ),
                          child: const Text(
                            "お問い合わせ",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // 利用規約ボタン
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TermsScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            overlayColor:
                            Colors.black54.withOpacity(0.08),
                            splashFactory: InkRipple.splashFactory,
                          ).copyWith(
                            elevation:
                            MaterialStateProperty.resolveWith<double?>(
                                  (states) => states
                                  .contains(MaterialState.pressed)
                                  ? 0
                                  : 2,
                            ),
                          ),
                          child: const Text(
                            "利用規約",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),

          // 画面下部のブランドカラーバー
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 60,
            child: Container(
              color: const Color(0xFF93B5A5),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// ・HMLMアプリの「設定画面」を定義。
// ・退会ボタンから Firestore users/{uid} と FirebaseAuthユーザーを削除し、
//   成功 / requires-recent-login どちらの場合も PreLoginScreen へ遷移させることで
//   2枚目スクショの「HMLMログイン前トップ」に必ず戻るようにしている。
// ・お問い合わせ/利用規約への導線や、背景画像＋下部ブランドバーのUI構成は元のまま。
