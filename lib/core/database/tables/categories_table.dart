import 'package:drift/drift.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get iconCodePoint => integer()();
  TextColumn get iconFontFamily =>
      text().withDefault(const Constant('MaterialIcons'))();
  IntColumn get color => integer()();
  IntColumn get type => integer()();
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
