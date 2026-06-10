part of 'calendar_screen.dart';

extension _CalendarScreenScroll on _CalendarScreenState {
  void _ensureCurrentMonthInitialPosition({
    required DateTime firstMonth,
    required DateTime nowMonth,
    required int currentMonthIndex,
    required bool forceRecenter,
  }) {
    if (_positionedAtCurrentMonth && !forceRecenter) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_monthScrollController.hasClients) {
        return;
      }

      final targetOffset = _estimateOffsetToMonthIndex(
        firstMonth: firstMonth,
        monthIndex: currentMonthIndex,
      );
      final currentMonthSectionHeight =
          CalendarViewUtils.estimateMonthSectionHeight(nowMonth);
      final viewport = _monthScrollController.position.viewportDimension;
      final centeredOffset = targetOffset - ((viewport - currentMonthSectionHeight) / 2);

      final maxOffset = _monthScrollController.position.maxScrollExtent;
      _monthScrollController.jumpTo(centeredOffset.clamp(0, maxOffset));
      _positionedAtCurrentMonth = true;
      _forceRecenterOnBuild = false;
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
