import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
import 'daos/category_dao.dart';
import 'daos/debt_dao.dart';
import 'daos/fixed_expense_dao.dart';
import 'daos/monthly_budget_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/transaction_dao.dart';
import 'seed/default_categories.dart';
import 'tables/categories_table.dart';
import 'tables/debt_payments_table.dart';
import 'tables/debts_table.dart';
import 'tables/fixed_expense_payments_table.dart';
import 'tables/fixed_expenses_table.dart';
import 'tables/monthly_budgets_table.dart';
import 'tables/transactions_table.dart';
import 'tables/user_settings_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    TransactionItems,
    Categories,
    MonthlyBudgets,
    UserSettings,
    FixedExpenses,
    FixedExpensePayments,
    Debts,
    DebtPayments,
  ],
  daos: [
    TransactionDao,
    CategoryDao,
    MonthlyBudgetDao,
    SettingsDao,
    FixedExpenseDao,
    DebtDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  factory AppDatabase({QueryExecutor? executor}) {
    return AppDatabase._internal(executor ?? _openConnection());
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaultCategories();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(fixedExpenses);
            await m.createTable(fixedExpensePayments);
          }
          if (from < 3) {
            await m.createTable(debts);
            await m.createTable(debtPayments);
          }
        },
      );

  Future<void> _seedDefaultCategories() async {
    final allSeeds = [
      ...defaultExpenseCategories,
      ...defaultIncomeCategories,
    ];
    final companions = allSeeds
        .map((s) => CategoriesCompanion.insert(
              name: s.name,
              iconCodePoint: s.iconCodePoint,
              color: s.color,
              type: s.type,
              isDefault: const Value(true),
            ))
        .toList();
    await batch((b) => b.insertAll(categories, companions));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
