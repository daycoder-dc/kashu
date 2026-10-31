import '../../../../core/error/either_typedefs.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  FutureEither<AppSettings> getSettings();
  FutureEither<void> updateCurrency(String currencyCode);
  FutureEither<void> updateThemeMode(String themeMode);
  FutureEither<double?> getBudget(int month, int year);
  FutureEither<void> setBudget(int month, int year, double amount);
}
