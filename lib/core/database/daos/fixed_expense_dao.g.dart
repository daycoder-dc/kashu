// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_expense_dao.dart';

// ignore_for_file: type=lint
mixin _$FixedExpenseDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $FixedExpensesTable get fixedExpenses => attachedDatabase.fixedExpenses;
  $FixedExpensePaymentsTable get fixedExpensePayments =>
      attachedDatabase.fixedExpensePayments;
  FixedExpenseDaoManager get managers => FixedExpenseDaoManager(this);
}

class FixedExpenseDaoManager {
  final _$FixedExpenseDaoMixin _db;
  FixedExpenseDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$FixedExpensesTableTableManager get fixedExpenses =>
      $$FixedExpensesTableTableManager(_db.attachedDatabase, _db.fixedExpenses);
  $$FixedExpensePaymentsTableTableManager get fixedExpensePayments =>
      $$FixedExpensePaymentsTableTableManager(
        _db.attachedDatabase,
        _db.fixedExpensePayments,
      );
}
