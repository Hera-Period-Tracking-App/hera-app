import 'package:flutter/material.dart';

class CyclePhaseColors extends ThemeExtension<CyclePhaseColors> {
  const CyclePhaseColors({
    required this.luteal,
    required this.follicular,
    required this.ovulation,
    required this.menstrual,
  });

  final Color luteal;
  final Color follicular;
  final Color ovulation;
  final Color menstrual;

  @override
  CyclePhaseColors copyWith({
    Color? luteal,
    Color? follicular,
    Color? ovulation,
    Color? menstrual,
  }) {
    return CyclePhaseColors(
      luteal: luteal ?? this.luteal,
      follicular: follicular ?? this.follicular,
      ovulation: ovulation ?? this.ovulation,
      menstrual: menstrual ?? this.menstrual,
    );
  }

  @override
  CyclePhaseColors lerp(ThemeExtension<CyclePhaseColors>? other, double t) {
    if (other is! CyclePhaseColors) {
      return this;
    }

    return CyclePhaseColors(
      luteal: Color.lerp(luteal, other.luteal, t) ?? luteal,
      follicular: Color.lerp(follicular, other.follicular, t) ?? follicular,
      ovulation: Color.lerp(ovulation, other.ovulation, t) ?? ovulation,
      menstrual: Color.lerp(menstrual, other.menstrual, t) ?? menstrual,
    );
  }
}
