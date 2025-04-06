import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../profile_screen/profile_screen.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    super.key,
    required this.onPressed
  });
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      ),
      child: const Icon(Icons.person),
    );
  }
}