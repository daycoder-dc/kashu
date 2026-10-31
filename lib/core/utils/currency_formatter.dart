import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class CurrencyFormatter {
  final CurrencyConfig _config;
  late final NumberFormat _format;

  CurrencyFormatter({String currencyCode = AppConstants.defaultCurrencyCode})
      : _config = AppConstants.supportedCurrencies[currencyCode] ??
            AppConstants.supportedCurrencies[AppConstants.defaultCurrencyCode]! {
    _format = NumberFormat.currency(
      locale: _config.locale,
      symbol: _config.symbol,
      decimalDigits: _config.decimalDigits,
    );
  }

  String format(double amount) => _format.format(amount);

  String formatSigned(double amount, {required bool isExpense}) {
    final prefix = isExpense ? '-' : '+';
    return '$prefix${_format.format(amount.abs())}';
  }

  String get currencyCode => _config.code;
  String get currencySymbol => _config.symbol;
}
