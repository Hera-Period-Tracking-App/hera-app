part of 'calendar_screen.dart';

extension _CalendarScreenScroll on _CalendarScreenState {
  void _ensureCurrentMonthInitialPosition({
    required DateTime firstMonth,
    required DateTime focusedMonth,
    required int focusedMonthIndex,
    required bool forceRecenter,
  }) {
    if (_positionedAtCurrentMonth && !forceRecenter) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_monthScrollController.hasClients) {
        return;
      }

      final maxOffset = _monthScrollController.position.maxScrollExtent;
      final targetOffset = _estimateOffsetToMonthIndex(
        firstMonth: firstMonth,
        monthIndex: focusedMonthIndex,
      );
      final currentMonthSectionHeight =
          CalendarViewUtils.estimateMonthSectionHeight(focusedMonth);
      final viewport = _monthScrollController.position.viewportDimension;
      final centeredOffset =
          targetOffset - ((viewport - currentMonthSectionHeight) / 2);
      _monthScrollController.jumpTo(centeredOffset.clamp(0.0, maxOffset));
      if (mounted) {
        _markCurrentMonthPositioned();
      }
    });
  }

  double _estimateOffsetToMonthIndex({
    required DateTime firstMonth,
    required int monthIndex,
  }) {
    var offset = 0.0;

    for (var i = 0; i < monthIndex; i++) {
      final month = DateTime(firstMonth.year, firstMonth.month + i);
      offset += CalendarViewUtils.estimateMonthSectionHeight(month);
    }

    return offset;
  }
}
