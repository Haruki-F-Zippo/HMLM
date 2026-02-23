import 'dart:async'; // 非同期処理・ストリーム購読のために使用
import 'dart:ui'; // ← ぼかし（BackdropFilter）に必要
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestoreを操作するためのパッケージ
import 'package:firebase_auth/firebase_auth.dart'; // Firebase認証を扱うためのパッケージ
import 'package:flutter/cupertino.dart'; // iOSスタイルのUIコンポーネントを使用可能にする
import 'package:flutter/material.dart'; // MaterialデザインのUIコンポーネントを使用可能にする
import 'package:googlemap_api/screens/map_screen/components/sign_in_button.dart'; // サインインボタンウィジェットをインポート
import 'package:googlemap_api/screens/map_screen/prelogin_screen.dart'; // ★ サインアウト後に遷移するPreLogin画面をインポート
import '../../../components/app_loading.dart'; // 共通ローディングインジケータをインポート
import '../../../models/app_user.dart'; // Firestore上のユーザーデータモデルをインポート
import 'edit_profile_screen.dart'; // プロフィール編集画面をインポート
import 'package:google_fonts/google_fonts.dart'; // ★ HMLMブランドフォント（League Spartan）用

// =======================================
// PROFILE SCREEN
// - targetUserId が null   → 自分のプロフィール
// - targetUserId が 非null → 他人のプロフィール閲覧モード
// =======================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.targetUserId, // ← 追加：閲覧対象ユーザーID（null なら currentUser）
  });

  final String? targetUserId;

  bool get isSelf => targetUserId == null;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false; // サインアウト中などの処理中状態を管理
  StreamSubscription<User?>? _authSub; // FirebaseAuthの状態変化を監視する購読ストリーム

  void setIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  void initState() {
    super.initState();

    // 自分のプロフィール画面のときだけ auth 状態を監視
    if (widget.isSelf) {
      _authSub = FirebaseAuth.instance
          .authStateChanges()
          .listen((user) async {
        if (!mounted) return;
        setState(() {}); // サインイン状態変化時にUIを再描画
        if (user != null) {
          await _ensureAppUserDocument(user); // Firestore上にユーザーデータを用意（無ければ作成）
        }
      });
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // 閲覧対象ユーザーID（自分 or 他人）
    final viewingUid = widget.targetUserId ?? currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: GoogleFonts.leagueSpartan(
            fontWeight: FontWeight.w900, // ロゴっぽく極太
            fontSize: 22,
            letterSpacing: 3,           // 文字間を少し広げてブランド感アップ
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFF93B5A5),
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: () {
        // 1) 自分のプロフィール + 未サインイン → LOGIN を出す
        if (widget.isSelf && currentUser == null) {
          return SignInButton(
            onSignedIn: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await _ensureAppUserDocument(user);
              }
              if (mounted) setState(() {});
            },
          );
        }

        // 2) 閲覧対象ユーザーIDが取れない場合は何も出せない
        if (viewingUid == null) {
          return const Center(
            child: Text('ユーザー情報を取得できませんでした'),
          );
        }

        // 3) Firestore の doc をストリームで購読
        return StreamBuilder<AppUser?>(
          stream: _fetchAppUser(viewingUid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AppLoading());
            }

            final appUser = snapshot.data;
            if (appUser == null) {
              return const Center(child: AppLoading());
            }

            final isSelfProfile = widget.isSelf &&
                currentUser != null &&
                currentUser.uid == viewingUid;

            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 右上 EDIT PROFILE ボタン（自分のプロフィールのときだけ）
                  if (isSelfProfile)
                    Container(
                      height: 40,
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                user: appUser,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'EDIT PROFILE',
                          style: TextStyle(
                            color: Color(0xFF93B5A5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 40),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // プロフィール画像
                          CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.transparent,
                            backgroundImage: (appUser.imageUrl.isNotEmpty)
                                ? NetworkImage(appUser.imageUrl)
                                : null,
                            child: (appUser.imageUrl.isEmpty)
                                ? const Icon(
                              Icons.person,
                              size: 64,
                              color: Color(0xFF93B5A5),
                            )
                                : null,
                          ),
                          const SizedBox(height: 20),
                          // ユーザー名
                          Text(
                            appUser.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // プロフィール文
                          Text(
                            appUser.profile,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // SIGN OUT ボタン（自分のプロフィールのときだけ）
                  if (isSelfProfile)
                    TextButton(
                      onPressed: () => _signOut(context),
                      child: isLoading
                          ? const AppLoading(color: Colors.blue)
                          : const Text(
                        'SIGN OUT',
                        style: TextStyle(
                          color: Color(0xFF93B5A5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }(),
    );
  }

  // 対象ユーザーの AppUser を購読
  Stream<AppUser?> _fetchAppUser(String uid) {
    final ref =
    FirebaseFirestore.instance.collection('app_users').doc(uid);
    return ref.snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data();
      if (data == null) return null;
      return AppUser.fromDoc(
        snap.id,
        data as Map<String, dynamic>,
      );
    });
  }

  /// サインイン後に app_users/{uid} を用意する（無ければ作成・あれば軽く更新）
  Future<void> _ensureAppUserDocument(User user) async {
    final ref =
    FirebaseFirestore.instance.collection('app_users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': user.displayName ?? '',
        'profile': '',
        'image_url': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.set({
        'updatedAt': FieldValue.serverTimestamp(),
        if (user.displayName != null) 'name': user.displayName,
        if (user.photoURL != null) 'image_url': user.photoURL,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      setIsLoading(true);

      // 少し待ってからサインアウト
      await Future.delayed(
        const Duration(seconds: 1),
            () => FirebaseAuth.instance.signOut(),
      );

      if (context.mounted) {
        // =========================================
        // 🚪 画面全体がフワッと切り替わるフェード遷移
        // =========================================
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const PreLoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // 0.0 → 1.0 へイージングしながらフェードイン
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              );
              return FadeTransition(
                opacity: curved,
                child: child,
              );
            },
            transitionDuration:
            const Duration(milliseconds: 400), // お好みで調整
          ),
        );
      }
    } catch (e) {
      print(e);
    } finally {
      setIsLoading(false);
    }
  }
}

// =============================
// 🧩 このファイル全体の説明（変更後）
// =============================
// ・_signOut 内の画面遷移を MaterialPageRoute → PageRouteBuilder に変更。
// ・transitionsBuilder で FadeTransition を使い、
//   PROFILE → PreLoginScreen への遷移をスライドではなく
//   「画面全体がフワッと切り替わる」フェードアニメーションにしている。
// ・pushReplacement を使っているので、戻るボタンで PROFILE に戻れないように
//   これまで同様ルートを差し替えている。
