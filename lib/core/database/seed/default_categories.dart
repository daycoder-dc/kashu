import 'package:flutter/material.dart' show Colors, Icons;

class SeedCategory {
  final String name;
  final int iconCodePoint;
  final int color;
  final int type;

  const SeedCategory({
    required this.name,
    required this.iconCodePoint,
    required this.color,
    required this.type,
  });
}

final List<SeedCategory> defaultExpenseCategories = [
  SeedCategory(name: 'Vivienda', iconCodePoint: Icons.home_rounded.codePoint, color: Colors.blue.toARGB32(), type: 0),
  SeedCategory(name: 'Alimentacion', iconCodePoint: Icons.restaurant_rounded.codePoint, color: Colors.orange.toARGB32(), type: 0),
  SeedCategory(name: 'Transporte', iconCodePoint: Icons.directions_car_rounded.codePoint, color: Colors.teal.toARGB32(), type: 0),
  SeedCategory(name: 'Salud', iconCodePoint: Icons.local_hospital_rounded.codePoint, color: Colors.red.toARGB32(), type: 0),
  SeedCategory(name: 'Educacion', iconCodePoint: Icons.school_rounded.codePoint, color: Colors.purple.toARGB32(), type: 0),
  SeedCategory(name: 'Entretenimiento', iconCodePoint: Icons.movie_rounded.codePoint, color: Colors.pink.toARGB32(), type: 0),
  SeedCategory(name: 'Servicios', iconCodePoint: Icons.receipt_long_rounded.codePoint, color: Colors.amber.toARGB32(), type: 0),
  SeedCategory(name: 'Deudas', iconCodePoint: Icons.credit_card_rounded.codePoint, color: Colors.deepOrange.toARGB32(), type: 0),
  SeedCategory(name: 'Otros gastos', iconCodePoint: Icons.more_horiz_rounded.codePoint, color: Colors.grey.toARGB32(), type: 0),
];

final List<SeedCategory> defaultIncomeCategories = [
  SeedCategory(name: 'Salario', iconCodePoint: Icons.payments_rounded.codePoint, color: Colors.green.toARGB32(), type: 1),
  SeedCategory(name: 'Freelance', iconCodePoint: Icons.laptop_rounded.codePoint, color: Colors.lightBlue.toARGB32(), type: 1),
  SeedCategory(name: 'Inversiones', iconCodePoint: Icons.trending_up_rounded.codePoint, color: Colors.indigo.toARGB32(), type: 1),
  SeedCategory(name: 'Otros ingresos', iconCodePoint: Icons.add_circle_outline_rounded.codePoint, color: Colors.lime.toARGB32(), type: 1),
];
