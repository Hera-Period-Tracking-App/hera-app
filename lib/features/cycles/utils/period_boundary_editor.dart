import 'package:flutter/material.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';

sealed class PeriodBoundaryEditResult {
  const PeriodBoundaryEditResult();
}

class UpdatedPeriodBoundary extends PeriodBoundaryEditResult {
  const UpdatedPeriodBoundary({required this.startDate, required this.menstruationLength});
  final DateTime startDate;
  final int menstruationLength;
}

class InvalidPeriodBoundaryEdit extends PeriodBoundaryEditResult {
  const InvalidPeriodBoundaryEdit(this.message);
  final String message;
}

PeriodBoundaryEditResult editPeriodBoundary(
    {required DateTime selectedDate,
    required DateTime startDate,
    required int cycleLength,
    required int menstruationLength}) {
  final selected = DateUtils.dateOnly(selectedDate);
  final start = DateUtils.dateOnly(startDate);
  final offset = selected.difference(start).inDays;
  final lastOffset = menstruationLength - 1;
  if (offset == -1) return UpdatedPeriodBoundary(startDate: selected, menstruationLength: menstruationLength + 1);
  if (offset == 0 || offset == lastOffset) {
    if (menstruationLength == 1) return const InvalidPeriodBoundaryEdit('The period must have at least one day.');
    return UpdatedPeriodBoundary(
        startDate: offset == 0 ? start.add(const Duration(days: 1)) : start,
        menstruationLength: menstruationLength - 1);
  }
  if (offset == menstruationLength) {
    if (offset >= cycleLength || menstruationLength >= 14) {
      return const InvalidPeriodBoundaryEdit('Period length must stay within the cycle and 14 days.');
    }
    return UpdatedPeriodBoundary(startDate: start, menstruationLength: menstruationLength + 1);
  }
  if (offset > 0 && offset < lastOffset) {
    return const InvalidPeriodBoundaryEdit('Only the first or last period day can be removed.');
  }
  return const InvalidPeriodBoundaryEdit('Period length must stay within the cycle and 14 days.');
}

bool isEditablePeriodBoundary(
    {required CycleSummary cycle,
    required DateTime date,
    required DateTime startDate,
    required int? menstruationLength}) {
  if (cycle.cycleLength == null || menstruationLength == null) return false;
  final offset = DateUtils.dateOnly(date).difference(DateUtils.dateOnly(startDate)).inDays;
  return offset == -1 || offset == 0 || offset == menstruationLength - 1 || offset == menstruationLength;
}
