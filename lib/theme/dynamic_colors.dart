import 'package:flutter/material.dart';

class DynamicColors {
  static Color cardBg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white;

  static Color onCard(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? Colors.white
          : Theme.of(ctx).primaryColor;
}
