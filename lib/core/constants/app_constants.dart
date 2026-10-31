abstract class AppConstants {
  static const String appName = 'Kashu';
  static const String databaseName = 'kashu.sqlite';
  static const String defaultCurrencyCode = 'COP';
  static const String defaultLocale = 'es_CO';

  static const Map<String, CurrencyConfig> supportedCurrencies = {
    'COP': CurrencyConfig(code: 'COP', symbol: r'$', locale: 'es_CO', decimalDigits: 0),
    'USD': CurrencyConfig(code: 'USD', symbol: r'$', locale: 'en_US', decimalDigits: 2),
    'EUR': CurrencyConfig(code: 'EUR', symbol: '€', locale: 'es_ES', decimalDigits: 2),
    'MXN': CurrencyConfig(code: 'MXN', symbol: r'$', locale: 'es_MX', decimalDigits: 2),
  };
}

class CurrencyConfig {
  final String code;
  final String symbol;
  final String locale;
  final int decimalDigits;

  const CurrencyConfig({
    required this.code,
    required this.symbol,
    required this.locale,
    required this.decimalDigits,
  });
}
