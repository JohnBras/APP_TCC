import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final double radius; // raio padrão de cards/containers
  final double gap; // espaçamento padrão vertical/horizontal
  final bool useRail; // se true, usa NavigationRail; senão, NavigationBar

  const AppTokens({
    required this.radius,
    required this.gap,
    required this.useRail,
  });

  @override
  AppTokens copyWith({double? radius, double? gap, bool? useRail}) {
    return AppTokens(
      radius: radius ?? this.radius,
      gap: gap ?? this.gap,
      useRail: useRail ?? this.useRail,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      radius: lerpDouble(radius, other.radius, t)!,
      gap: lerpDouble(gap, other.gap, t)!,
      useRail: t < 0.5 ? useRail : other.useRail,
    );
  }
}
