import 'package:cloud_firestore/cloud_firestore.dart'; // Firebaseのクラウドデータベース（Firestore）を使用するためのパッケージをインポート
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authenticationを使用するためのパッケージをインポート
import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのMaterialデザインウィジェットを使用するためのパッケージをインポート
import 'package:geolocator/geolocator.dart'; // 位置情報を取得するためのパッケージをインポート
import 'package:googlemap_api/components/auth_modal/components/submit_button.dart'; // 共通の送信ボタン（SubmitButton）コンポーネントをインポート
import 'animated_error_message.dart'; // アニメーション付きのエラーメッセージ表示用コンポーネントをインポート
import 'auth_modal_image.dart'; // 認証モーダルで使用する画像ウィジェットをインポート
import 'auth_text_form_field.dart'; // 認証フォーム用のテキスト入力フィールドをインポート

class SignUpForm extends StatefulWidget { // 新規登録フォームを定義するStatefulWidgetクラス
  const SignUpForm({
    super.key,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState(); // Stateクラスを生成して返す
}

class _SignUpFormState extends State<SignUpForm> { // 新規登録フォームの状態を管理するクラス
  final TextEditingController _emailController = TextEditingController(); // メールアドレス入力を管理するコントローラ
  final TextEditingController _passwordController = TextEditingController(); // パスワード入力を管理するコントローラ
  final _formKey = GlobalKey<FormState>(); // フォーム全体の状態を管理するキー
  String errorMessage = ''; // エラーメッセージを格納する変数
  bool isLoading = false; // ローディング状態を示すフラグ

  @override
  void dispose() { // ウィジェット破棄時に呼ばれる処理
    _emailController.dispose(); // メール入力コントローラを破棄
    _passwordController.dispose(); // パスワード入力コントローラを破棄
    super.dispose(); // 親クラスのdisposeを呼び出す
  }

  // ---------  Validation ---------
  String? validateEmail(String? value) { // メールアドレス入力のバリデーション処理
    if (value == null || value.isEmpty) { // 入力が空の場合
      return 'Please enter some text'; // エラーメッセージを返す
    }
    return null; // 問題なければnull（エラーなし）
  }

  String? validatePassword(String? value) { // パスワード入力のバリデーション処理
    if (value == null || value.isEmpty) { // 入力が空の場合
      return 'Please enter some text'; // エラーメッセージを返す
    }
    return null; // 問題なければnull（エラーなし）
  }

  String? validateConfirmPassword(String? value) { // パスワード確認入力のバリデーション処理
    if (value == null || value.isEmpty) { // 入力が空の場合
      return 'Please enter some text'; // エラーメッセージを返す
    }
    if (value != _passwordController.text) { // 確認用パスワードが一致しない場合
      return 'Password does not match'; // 一致しないエラーメッセージを返す
    }
    return null; // 問題なければnull
  }

  // ---------  StateChanges ---------
  void _setErrorMessage(String message) { // エラーメッセージを設定する関数
    setState(() {
      errorMessage = message; // 新しいメッセージを反映
    });
  }

  void _clearErrorMessage() { // エラーメッセージをクリアする関数
    setState(() {
      errorMessage = ''; // メッセージを空にする
    });
  }

  void _setIsLoading(bool value) { // ローディング状態を設定する関数
    setState(() {
      isLoading = value; // trueでローディング中、falseで完了
    });
  }

  @override
  Widget build(BuildContext context) { // UIを構築するbuildメソッド
    return Form( // 入力フォーム全体を定義
      key: _formKey, // フォームの状態を管理
      child: Column( // 縦方向にウィジェットを並べる
        children: [
          const Text( // フォーム上部に表示される説明文
            'メールとパスワードを入力して\n「新規登録」を押しなさい',
            style: TextStyle(
              fontSize: 18.0, // 文字サイズを22に設定
              fontWeight: FontWeight.bold, // 太字に設定
            ),
          ),
          const SizedBox(height: 1.0), // テキストと画像の間に余白を設定
          const AuthModalImage(), // モーダル用画像（ベルーガなど）を表示
          AnimatedErrorMessage(errorMessage: errorMessage), // エラーメッセージをアニメーション付きで表示
          const SizedBox(height: 1.0), // 余白を追加
          AuthTextFormField( // メールアドレス入力フィールド
            controller: _emailController, // 入力内容を管理するコントローラ
            onChanged: (value) => _clearErrorMessage(), // 入力中にエラーメッセージをクリア
            validator: validateEmail, // バリデーションロジックを設定
            labelText: 'Email', // フィールドラベルを設定
          ),
          const SizedBox(height: 10.0), // 余白を追加
          AuthTextFormField( // パスワード入力フィールド
            controller: _passwordController, // 入力内容を管理するコントローラ
            obscureText: true, // 入力内容を非表示（パスワード用）
            onChanged: (value) => _clearErrorMessage(), // 入力時にエラーメッセージをクリア
            validator: validatePassword, // バリデーションロジックを設定
            labelText: 'Password', // フィールドラベルを設定
          ),
          const SizedBox(height: 10.0), // 余白を追加
          AuthTextFormField( // パスワード確認入力フィールド
            obscureText: true, // 入力内容を非表示（パスワード確認用）
            onChanged: (value) => _clearErrorMessage(), // 入力時にエラーメッセージをクリア
            validator: validateConfirmPassword, // パスワード一致確認ロジックを設定
            labelText: 'Confirm Password', // フィールドラベルを設定
          ),
          const SizedBox(height: 20.0), // フィールドとボタンの間に余白を追加
          SubmitButton( // 新規登録ボタン
            labelName: '新規登録', // ボタン上に表示する文字
            isLoading: isLoading, // ローディング状態を反映
            onTap: () => _submit(context), // タップ時にサインアップ処理を実行
            backgroundColor: Colors.white, // ボタン背景色（白）
            textColor: const Color(0xFF93B5A5), // テキストカラー（HMLMテーマカラー）
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async { // 「新規登録」ボタン押下時の処理
    if (_formKey.currentState!.validate()) { // フォームの入力が有効な場合
      // サインアップ処理
      final UserCredential? user = await signUp( // FirebaseAuthで新規ユーザー登録
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 500ミリ秒待って、モーダルを閉じる
      if (user != null) { // 登録成功時
        await createAppUser(user.user!.uid); // Firestoreにユーザーデータを作成
        if (!mounted) return; // 画面が破棄されていたら終了

        // ★ 追加：SnackBarで一時的な通知を表示
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                '新規登録が完了しました。\n登録したアカウントでサインインしてください。',
              ),
              duration: Duration(seconds: 3), // 3秒間表示
            ),
          );

        // ★ 既存処理：0.5秒後にモーダルを閉じる
        Future.delayed(
          const Duration(milliseconds: 500), // 0.5秒後に実行
          Navigator.of(context).pop, // モーダルを閉じる
        );
      }
    }
  }

  // ---------  Sign Up ---------
  Future<UserCredential?> signUp({ // Firebaseによるユーザー登録処理
    required String email, // 入力されたメールアドレス
    required String password, // 入力されたパスワード
  }) async {
    try {
      _setIsLoading(true); // ローディング開始
      return await FirebaseAuth.instance.createUserWithEmailAndPassword( // Firebase Auth APIを呼び出して新規登録
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) { // Firebase認証時にエラーが発生した場合
      if (e.code == 'weak-password') { // パスワードが弱い場合
        _setErrorMessage('The password provided is too weak.'); // エラーメッセージを設定
      } else if (e.code == 'email-already-in-use') { // 既に登録されているメールアドレスの場合
        _setErrorMessage('The account already exists for that email.'); // エラーメッセージを設定
      } else { // その他の不明なエラー
        _setErrorMessage('Unidentified error occurred while signing up.'); // エラーメッセージを設定
      }
    } finally {
      _setIsLoading(false); // ローディング終了
    }
    return null; // 登録失敗時はnullを返す
  }

  Future<void> createAppUser(String userId) async { // Firestoreに新しいユーザー情報を作成する関数
    final Position position = await Geolocator.getCurrentPosition(); // 現在位置（緯度・経度）を取得
    final GeoPoint location = GeoPoint(position.latitude, position.longitude); // Firestore用の位置情報オブジェクトに変換

    await FirebaseFirestore.instance.collection('app_users').doc(userId).set({ // "app_users"コレクションに新規ドキュメントを作成
      'name': 'your name please!', // 初期値として名前フィールドを設定
      'profile': 'your profile please!', // 初期値としてプロフィールフィールドを設定
      'image_type': 'lion', // 初期値としてアバター種別を設定
      'location': location, // 現在位置情報を保存
    });
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリ内の「新規登録フォーム（SignUpForm）」を実装している。
// ユーザーがメールアドレスとパスワードを入力してFirebase Authenticationによりアカウントを作成する処理を提供。
// さらに、登録完了後にはFirestore上の「app_users」コレクションに初期ユーザーデータを保存し、現在地情報も登録する。
// エラーメッセージの表示、ローディング状態管理、フォームバリデーションなども含め、UIとロジックを一体化している。
// AuthModalImage・AuthTextFormField・SubmitButtonなどの共通UIコンポーネントを利用して統一感のある画面デザインを構築している。
