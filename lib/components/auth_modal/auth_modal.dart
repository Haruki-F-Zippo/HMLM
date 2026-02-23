import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'components/close_modal_button.dart';
import 'components/sign_in_form.dart';
import 'components/sign_up_form.dart';
import 'components/submit_button.dart'; // ★ サインインと同じSubmitButtonを使う

enum AuthModalType {
  signIn,
  signUp;
}

class AuthModal extends StatefulWidget {
  const AuthModal({
    super.key,
    this.onSignedIn, // ★ サインイン成功時のコールバックを受け取る
  });

  final Future<void> Function()? onSignedIn; // ★ SignInForm に渡すためのフィールド

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  AuthModalType modalType = AuthModalType.signIn;

  @override
  Widget build(BuildContext context) {
    // 👇 キーボードの高さ（0〜数百px）
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => unFocus(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        height: MediaQuery.of(context).size.height * 0.9,
        child: SingleChildScrollView(
          // 👇 キーボードの分だけ下に余白を足して、被らないようにする
          padding: EdgeInsets.only(bottom: bottomInset + 16),
          child: Column(
            children: [
              const CloseModalButton(),

              // ==========================
              // 🧩 サインイン or 新規登録フォーム
              // ==========================
              modalType == AuthModalType.signIn
                  ? SignInForm(onSignedIn: widget.onSignedIn)
                  : const SignUpForm(),

              // ==========================
              // 🔘 「新規登録へ」切り替えボタン
              //     → サインイン画面のときだけ表示
              // ==========================
              if (modalType == AuthModalType.signIn) ...[
                const SizedBox(height: 10),
                SubmitButton(
                  labelName: '新規登録へ', // ← ラベル固定
                  isLoading: false,
                  onTap: switchToSignUp, // ← 押したら一方通行で signUp へ
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF93B5A5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void unFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // サインイン画面 → 新規登録画面 への一方通行切り替え
  void switchToSignUp() {
    setState(() {
      modalType = AuthModalType.signUp;
    });
  }
}
