import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../components/app_loading.dart';

class SignOutButton extends StatelessWidget {
  const SignOutButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: isLoading ? const AppLoading() : const Icon(Icons.logout),
    );
  }
}