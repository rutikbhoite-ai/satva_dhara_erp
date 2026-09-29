import 'package:firebase_core/firebase_core.dart';

/// This file is intentionally a safe placeholder for a brand-new project.
///
/// Run:
///   flutterfire configure
///
/// The FlutterFire CLI will replace this file with the real, platform-specific
/// Firebase configuration for your project. No credentials are invented here.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    throw UnsupportedError(
      'Firebase is not configured. Run "flutterfire configure" to generate '
      'lib/firebase_options.dart for this project.',
    );
  }
}
