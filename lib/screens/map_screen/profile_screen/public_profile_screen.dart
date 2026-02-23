// lib/screens/map_screen/profile_screen/public_profile_screen.dart
import 'package:flutter/material.dart';
import '../../../models/app_user.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  static const _themeGreen = Color(0xFF93B5A5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _themeGreen,
        title: const Text(
          'PROFILE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.transparent,
                backgroundImage: (user.imageUrl != null &&
                    user.imageUrl!.isNotEmpty)
                    ? NetworkImage(user.imageUrl!)
                    : null,
                child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                    ? const Icon(
                  Icons.person,
                  size: 64,
                  color: _themeGreen,
                )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user.name ?? 'HMLM USER',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              user.profile ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
