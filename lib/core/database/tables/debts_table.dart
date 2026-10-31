import 'package:drift/drift.dart';

import 'categories_table.dart';

class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  RealColumn get totalAmount => real()();
  RealColumn get interestRate => real()();
  IntColumn get totalInstallments => integer()();
  RealColumn get monthlyPayment => real()();
  DateTimeColumn get startDate => dateTime()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
