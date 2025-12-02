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
import '../prelogin_screen.dart';
import 'edit_profile_screen.dart'; // プロフィール編集画面をインポート

class ProfileScreen extends StatefulWidget { // プロフィール画面を定義するStatefulWidgetクラス
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState(); // 状態管理用のStateを作成
}

class _ProfileScreenState extends State<ProfileScreen> { // プロフィール画面の状態を管理するクラス
  bool isLoading = false; // サインアウト中などの処理中状態を管理
  StreamSubscription<User?>? _authSub; // FirebaseAuthの状態変化を監視する購読ストリーム

  setIsLoading(bool value) { // ローディング状態を更新する関数
    setState(() {
      isLoading = value;
    });
  }

  @override
  void initState() { // 初期化処理。画面生成時に一度だけ呼ばれる。
    super.initState();
    // サインイン/アウトのたびに再描画＆ユーザードキュメントの整備
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async { // 認証状態の変化を監視
      if (!mounted) return; // ウィジェットが破棄済みなら何もしない
      setState(() {}); // サインイン状態変化時にUIを再描画
      if (user != null) { // ユーザーがサインイン済みなら
        await _ensureAppUserDocument(user); // Firestore上にユーザーデータを用意（無ければ作成）
      }
    });
  }

  @override
  void dispose() { // 破棄時処理
    _authSub?.cancel(); // FirebaseAuthのリスナーを解除
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { // 画面のUIを構築
    final currentUser = FirebaseAuth.instance.currentUser; // 現在のサインインユーザーを取得
    return Scaffold( // Materialデザインの基本構造
      // -----------------------------
      // 🎨 背景色を「透明」に変更
      //     → 画面遷移アニメーション中に、
      //       Scaffold下地の「真っ白」がチラッと見える問題を防ぐ
      // -----------------------------
      backgroundColor: Colors
          .transparent, // ★ 以前: Colors.white → 透明にすることで「白い枠」のチラ見えを抑制
      appBar: AppBar( // 画面上部のバー
        title: const Text(
          'PROFILE', // 画面タイトル
          style: TextStyle(
            fontWeight: FontWeight.bold, // ← 太字を追加
            color: Colors.black, // ← 黒文字で視認性アップ
          ),
        ),
        backgroundColor: const Color(0xFF93B5A5), // ← AppBarを #93B5A5 に変更
        elevation: 4, // ← 軽いシャドウ
        surfaceTintColor: Colors.transparent, // ← M3の自動ティント無効化
        // ガラス風ぼかし（範囲はAppBar内に限定）
        flexibleSpace: ClipRect(
          child: BackdropFilter( // AppBar背景にぼかしを適用
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // ぼかし強度を設定
            child: Container(color: Colors.transparent), // 透明コンテナでぼかし効果のみ反映
          ),
        ),
      ),
      body: () { // body部分を即時関数で動的に生成
        // 1) 本当に未サインインの場合のみ LOGIN を出す
        if (currentUser == null) { // ログインしていない場合
          return SignInButton( // サインインボタンを表示
            onSignedIn: () async { // サインイン完了時の処理
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await _ensureAppUserDocument(user); // Firestoreにユーザー情報を登録
              }
              if (mounted) setState(() {}); // 画面再描画
            },
          );
        }
        // 2) サインイン済み：Firestore の doc を待つ間はローディングを出す
        return StreamBuilder<AppUser?>( // Firestore上のユーザーデータを購読
          stream: _fetchAppUser(), // ユーザードキュメントの購読ストリーム
          builder: (context, snapshot) {
            // ストリーム接続待ち・初回フェッチ中 → ローディング
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AppLoading()); // ローディングインジケータを表示
            }

            final appUser = snapshot.data; // Firestoreから取得したユーザーデータ
            // doc がまだ無い/未整備の瞬間もローディング（LOGINは出さない）
            if (appUser == null) {
              return const Center(child: AppLoading()); // ローディング継続
            }

            return Container(
              // -----------------------------
              // 🎨 ここで「中身の背景」を白に設定
              //     → 通常表示時は今まで通り白背景のプロフィール画面
              //     → 画面遷移アニメーション中の“下地”は透明なので
              //       「白い枠」が一瞬見える現象を抑えられる
              // -----------------------------
              color: Colors.white, // ★ 背景白はこのコンテンツ領域だけに限定
              padding: const EdgeInsets.all(20), // 全体に余白を設定
              child: Column(
                children: [
                  Container( // 右上に「EDIT PROFILE」ボタンを配置
                    height: 40,
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () { // 押下時にプロフィール編集画面へ遷移
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) {
                            return EditProfileScreen(
                              user: appUser, // 現在のユーザー情報を渡す
                            );
                          }),
                        );
                      },
                      child: const Text(
                        'EDIT PROFILE',
                        style: TextStyle(
                          color: Color(0xFF93B5A5), // ← 濃い緑に変更
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView( // 内容が多い場合にスクロール可能に
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar( // ユーザー画像を表示
                            radius: 100, // サイズ設定
                            backgroundColor: Colors.transparent, // 背景透明
                            backgroundImage: (appUser.imageUrl.isNotEmpty)
                                ? NetworkImage(appUser.imageUrl) // Firestore上の画像URLを使用
                                : null,
                            child: (appUser.imageUrl.isEmpty)
                                ? const Icon( // 画像がない場合の代替アイコン
                              Icons.person,
                              size: 64,
                              color: Color(0xFF93B5A5), // 濃い緑（DarkGreen）
                            )
                                : null,
                          ),
                          const SizedBox(height: 20),
                          Text( // ユーザー名を表示
                            appUser.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text( // プロフィール文を表示
                            appUser.profile,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton( // サインアウトボタン
                    onPressed: () => _signOut(context), // 押下でサインアウト処理
                    child: isLoading // ローディング状態に応じて切り替え
                        ? const AppLoading(
                        color: Colors
                            .blue) // ローディング中は青いインジケータ（※ここは元のまま）
                        : const Text(
                      'SIGN OUT', // 通常時のラベル
                      style: TextStyle(
                        color: Color(0xFF93B5A5), // ← 濃い緑に変更
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

  Stream<AppUser?> _fetchAppUser() { // Firestore上のユーザー情報をリアルタイム購読する関数
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // 未ログイン → ここは呼ばれない想定だが安全のため null を流す
      return Stream.value(null);
    }
    final ref =
    FirebaseFirestore.instance.collection('app_users').doc(user.uid); // 対象ユーザーのドキュメント参照を取得
    return ref.snapshots().map((snap) { // Firestoreの変更をリアルタイムで監視
      if (!snap.exists) return null; // ドキュメントが存在しない場合はnullを返す
      final data = snap.data();
      if (data == null) return null;
      return AppUser.fromDoc(
          snap.id, data as Map<String, dynamic>); // FirestoreデータをAppUserモデルに変換
    });
  }

  /// サインイン後に app_users/{uid} を用意する（無ければ作成・あれば軽く更新）
  Future<void> _ensureAppUserDocument(User user) async { // Firestore上にユーザードキュメントを作成・更新
    final ref =
    FirebaseFirestore.instance.collection('app_users').doc(user.uid); // 対象ユーザーのドキュメント参照を取得
    final snap = await ref.get(); // ドキュメントの存在確認
    if (!snap.exists) { // ドキュメントが存在しない場合 → 新規作成
      await ref.set({
        'name': user.displayName ?? '', // FirebaseAuth上のdisplayNameを使用（なければ空文字）
        'profile': '', // 初期プロフィールは空
        'image_url': user.photoURL ?? '', // FirebaseAuth上のphotoURLを使用（なければ空文字）
        'createdAt': FieldValue.serverTimestamp(), // 作成時刻をサーバー時刻で保存
        'updatedAt': FieldValue.serverTimestamp(), // 更新時刻も記録
      });
    } else { // 既に存在する場合 → 軽く更新
      await ref.set({
        'updatedAt': FieldValue.serverTimestamp(), // 更新時刻を上書き
        if (user.displayName != null)
          'name': user.displayName, // displayNameがある場合のみ更新
        if (user.photoURL != null)
          'image_url': user.photoURL, // 画像URLも同様に更新
      }, SetOptions(merge: true)); // 既存データにマージ（上書きしない）
    }
  }

  Future<void> _signOut(BuildContext context) async { // サインアウト処理を実行する関数
    try {
      setIsLoading(true); // ローディング開始
      await Future.delayed(
        const Duration(seconds: 1),
            () => FirebaseAuth.instance.signOut(), // 1秒後にサインアウト
      );
      if (context.mounted) { // ウィジェットがまだ有効か確認
        Navigator.of(context).pushReplacement( // ★ 前の画面に戻るのではなく、PreLogin画面に置き換えて遷移
          MaterialPageRoute(
            builder: (_) => const PreLoginScreen(), // ★ サインアウト後に表示する画面
          ),
        );
      }
    } catch (e) {
      print(e); // エラー出力
    } finally {
      setIsLoading(false); // ローディング終了
    }
  }
}

// =============================
// 🧩 このファイル全体の説明（変更後）
// =============================
// ・プロフィール画面の機能（サインイン状態監視、Firestore連携、プロフィール表示/編集、サインアウト）は元のまま。
// ・画面遷移時に「白い枠」が一瞬見える問題は、Scaffoldの背景色が純白だったことが原因と想定。
//   → Scaffold.backgroundColor を Colors.transparent に変更し、
//      通常表示時にだけ Container(color: Colors.white) でコンテンツ領域の背景を白にしている。
// ・これにより、ページ遷移アニメーションの境界で「下地の白」が出る現象を抑えつつ、
//   実際のプロフィール画面の見た目（中央コンテンツの白背景）は従来と同じまま維持している。
