import 'package:drift/drift.dart';

import 'fixed_expenses_table.dart';

@DataClassName('FixedExpensePayment')
class FixedExpensePayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixedExpenseId =>
      integer().references(FixedExpenses, #id)();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  BoolColumn get isPaid =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {fixedExpenseId, month, year}
      ];
}
