import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/user_settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [UserSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(userSettings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String key, String value) {
    return into(userSettings).insert(
      UserSettingsCompanion.insert(key: key, value: value),
      onConflict: DoUpdate(
        (old) => UserSettingsCompanion(value: Value(value)),
        target: [userSettings.key],
      ),
    );
  }

  Future<int> deleteKey(String key) {
    return (delete(userSettings)..where((s) => s.key.equals(key))).go();
  }

  Future<Map<String, String>> getAll() async {
    final rows = await select(userSettings).get();
    return {for (final row in rows) row.key: row.value};
  }
}
