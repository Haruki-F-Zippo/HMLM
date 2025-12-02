import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'components/close_modal_button.dart';
import 'components/sign_in_form.dart';
import 'components/sign_up_form.dart';
import 'components/submit_button.dart'; // ★ 追加：サインインと同じSubmitButtonを使う

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
  String buttonLabel = '新規登録へ';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => unFocus(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        height: MediaQuery.of(context).size.height * 0.9,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CloseModalButton(),

              // ==========================
              // 🧩 サインイン or 新規登録フォーム
              // ==========================
              modalType == AuthModalType.signIn
              // ★ SignInForm に onSignedIn をそのまま渡す
                  ? SignInForm(onSignedIn: widget.onSignedIn)
                  : const SignUpForm(),

              // ==========================
              // 🔘 「新規登録へ / サインインへ」切り替えボタン
              //     → SubmitButton と同じUIに統一
              // ==========================
              const SizedBox(height: 10), // ← 少し下に配置したいので余白追加
              SubmitButton(
                labelName: buttonLabel, // ← 「新規登録へ」 or 「サインインへ」
                isLoading: false, // ← ここは画面切り替えだけなので常に false でOK
                onTap: switchModalType, // ← 押したらサインイン/新規登録を入れ替える
                backgroundColor: Colors.white, // ← サインインボタンと同じ配色
                textColor: const Color(0xFF93B5A5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void unFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  void switchModalType() {
    setState(() {
      if (modalType == AuthModalType.signIn) {
        modalType = AuthModalType.signUp;
        buttonLabel = 'サインインへ';
      } else {
        modalType = AuthModalType.signUp;
        buttonLabel = '新規登録へ';
      }
    });
  }
}
