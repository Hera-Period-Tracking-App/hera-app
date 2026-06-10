class AppRoutePaths {
  const AppRoutePaths._();

  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const home = '/home';
  static const calendar = '/calendar';
  static const calendarDateDetails = '/calendar/date/:date';
  static const addEntry = '/add';
  static const symptoms = '/symptoms';
  static const notes = '/notes';
  static const profile = '/profile';

  static String calendarDateDetailsFor(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final dateParam =
        '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
    return '/calendar/date/$dateParam';
  }
}
