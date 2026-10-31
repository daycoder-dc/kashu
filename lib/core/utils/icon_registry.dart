import 'package:flutter/material.dart';

const _icons = <IconData>[
  Icons.home_rounded,
  Icons.restaurant_rounded,
  Icons.directions_car_rounded,
  Icons.local_hospital_rounded,
  Icons.school_rounded,
  Icons.movie_rounded,
  Icons.receipt_long_rounded,
  Icons.credit_card_rounded,
  Icons.more_horiz_rounded,
  Icons.payments_rounded,
  Icons.laptop_rounded,
  Icons.trending_up_rounded,
  Icons.add_circle_outline_rounded,
  Icons.category_rounded,
];

final Map<int, IconData> _lookup = {
  for (final icon in _icons) icon.codePoint: icon,
};

IconData resolveIcon(int codePoint) {
  return _lookup[codePoint] ?? Icons.category_rounded;
}
