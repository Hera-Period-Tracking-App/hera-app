import 'package:hera_app/features/cycles/models/cycle_summary.dart';

CycleSummary? findCycleById(Iterable<CycleSummary> cycles, String? id) {
  if (id == null) return null;
  for (final cycle in cycles) {
    if (cycle.id == id) return cycle;
  }
  return null;
}

CycleSummary? currentOrEditedCycle(Iterable<CycleSummary> cycles, String? editedId) {
  return findCycleById(cycles, editedId) ?? (cycles.isEmpty ? null : cycles.first);
}
