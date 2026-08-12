import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/core/theme/cycle_phase_colors.dart';
import 'package:hera_app/features/cyclePrediction/cycle_forecast.dart';
import 'package:hera_app/features/cyclePrediction/providers/cycle_prediction_provider.dart';
import 'package:hera_app/features/cycles/models/cycle_summary.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';

class CyclePredictionScreen extends ConsumerWidget {
  const CyclePredictionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycles = ref.watch(cyclesProvider);
    final forecast = ref.watch(upcomingCycleForecastProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictions'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: cycles.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Could not load cycle history: $error'),
          ),
          data: (cycleHistory) => forecast.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Could not create predictions: $error'),
            ),
            data: (value) => _PredictionContent(
              cycles: cycleHistory,
              forecast: value,
            ),
          ),
        ),
      ),
    );
  }
}

class _PredictionContent extends StatelessWidget {
  const _PredictionContent({required this.cycles, required this.forecast});

  final List<CycleSummary> cycles;
  final CycleForecast? forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prediction = forecast;
    if (cycles.isEmpty || prediction == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Add a cycle first to see predictions.'),
        ),
      );
    }

    final latestCycle = cycles.reduce(
      (latest, cycle) => cycle.startDate.isAfter(latest.startDate)
          ? cycle
          : latest,
    );
    final firstStart = _addCalendarDays(
      _dateOnly(latestCycle.startDate),
      prediction.cycleLength,
    );
    final predictions = List.generate(
      6,
      (index) => _addCalendarDays(
        firstStart,
        index * prediction.cycleLength,
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'These forecast settings are calculated from your saved previous cycles. Your latest cycle only sets the starting point for the first predicted date.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Predictions are estimates and may be inaccurate. They are not medical advice.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 2,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FORECAST SETTINGS',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Cycle length: ${prediction.cycleLength} days'),
                    Text(
                      'Menstruation length: ${prediction.menstruationLength} days',
                    ),
                    Text('Ovulation day: ${prediction.ovulationDay}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        for (final start in predictions)
          _PredictionCard(start: start, forecast: prediction),
      ],
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({required this.start, required this.forecast});

  final DateTime start;
  final CycleForecast forecast;

  @override
  Widget build(BuildContext context) {
    final periodEnd = _addCalendarDays(start, forecast.menstruationLength - 1);
    final ovulation = _addCalendarDays(start, forecast.ovulationDay - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CYCLE STARTING - ${_formatDate(start)}',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 2),
        Text('${forecast.cycleLength} day cycle'),
        const SizedBox(height: 8),
        _PredictionPhaseLine(forecast: forecast),
        const SizedBox(height: 12),
        Text('Menstruation: ${_formatDate(start)} - ${_formatDate(periodEnd)}'),
        Text('Ovulation: ${_formatDate(ovulation)}'),
        const SizedBox(height: 36),
      ],
    );
  }
}

class _PredictionPhaseLine extends StatelessWidget {
  const _PredictionPhaseLine({required this.forecast});

  final CycleForecast forecast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColors = theme.extension<CyclePhaseColors>();
    final totalDays = forecast.cycleLength.clamp(1, 90).toInt();

    return LayoutBuilder(
      builder: (context, constraints) {
        const maxDotsPerRow = 28;
        const spacing = 4.0;
        final dotsInFirstRow = totalDays.clamp(1, maxDotsPerRow).toInt();
        final dotSize =
            ((constraints.maxWidth - (spacing * (dotsInFirstRow - 1))) /
                    dotsInFirstRow)
                .clamp(7.0, 10.0);

        return Semantics(
          label: 'Predicted full cycle phase timeline',
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var day = 1; day <= totalDays; day++)
                Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: _predictionPhaseDotColor(
                      day: day,
                      forecast: forecast,
                      phaseColors: phaseColors,
                      theme: theme,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Color _predictionPhaseDotColor({
  required int day,
  required CycleForecast forecast,
  required CyclePhaseColors? phaseColors,
  required ThemeData theme,
}) {
  final menstruationLength =
      forecast.menstruationLength.clamp(1, forecast.cycleLength).toInt();
  final ovulationDay = forecast.ovulationDay.clamp(1, forecast.cycleLength).toInt();
  final fertileStart = (ovulationDay - 5).clamp(1, forecast.cycleLength).toInt();

  if (day <= menstruationLength) {
    return phaseColors?.menstrual ?? Colors.red;
  }
  if (day >= fertileStart && day <= ovulationDay) {
    return phaseColors?.ovulation ?? theme.colorScheme.primary;
  }
  if (day > ovulationDay) {
    return phaseColors?.luteal ?? theme.colorScheme.tertiary;
  }
  return phaseColors?.follicular ?? theme.colorScheme.secondary;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _addCalendarDays(DateTime date, int days) {
  return DateTime(date.year, date.month, date.day + days);
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.${date.year}';
}
