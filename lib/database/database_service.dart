import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

/// Native local database boundary.
///
/// Business models will be added in later phases. The database is deliberately
/// scoped by authenticated user + farm so the architecture does not fall back
/// to a shared local database.
class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Isar? _isar;
  String? _scopeKey;

  bool get isOpen => _isar?.isOpen ?? false;

  Future<Isar> openForScope({
    required String uid,
    required String farmId,
  }) async {
    if (kIsWeb) {
      throw UnsupportedError(
        'The native Isar database is not used on Web.',
      );
    }

    final cleanUid = uid.trim();
    final cleanFarmId = farmId.trim();

    if (cleanUid.isEmpty || cleanFarmId.isEmpty) {
      throw ArgumentError('Both uid and farmId are required.');
    }

    final scopeKey = _safeScopeKey(cleanUid, cleanFarmId);

    if (_isar?.isOpen == true && _scopeKey == scopeKey) {
      return _isar!;
    }

    await close();

    final directory = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      const [],
      name: scopeKey,
      directory: directory.path,
    );
    _scopeKey = scopeKey;

    return _isar!;
  }

  Future<void> close() async {
    if (_isar?.isOpen == true) {
      await _isar!.close();
    }
    _isar = null;
    _scopeKey = null;
  }

  String _safeScopeKey(String uid, String farmId) {
    final raw = 'sd_$uid' '_' '$farmId'.toLowerCase();
    final sanitized = raw.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    return sanitized.length <= 40 ? sanitized : sanitized.substring(0, 40);
  }
}
