import 'package:flutter_test/flutter_test.dart';

import 'package:satva_dhara_erp/app/theme/app_theme.dart';

void main() {
  test('Satva Dhara theme uses Material 3', () {
    expect(AppTheme.lightTheme.useMaterial3, isTrue);
  });
}
