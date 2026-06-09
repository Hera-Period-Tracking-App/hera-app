part of 'month_cycle_dots_ring.dart';

class _CurrentDayHeader extends StatelessWidget {
  const _CurrentDayHeader({
    required this.selectedDate,
    required this.dragProgress,
    required this.onSelectDate,
  });

  final DateTime selectedDate;
  final double dragProgress;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final dates = List<DateTime>.generate(
      9,
      (index) => DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day + (index - 4),
      ),
    );

    return SizedBox(
      height: 52,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final theme = Theme.of(context);
          final itemWidth = constraints.maxWidth / 7;
          final rowLeft = -itemWidth - (dragProgress * itemWidth);

          return ClipRect(
            child: Stack(
              children: [
                Positioned(
                  left: rowLeft,
                  top: 0,
                  width: itemWidth * dates.length,
                  height: 52,
                  child: Row(
                    children: [
                      for (var i = 0; i < dates.length; i++)
                        SizedBox(
                          width: itemWidth,
                          child: InkWell(
                            onTap: () => onSelectDate(dates[i]),
                            child: _DateStripItem(
                              date: dates[i],
                              isCenter: i == 4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      width: 2,
                      height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DateStripItem extends StatelessWidget {
  const _DateStripItem({required this.date, required this.isCenter});

  final DateTime date;
  final bool isCenter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: isCenter
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurfaceVariant,
      fontWeight: isCenter ? FontWeight.w700 : FontWeight.w500,
      letterSpacing: 1,
    );
    final dayStyle = theme.textTheme.titleSmall?.copyWith(
      color: isCenter
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurfaceVariant,
      fontWeight: isCenter ? FontWeight.w700 : FontWeight.w500,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: labelStyle ?? const TextStyle(),
          child: Text(weekdayLabels[date.weekday - 1].toUpperCase()),
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: dayStyle ?? const TextStyle(),
          child: Text('${date.day}'),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
