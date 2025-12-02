import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットを使用するためのパッケージをインポート
import 'package:firebase_auth/firebase_auth.dart'; // ★ 現在のログインユーザー情報を取得するためのFirebaseAuthをインポート
import 'package:cloud_firestore/cloud_firestore.dart'; // ★ Firestoreからユーザーの画像URL(app_users.image_url)を取得するためのパッケージをインポート
import '../profile_screen/profile_screen.dart'; // プロフィール画面のウィジェットをインポート

class ProfileButton extends StatelessWidget { // プロフィール画面へ遷移するためのボタンを定義するStatelessWidgetクラス
  const ProfileButton({ // コンストラクタ（キーとコールバック関数を受け取る）
    super.key,
    required this.onPressed, // ボタン押下時の処理を受け取る（必須）
  });

  final VoidCallback onPressed; // ボタン押下時に実行されるコールバック関数

  @override
  Widget build(BuildContext context) { // ウィジェットのUIを構築するbuildメソッド
    final user = FirebaseAuth.instance.currentUser; // ★ 現在サインインしているFirebase Authユーザーを取得

    // ================================
    // 👤 未ログインの場合：従来通りの人アイコンを表示
    // ================================
    if (user == null) { // サインインユーザーがいない場合
      return FloatingActionButton( // 画面上に浮かぶ円形ボタンを定義
        onPressed: () => Navigator.of(context).push( // 押下時に新しい画面（ProfileScreen）へ遷移
          MaterialPageRoute( // 新しいページへのルートを作成
            builder: (context) => const ProfileScreen(), // 遷移先はProfileScreen（プロフィール画面）
          ),
        ),
        backgroundColor: Colors.white, // ボタン背景色を白に設定
        child: const Icon( // ボタン内に表示するアイコン
          Icons.person, // 人型のプロフィールアイコン
          color: Colors.grey, // アイコンの色をグレーに設定
        ),
      );
    }

    // ================================
    // 🖼 ログイン済みの場合：app_users/{uid}.image_url を購読してアイコンを切り替える
    // ================================
    final docRef = FirebaseFirestore.instance // Firestoreインスタンスから
        .collection('app_users') // app_users コレクションを参照し
        .doc(user.uid); // 現在ユーザー(uid)のドキュメントを参照

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>( // ★ image_url をリアルタイム購読するためのStreamBuilder
      stream: docRef.snapshots(), // app_users/{uid} の変更を監視
      builder: (context, snapshot) {
        String? imageUrl; // 表示する画像URL用のローカル変数

        if (snapshot.hasData && snapshot.data!.data() != null) { // ドキュメントが存在しデータが取得できた場合
          final data = snapshot.data!.data()!; // Map<String, dynamic> 型としてデータを取得
          final dynamicUrl = data['image_url']; // image_url フィールドを取り出す
          if (dynamicUrl is String && dynamicUrl.isNotEmpty) { // Stringかつ空でないかを確認
            imageUrl = dynamicUrl; // 有効なURLとして保持
          }
        }

        return FloatingActionButton( // 画面上に浮かぶ円形ボタンを定義
          onPressed: () => Navigator.of(context).push( // 押下時に新しい画面（ProfileScreen）へ遷移
            MaterialPageRoute( // 新しいページへのルートを作成
              builder: (context) => const ProfileScreen(), // 遷移先はProfileScreen（プロフィール画面）
            ),
          ),
          backgroundColor: Colors.white, // FABの背景色を白に設定（従来と同じ）
          child: (imageUrl != null) // ★ 画像URLが存在するかどうかで表示を切り替える
              ? ClipOval( // 画像を円形に切り抜く
            child: Image.network(
              imageUrl, // Firestoreに保存されているプロフィール画像URL
              width: 40, // FAB内に収まるよう横幅を指定
              height: 40, // FAB内に収まるよう縦幅を指定
              fit: BoxFit.cover, // 画像の縦横比を保ちつつ円内をしっかり埋める
            ),
          )
              : const Icon( // 画像URLが無い場合は従来通り人アイコンを使用
            Icons.person, // 人型のプロフィールアイコン
            color: Colors.grey, // アイコンの色をグレーに設定
          ),
        );
      },
    );
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリ内でプロフィール画面への遷移を行う「ProfileButton」ウィジェットを定義している。
// ・FirebaseAuthから現在サインイン中のユーザー情報を取得し、
//   Firestoreの「app_users/{uid}」ドキュメントをStreamBuilderでリアルタイム購読する。
// ・ドキュメント内の image_url フィールドが空でなければ、
//   FloatingActionButton 内にその画像を円形(ClipOval + Image.network)で表示する。
// ・image_url が未設定の場合は、これまで通り Icons.person の人型アイコンを表示する。
// ・ボタンを押下すると ProfileScreen へ遷移し、プロフィール詳細を確認・編集できる。
// これにより、EditProfileScreen でギャラリーから画像を設定 → image_url 更新 →
// ProfileScreen のアイコンだけでなく、この ProfileButton のアイコンも同じ画像に同期して表示される。
