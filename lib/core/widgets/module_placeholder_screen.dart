import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../app/theme/app_colors.dart';
import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/localization/locale_provider.dart';

class ModulePlaceholderScreen extends ConsumerWidget {
  const ModulePlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.construction_outlined,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSettings = title == AppStrings.of(context).get('settings');

    return AppPage(
      title: title,
      subtitle: subtitle,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 34),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isSettings ? 'Workspace settings' : 'Foundation route ready',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSettings
                        ? 'Language is centralized here so the application can switch without changing the project architecture.'
                        : 'This module has a fixed place in the architecture. Its business logic will be implemented in the planned development phase rather than using sample or fake records.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (isSettings) ...[
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppStrings.of(context).get('language'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: Localizations.localeOf(context).languageCode,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.language_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'mr', child: Text('मराठी')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        ref.read(localeProvider.notifier).state = Locale(value);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
