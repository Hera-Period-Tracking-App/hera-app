import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';

final cyclesProvider = StreamProvider<List<CycleSummary>>(
  (ref) => ref.watch(cycleRepositoryProvider).watchSummaries(),
);
