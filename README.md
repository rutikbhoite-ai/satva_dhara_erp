# Satva Dhara ERP — Phase 1 Foundation

Fresh-start foundation for the Satva Dhara Dairy Farm ERP.

## Fixed architecture

- Flutter + Dart
- Material 3
- Riverpod
- GoRouter
- Firebase Authentication / Firestore / Storage / Messaging
- Isar Community for native offline storage
- Responsive desktop/tablet/mobile UI
- Modular feature structure

## Current phase

Phase 1 establishes:

- Premium Satva Dhara branding
- Centralized design system
- Responsive application shell
- Routing foundation
- Localization foundation (English / Marathi / Hindi)
- Firebase bootstrap with a safe configuration placeholder
- Native Isar service boundary
- Modern dashboard and module navigation
- Basic automated smoke test

Business modules are intentionally not faked in this phase.

## Windows setup

1. Create the platform folders in a terminal from this project root:

```powershell
flutter create .
```

2. Get packages:

```powershell
flutter pub get
```

3. Configure Firebase when ready:

```powershell
flutterfire configure
```

This replaces `lib/firebase_options.dart` with your real project configuration.

4. Analyze and test:

```powershell
flutter analyze
flutter test
```

5. Run Windows:

```powershell
flutter run -d windows
```

## Important

Do not change the `lib` architecture casually. New features should fit the established structure rather than creating another parallel architecture.
