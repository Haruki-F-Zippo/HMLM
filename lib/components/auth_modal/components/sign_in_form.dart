import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authenticationを使用するためのパッケージをインポート
import 'package:flutter/cupertino.dart'; // iOSスタイルのウィジェットを使用するためのパッケージをインポート
import 'package:flutter/material.dart'; // FlutterのMaterialデザイン用ウィジェットを使用するためのパッケージをインポート
import 'package:googlemap_api/components/auth_modal/components/submit_button.dart'; // サインインボタンなどで使う共通SubmitButtonコンポーネントをインポート
import 'animated_error_message.dart'; // エラーメッセージ表示用コンポーネントをインポート
import 'auth_modal_image.dart'; // 認証画面で表示する画像ウィジェットをインポート
import 'auth_text_form_field.dart'; // 認証画面用の入力フォームコンポーネントをインポート

class SignInForm extends StatefulWidget { // サインイン画面のフォームを定義するStatefulWidgetクラス
  const SignInForm({ // コンストラクタ（キーとコールバックを受け取る）
    super.key,
    this.onSignedIn, // ★ サインイン成功時に呼ばれる任意コールバック
  });

  final Future<void> Function()? onSignedIn; // ★ 親から渡される「サインイン成功時の処理」（PreLogin の遷移など）

  @override
  State<SignInForm> createState() => _SignInFormState(); // Stateクラスを生成して返す
}

class _SignInFormState extends State<SignInForm> { // SignInFormの状態を管理するクラス
  final TextEditingController _emailController = TextEditingController(); // メールアドレス入力を管理するコントローラ
  final TextEditingController _passwordController = TextEditingController(); // パスワード入力を管理するコントローラ
  final _formKey = GlobalKey<FormState>(); // フォーム全体の状態を管理するキー
  String errorMessage = ''; // エラーメッセージ文字列を格納する変数
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

  // ---------  StateChanges ---------
  void _setErrorMessage(String message) { // エラーメッセージを設定する関数
    setState(() {
      errorMessage = message; // エラーメッセージを更新
    });
  }

  void _clearErrorMessage() { // エラーメッセージをクリアする関数
    setState(() {
      errorMessage = ''; // メッセージを空にする
    });
  }

  void _setIsLoading(bool value) { // ローディング状態を設定する関数
    setState(() {
      isLoading = value; // trueでロード中、falseで完了
    });
  }

