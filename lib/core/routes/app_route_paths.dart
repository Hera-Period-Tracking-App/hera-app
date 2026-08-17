class AppRoutePaths {
  const AppRoutePaths._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const calendar = '/calendar';
  static const calendarPredictions = '/calendar/predictions';
  static const calendarDateDetails = '/calendar/date/:date';
  static const calendarAddNote = '/calendar/note/new/:date';
  static const addEntry = '/add';
  static const symptoms = '/symptoms';
  static const notes = '/notes';
  static const profile = '/profile';
  static const settings = '/profile/settings';
  static const appLockSetup = '/profile/settings/app-lock';
  static const appLockDisable = '/profile/settings/app-lock/disable';

  static String calendarDateDetailsFor(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final dateParam =
        '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
    return '/calendar/date/$dateParam';
  }

  static String calendarAddNoteFor(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final dateParam =
        '${normalized.year.toString().padLeft(4, '0')}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
    return '/calendar/note/new/$dateParam';
  }
}
