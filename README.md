# googlemap_api

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase Crashlytics setup

Crashlytics has been wired into the Flutter app and Android Gradle plugins.
To complete production setup, run the following once in your environment:

1. Update Firebase app registration so IDs match this project:
   - Android `applicationId`: `jp.co.haruki.hmlm`
   - iOS `PRODUCT_BUNDLE_IDENTIFIER`: `com.example.hmlm.fh`
2. Download and replace:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
3. Run `flutterfire configure` to regenerate `lib/firebase_options.dart`.
4. Build release artifacts once so Crashlytics can process symbols.

The app now sends fatal Flutter and platform errors to Crashlytics at startup.
