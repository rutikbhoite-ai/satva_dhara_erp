# Satva Dhara ERP — Fixed Phase 1 Structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── app_bootstrap.dart
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   └── locale_provider.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       ├── app_colors.dart
│       ├── app_radius.dart
│       ├── app_shadows.dart
│       ├── app_spacing.dart
│       └── app_theme.dart
│
├── core/
│   └── widgets/
│       ├── app_shell.dart
│       └── module_placeholder_screen.dart
│
├── database/
│   └── database_service.dart
│
├── services/
│   └── auth_service.dart
│
├── features/
│   ├── auth/
│   │   └── presentation/screens/auth_screen.dart
│   └── dashboard/
│       └── presentation/screens/dashboard_screen.dart
│
├── firebase_options.dart
└── main.dart
```

This is the starting structure. New business modules should be added inside their fixed feature folders rather than introducing parallel architectures.
