import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app_bootstrap.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/localization/app_localizations.dart';
import 'app/localization/locale_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // `.env` is optional in the foundation phase.
  }

  var firebaseAvailable = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAvailable = true;
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  AppBootstrap.firebaseAvailable = firebaseAvailable;

  runApp(
    const ProviderScope(
      child: SatvaDharaApp(),
    ),
  );
}

class SatvaDharaApp extends ConsumerWidget {
  const SatvaDharaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Satva Dhara ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: AppStrings.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
