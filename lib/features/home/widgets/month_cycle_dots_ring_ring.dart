part of 'month_cycle_dots_ring.dart';

class _DotsRing extends StatelessWidget {
  const _DotsRing({
    required this.dotsCount,
    required this.currentDay,
    required this.dragProgress,
    required this.cyclePhase,
    required this.phasesByDay,
  });

  final int dotsCount;
  final int currentDay;
  final double dragProgress;
  final CyclePhase cyclePhase;
  final Map<int, CyclePhase> phasesByDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phaseColors = theme.extension<CyclePhaseColors>();
    final safeDotsCount = dotsCount > 0 ? dotsCount : 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ringSize = constraints.biggest.shortestSide;
        final center = ringSize / 2;
        final dotSize = (ringSize * 0.075).clamp(12.0, 26.0);
        final radius = (ringSize / 2) - (dotSize / 2);
        final imageViewportDiameter = ((radius * 2) - dotSize - 10).clamp(
          120.0,
          ringSize,
        );

        return Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              children: [
                Center(
                  child: _PhaseCenterImage(
                    phase: cyclePhase,
                    viewportDiameter: imageViewportDiameter,
                  ),
                ),
                for (var day = 1; day <= safeDotsCount; day++)
                  _buildDot(
                    day: day,
                    totalDots: safeDotsCount,
                    center: center,
                    radius: radius,
                    dotSize: dotSize,
                    color: _colorForDay(
                      day,
                      phaseColors,
                      theme,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _colorForDay(
    int day,
    CyclePhaseColors? phaseColors,
    ThemeData theme,
  ) {
    final phase = phasesByDay[day] ?? CyclePhase.follicular;

    if (phaseColors == null) {
      return theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38);
    }

    return switch (phase) {
      CyclePhase.menstruation => phaseColors.menstrual,
      CyclePhase.follicular => phaseColors.follicular,
      CyclePhase.ovulation => phaseColors.ovulation,
      CyclePhase.luteal => phaseColors.luteal,
    };
  }

  Widget _buildDot({
    required int day,
    required int totalDots,
    required double center,
    required double radius,
    required double dotSize,
    required Color color,
  }) {
    var normalizedIndex = (day - currentDay - dragProgress) % totalDots;
    if (normalizedIndex < 0) {
      normalizedIndex += totalDots;
    }

    final angle = (-math.pi / 2) + (2 * math.pi * normalizedIndex / totalDots);

    final x = center + radius * math.cos(angle);
    final y = center + radius * math.sin(angle);

    return Positioned(
      left: x - (dotSize / 2),
      top: y - (dotSize / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _PhaseCenterImage extends StatelessWidget {
  const _PhaseCenterImage({
    required this.phase,
    required this.viewportDiameter,
  });

  final CyclePhase phase;
  final double viewportDiameter;

  @override
  Widget build(BuildContext context) {
    final config = _configForPhase(phase);

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = viewportDiameter;
        final imageYOffset = imageSize * config.yOffsetFactor;
        final imageXOffset = imageSize * config.xOffsetFactor;

        return RepaintBoundary(
          child: AnimatedSwitcher(
              key: ValueKey<String>(config.assetPath),
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale:
                        Tween<double>(begin: 0.96, end: 1).animate(animation),
                    child: child,
                  ),
                );
              },
              child: ClipOval(
                child: SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: Transform.translate(
                    offset: Offset(imageXOffset, imageYOffset),
                    child: Transform.scale(
                      scale: config.zoom,
                      child: Image.asset(
                        key: ValueKey<String>(config.assetPath),
                        config.assetPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              )),
        );
      },
    );
  }

  _PhaseImageConfig _configForPhase(CyclePhase phase) {
    return switch (phase) {
      CyclePhase.menstruation => const _PhaseImageConfig(
          assetPath: 'assets/images/homepage/persephone.png',
          zoom: 1.75,
          yOffsetFactor: 0.39,
          xOffsetFactor: 0,
        ),
      CyclePhase.follicular => const _PhaseImageConfig(
          assetPath: 'assets/images/homepage/artemis.png',
          zoom: 1.5,
          yOffsetFactor: 0.28,
          xOffsetFactor: 0.1,
        ),
      CyclePhase.ovulation => const _PhaseImageConfig(
          assetPath: 'assets/images/homepage/aphrodite.png',
          zoom: 1.7,
          yOffsetFactor: 0.48,
          xOffsetFactor: 0,
        ),
      CyclePhase.luteal => const _PhaseImageConfig(
          assetPath: 'assets/images/homepage/athena.png',
          zoom: 1.7,
          yOffsetFactor: 0.42,
          xOffsetFactor: 0.06,
        ),
    };
  }
}

class _PhaseImageConfig {
  const _PhaseImageConfig({
    required this.assetPath,
    required this.zoom,
    required this.yOffsetFactor,
    required this.xOffsetFactor,
  });

  final String assetPath;
  final double zoom;
  final double yOffsetFactor;
  final double xOffsetFactor;
}
