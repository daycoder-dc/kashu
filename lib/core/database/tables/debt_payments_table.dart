import 'package:drift/drift.dart';

import 'debts_table.dart';

@DataClassName('DebtPayment')
class DebtPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId => integer().references(Debts, #id)();
  IntColumn get installmentNumber => integer()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  RealColumn get amount => real()();
  BoolColumn get isPaid =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {debtId, installmentNumber}
      ];
}
