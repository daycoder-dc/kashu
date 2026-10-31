import 'package:drift/drift.dart';

import 'categories_table.dart';

class TransactionItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get concept => text().withLength(min: 1, max: 255)();
  RealColumn get amount => real()();
  IntColumn get type => integer()();
  BoolColumn get isPaid =>
      boolean().withDefault(const Constant(false))();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get date => dateTime()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
