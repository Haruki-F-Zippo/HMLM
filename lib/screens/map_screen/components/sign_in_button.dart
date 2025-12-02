import 'dart:ui'; // ← ガラス風エフェクト用（BackdropFilter）
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/auth_modal/auth_modal.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({
    super.key,
    required this.onSignedIn, // ★ コンストラクタで受け取る
  });

  final Future<void> Function() onSignedIn; // ★ フィールドに保持

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ------------------------
        // 🖼 背景画像（全面）
        // ------------------------
        Positioned.fill(
          child: Image.asset(
            'assets/images/HMLM_LOGIN_BACK.png',
            fit: BoxFit.cover,
          ),
        ),

        // ------------------------
        // 🔘 オシャレ LOG IN ボタン
        // ------------------------
        Positioned(
          bottom: 40, // ← 少し余裕を持たせて上げる
          left: 0,
          right: 0,
          child: Center(
            child: _LoginGlassButton(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  builder: (BuildContext context) {
                    // ★ ここで AuthModal に onSignedIn を渡す
                    return AuthModal(onSignedIn: onSignedIn);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================
// 🌟 ガラス風・カプセル型 LOG IN ボタン
// =====================================
class _LoginGlassButton extends StatelessWidget {
  const _LoginGlassButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        // ← 背景をぼかしてガラスっぽくする
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.white.withOpacity(0.72), // ← 半透明の白
          elevation: 6, // ← ほどよい影
          shadowColor: Colors.black.withOpacity(0.25),
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _themeGreen,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    CupertinoIcons.lock_fill,
                    size: 20,
                    color: _themeGreen,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'LOG IN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 3, // ← 文字の間隔をあけてロゴ感UP
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
