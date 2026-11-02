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
  Icons.shopping_cart_rounded,
  Icons.pets_rounded,
  Icons.fitness_center_rounded,
  Icons.wifi_rounded,
  Icons.phone_android_rounded,
  Icons.flight_rounded,
  Icons.local_cafe_rounded,
  Icons.child_care_rounded,
  Icons.brush_rounded,
  Icons.build_rounded,
  Icons.music_note_rounded,
  Icons.sports_esports_rounded,
];

final Map<int, IconData> _lookup = {
  for (final icon in _icons) icon.codePoint: icon,
};

IconData resolveIcon(int codePoint) {
  return _lookup[codePoint] ?? Icons.category_rounded;
}
