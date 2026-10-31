enum TransactionType {
  expense(0, 'Gasto'),
  income(1, 'Ingreso');

  const TransactionType(this.value, this.label);

  final int value;
  final String label;

  static TransactionType fromValue(int value) {
    return TransactionType.values.firstWhere((e) => e.value == value);
  }
}
