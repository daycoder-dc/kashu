import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';

import '../database/app_database.dart';
import '../database/daos/category_dao.dart';
import '../database/daos/debt_dao.dart';
import '../database/daos/fixed_expense_dao.dart';
import '../database/daos/monthly_budget_dao.dart';
import '../database/daos/settings_dao.dart';
import '../database/daos/transaction_dao.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/dashboard/data/datasources/dashboard_local_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_monthly_summary.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../features/statistics/data/datasources/statistics_local_datasource.dart';
import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../../features/statistics/domain/repositories/statistics_repository.dart';
import '../../features/statistics/domain/usecases/get_category_breakdown.dart';
import '../../features/statistics/presentation/cubit/statistics_cubit.dart';
import '../../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../../features/transactions/domain/repositories/transaction_repository.dart';
import '../../features/transactions/domain/usecases/create_transaction.dart';
import '../../features/transactions/domain/usecases/delete_transaction.dart';
import '../../features/transactions/domain/usecases/get_transactions_by_month.dart';
import '../../features/transactions/domain/usecases/update_transaction.dart';
import '../../features/debts/data/datasources/debt_local_datasource.dart';
import '../../features/debts/data/repositories/debt_repository_impl.dart';
import '../../features/debts/domain/repositories/debt_repository.dart';
import '../../features/debts/presentation/cubit/debts_cubit.dart';
import '../../features/fixed_expenses/data/datasources/fixed_expense_local_datasource.dart';
import '../../features/fixed_expenses/data/repositories/fixed_expense_repository_impl.dart';
import '../../features/fixed_expenses/domain/repositories/fixed_expense_repository.dart';
import '../../features/fixed_expenses/presentation/cubit/fixed_expenses_cubit.dart';
import '../../features/transactions/presentation/cubit/transaction_form_cubit.dart';
import '../../features/transactions/presentation/cubit/transaction_list_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => LocalAuthentication());

  // Database
  final database = AppDatabase();
  sl.registerSingleton<AppDatabase>(database);

  // DAOs
  sl.registerLazySingleton(() => TransactionDao(sl<AppDatabase>()));
  sl.registerLazySingleton(() => CategoryDao(sl<AppDatabase>()));
  sl.registerLazySingleton(() => MonthlyBudgetDao(sl<AppDatabase>()));
  sl.registerLazySingleton(() => SettingsDao(sl<AppDatabase>()));
  sl.registerLazySingleton(() => FixedExpenseDao(sl<AppDatabase>()));
  sl.registerLazySingleton(() => DebtDao(sl<AppDatabase>()));

  // Datasources
  sl.registerLazySingleton(() => TransactionLocalDatasource(
        transactionDao: sl(),
        categoryDao: sl(),
      ));
  sl.registerLazySingleton(() => DashboardLocalDatasource(
        transactionDao: sl(),
        budgetDao: sl(),
        fixedExpenseDao: sl(),
        debtDao: sl(),
      ));
  sl.registerLazySingleton(() => StatisticsLocalDatasource(
        transactionDao: sl(),
      ));
  sl.registerLazySingleton(() => SettingsLocalDatasource(
        settingsDao: sl(),
        budgetDao: sl(),
      ));
  sl.registerLazySingleton(() => FixedExpenseLocalDatasource(
        fixedExpenseDao: sl(),
        budgetDao: sl(),
      ));
  sl.registerLazySingleton(() => DebtLocalDatasource(
        debtDao: sl(),
      ));

  // Repositories
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localAuth: sl(), secureStorage: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<FixedExpenseRepository>(
    () => FixedExpenseRepositoryImpl(datasource: sl()),
  );
  sl.registerLazySingleton<DebtRepository>(
    () => DebtRepositoryImpl(datasource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => CreateTransaction(sl()));
  sl.registerLazySingleton(() => GetTransactionsByMonth(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => GetMonthlySummary(sl()));
  sl.registerLazySingleton(() => GetCategoryBreakdown(sl()));
  // Cubits (Factory = fresh instance each time, Singleton for global state)
  sl.registerLazySingleton(() => AuthCubit(repository: sl()));
  sl.registerFactory(() => TransactionListCubit(
        getTransactionsByMonth: sl(),
      ));
  sl.registerFactory(() => TransactionFormCubit(
        repository: sl(),
        createTransaction: sl(),
        updateTransaction: sl(),
        deleteTransaction: sl(),
      ));
  sl.registerLazySingleton(() => DashboardCubit(
        getMonthlySummary: sl(),
      ));
  sl.registerFactory(() => StatisticsCubit(
        getCategoryBreakdown: sl(),
      ));
  sl.registerLazySingleton(() => SettingsCubit(
        repository: sl(),
      ));
  sl.registerFactory(() => FixedExpensesCubit(
        repository: sl(),
      ));
  sl.registerFactory(() => DebtsCubit(
        repository: sl(),
      ));
}
