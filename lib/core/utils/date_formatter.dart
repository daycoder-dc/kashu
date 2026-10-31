import 'package:intl/intl.dart';

class DateFormatter {
  static String fullDate(DateTime date) =>
      DateFormat("d 'de' MMMM 'de' yyyy", 'es').format(date);

  static String shortDate(DateTime date) =>
      DateFormat('d MMM', 'es').format(date);

  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy', 'es').format(date);

  static String monthName(DateTime date) =>
      DateFormat('MMMM', 'es').format(date);

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.month == b.month && a.year == b.year;
}