  @override
  Widget build(BuildContext context) { // UIを構築するbuildメソッド
    return Container(
      color: const Color(0), // ← 背景色を #93B5A5 に（未設定の状態、コメントで意図を残している）
      child: Theme( // ★ このフォーム内だけ入力フィールドの色テーマを上書き
        data: Theme.of(context).copyWith(
          // 入力フィールドのデコレーション共通設定
          inputDecorationTheme: const InputDecorationTheme(
            // フォーカスされたときの下線色（デフォルトの青 → HMLMカラーに変更）
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color(0xFF93B5A5), // ★ フォーカス時のボーダー色
                width: 2.0,
              ),
            ),
            // ラベルが浮き上がったとき（フォーカス時など）の文字色
            floatingLabelStyle: TextStyle(
              color: Color(0xFF93B5A5), // ★ フォーカス時のラベル色もHMLMカラーに
            ),
          ),
          // テキストカーソルや選択範囲の色もブランドカラーに揃える
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0xFF93B5A5), // ★ カーソル色
            selectionColor: Color(0x5593B5A5), // ★ 選択範囲のハイライト色（半透明）
            selectionHandleColor: Color(0xFF93B5A5), // ★ つまみの色
          ),
        ),
        child: Form( // 入力フォーム全体を定義
          key: _formKey, // フォームの状態を管理
          child: Column( // 縦方向にウィジェットを並べる
            mainAxisAlignment: MainAxisAlignment.start, // ← フォーム全体を上寄せに配置
            children: [
              const Text( // 説明文を表示するテキスト（既存ユーザー向け案内のみ残す）
                '新規登録済みの方は作成したアカウントで「サインイン」をしなさい',
                style: TextStyle(
                  fontSize: 18.0, // 文字サイズを18に設定
                  fontWeight: FontWeight.bold, // 太字に設定
                ),
              ),
              const SizedBox(height: 1.0), // テキストと画像の間に少し余白を設定
              const AuthModalImage(), // ロゴやキャラクター画像を表示
              AnimatedErrorMessage(errorMessage: errorMessage), // エラーメッセージをアニメーション付きで表示
              const SizedBox(height: 1.0), // 余白を追加
              AuthTextFormField( // メールアドレス入力フィールド
                controller: _emailController, // 入力値を管理するコントローラを設定
                onChanged: (value) => _clearErrorMessage(), // 入力中にエラーメッセージをクリア
                validator: validateEmail, // 入力検証ロジックを設定
                labelText: 'E-mail', // フィールドラベルを設定
              ),
              const SizedBox(height: 10.0), // メールとパスワードの間に余白を追加
              AuthTextFormField( // パスワード入力フィールド
                controller: _passwordController, // 入力値を管理するコントローラを設定
                obscureText: true, // 入力内容を非表示（パスワード用）
                onChanged: (value) => _clearErrorMessage(), // 入力時にエラーメッセージをクリア
                validator: validatePassword, // 入力検証ロジックを設定
                labelText: 'Password', // フィールドラベルを設定
              ),
              const SizedBox(height: 12.0), // フィールドとボタンの間に余白を追加
              SubmitButton( // 送信ボタン（サインインボタン）
                labelName: 'サインイン', // ボタン上に表示するテキスト
                isLoading: isLoading, // ローディング状態を反映（押下中にインジケータ表示など）
                onTap: () => _submit(context), // タップ時にサインイン処理を実行
                backgroundColor: Colors.white, // ← ボタン背景色は白
                textColor: const Color(0xFF93B5A5), // ← 文字色をブランドカラーに設定
              ),

              // ================================
              // 🔻 サインインボタンの直下に配置した案内文
              // ================================
              const SizedBox(height: 15.0), // サインインボタンとの間の余白
              const Align( // 左寄せで文言を配置
                alignment: Alignment.centerLeft, // 親Columnの幅の中で左に寄せる
                child: Text(
                  '初めての方&アカウントを一度削除した方は「新規登録へ」',
                  style: TextStyle(
                    fontSize: 18.0, // 読みやすいサイズ
                    fontWeight: FontWeight.bold, // 太字で強調
                  ),
                  // textAlignは指定せず、左寄せ（デフォルト）のまま
                ),
              ),
              // ※ このテキストのすぐ下に、AuthModal側の「新規登録へ」ボタンが来る想定
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async { // サインインボタン押下時の処理
    if (_formKey.currentState!.validate()) { // フォームの入力が有効な場合
      // サインイン処理
      final UserCredential? user = await signIn( // FirebaseAuthでサインイン
        email: _emailController.text,
        password: _passwordController.text,
      );

      // 画面が破棄されている場合、後続処理を行わない
      if (!mounted) return;

      // サインイン成功時の処理
      if (user != null) {
        // 0.5秒待ってモーダルを閉じ、その後 onSignedIn を呼び出す
        Future.delayed(
          const Duration(milliseconds: 500), // 0.5秒後に実行
              () {
            Navigator.of(context).pop(); // モーダルを閉じる
            // ★ 親からコールバックが渡されていれば呼ぶ（PreLogin → MapScreen遷移など）
            if (widget.onSignedIn != null) {
              widget.onSignedIn!();
            }
          },
        );
      }
    }
  }

  // ---------  Sign In ---------
  Future<UserCredential?> signIn({ // Firebaseによるサインイン処理
    required String email, // 入力されたメールアドレス
    required String password, // 入力されたパスワード
  }) async {
    try {
      _setIsLoading(true); // ローディング開始
      return await FirebaseAuth.instance.signInWithEmailAndPassword( // Firebaseの認証APIを呼び出し
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) { // 認証エラー発生時の処理
      if (e.code == 'user-not-found') { // ユーザーが見つからない場合
        _setErrorMessage('No user found for that email.'); // エラーメッセージを設定
      } else if (e.code == 'wrong-password') { // パスワードが間違っている場合
        _setErrorMessage('Wrong password provided for that user.'); // エラーメッセージを設定
      } else { // その他のエラー（無効な資格情報など）
        _setErrorMessage('アカウントとパスワードが一致しないか、アカウントが存在しません。アカウントがない方は「新規登録」を実施してください。'); // エラーメッセージを設定
      }
    } finally {
      _setIsLoading(false); // ローディング終了
    }
    return null; // サインイン失敗時はnullを返す
  }
}

// =============================
// 🧩 このファイル全体の説明
// =============================
// このファイルは、HMLMアプリにおける「サインイン画面（ログイン画面）」のフォームを実装している。
// ・ユーザーがメールアドレスとパスワードを入力し、Firebase Authenticationを用いてログインする機能を提供する。
// ・入力バリデーション、エラーメッセージ表示（AnimatedErrorMessage）、ローディング状態管理をStateで制御している。
// ・上部には「新規登録済みの方」向けのサインイン案内を表示し、
//   サインインボタンの直下に「初めての方＆アカウントを一度削除した方は『新規登録へ』」という補足案内を、
//   左寄せ＆サインインボタンから少し余裕を持たせた余白で配置している。
// ・Themeウィジェットで inputDecorationTheme / textSelectionTheme を上書きすることで、
//   E-mail / Password入力欄のフォーカス時の下線色・ラベル色・カーソル色・選択範囲色を
//   ブランドカラー(#93B5A5)に統一している。
// ・AuthModalImage・AuthTextFormField・SubmitButtonといった共通コンポーネントを組み合わせてUIを構成し、
//   成功時にはモーダルを閉じた上で、親から渡された onSignedIn コールバックを実行することで、
//   PreLoginScreen など呼び出し元側で「サインイン成功後の画面遷移」を柔軟に制御できるようになっている。
