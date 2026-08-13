// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get cycleNotifications => 'Cycle notifications';

  @override
  String get cycleNotificationsDescription =>
      'Reminders for upcoming menstruation, ovulation, fertile window, and late periods.';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockBiometricsDescription =>
      'Unlock Hera with biometrics, with PIN as backup.';

  @override
  String get appLockPinDescription => 'Unlock Hera with your PIN.';

  @override
  String get appLockDisabledDescription =>
      'Require biometrics or a backup PIN when opening the app.';

  @override
  String get notes => 'Notes';

  @override
  String get notesDescription =>
      'Show saved notes and allow adding new notes from the app.';

  @override
  String get aiSummaries => 'AI summaries';

  @override
  String get aiSummariesDescription =>
      'Allow Hera to generate cycle summaries from your local cycle data and notes.';

  @override
  String get automaticSync => 'Automatic sync';

  @override
  String get automaticSyncSignedInDescription =>
      'Automatically sync encrypted data with the server when the app runs.';

  @override
  String get automaticSyncSignedOutDescription =>
      'Sign in to enable automatic server sync.';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose the app language.';

  @override
  String get english => 'English';

  @override
  String get slovenian => 'Slovenian';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get profile => 'Profile';

  @override
  String get startNewCycle => 'Start new cycle';

  @override
  String get startNewCycleDescription =>
      'Begin tracking a fresh cycle start date.';

  @override
  String couldNotLoadSettings(String error) {
    return 'Could not load settings: $error';
  }

  @override
  String routeNotFound(String route) {
    return 'Route not found: $route';
  }

  @override
  String get preparingPrivateSpace => 'Preparing your private space';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get done => 'Done';

  @override
  String get edit => 'Edit';

  @override
  String get saving => 'Saving...';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get viewPredictions => 'View predictions';

  @override
  String get editCurrentCycleStartDate => 'Edit current cycle start date';

  @override
  String get hideCalendarLegend => 'Hide calendar legend';

  @override
  String get showCalendarLegend => 'Show calendar legend';

  @override
  String get notesDisabledInSettings => 'Notes are disabled in Settings.';

  @override
  String couldNotLoadNotes(String error) {
    return 'Could not load notes: $error';
  }

  @override
  String couldNotLoadProfileSettings(String error) {
    return 'Could not load profile settings: $error';
  }

  @override
  String couldNotLoadCalendar(String error) {
    return 'Could not load calendar: $error';
  }

  @override
  String get editCycleInstruction =>
      'Tap on days you want your period to be added or removed.';

  @override
  String get selectNewCycleStartDate =>
      'Select a start date for your new cycle.';

  @override
  String get selectNoteDate => 'Select a date for your note.';

  @override
  String get newCycleDateRules =>
      'Future dates are disabled. Existing cycle rules are applied when saving.';

  @override
  String get noteDateRules => 'Each date can have one note.';

  @override
  String selectedDate(String date) {
    return 'Selected: $date';
  }

  @override
  String get saveChanges => 'Save changes';

  @override
  String get newNote => 'New note';

  @override
  String get editNote => 'Edit note';

  @override
  String get writePrivateNoteHint => 'Write a private note...';

  @override
  String get addSymptoms => 'Add symptoms';

  @override
  String flowLabel(String flow) {
    return 'Flow: $flow';
  }

  @override
  String get cancelNote => 'Cancel note';

  @override
  String get saveNote => 'Save note';

  @override
  String get writeNoteOrSymptomsBeforeSaving =>
      'Write a note or add symptoms before saving.';

  @override
  String get noteSaved => 'Note saved.';

  @override
  String get noteUpdated => 'Note updated.';

  @override
  String couldNotSaveNote(String error) {
    return 'Could not save note: $error';
  }

  @override
  String get symptoms => 'Symptoms';

  @override
  String get editSymptoms => 'Edit symptoms';

  @override
  String get customSymptoms => 'Custom symptoms';

  @override
  String get noCustomSymptomsYet => 'No custom symptoms yet.';

  @override
  String get symptomName => 'Symptom name';

  @override
  String get editCustomSymptom => 'Edit custom symptom';

  @override
  String get removeCustomSymptom => 'Remove custom symptom';

  @override
  String get addSymptom => 'Add a symptom';

  @override
  String get menstrualFlow => 'Menstrual flow';

  @override
  String get symptomCramps => 'Cramps';

  @override
  String get symptomHeadache => 'Headache';

  @override
  String get symptomBloating => 'Bloating';

  @override
  String get symptomBackPain => 'Back pain';

  @override
  String get symptomBreastTenderness => 'Breast tenderness';

  @override
  String get symptomAcne => 'Acne';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomMoodSwings => 'Mood swings';

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomCravings => 'Cravings';

  @override
  String get flowSpotting => 'Spotting';

  @override
  String get flowLight => 'Light';

  @override
  String get flowMedium => 'Medium';

  @override
  String get flowHeavy => 'Heavy';

  @override
  String get flowVeryHeavy => 'Very heavy';

  @override
  String get noNotesYet => 'No notes yet.';

  @override
  String noteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
    );
    return '$_temp0';
  }

  @override
  String get predictionsTitle => 'Predictions';

  @override
  String couldNotLoadCycleHistory(String error) {
    return 'Could not load cycle history: $error';
  }

  @override
  String couldNotCreatePredictions(String error) {
    return 'Could not create predictions: $error';
  }

  @override
  String get addCycleFirstForPredictions =>
      'Add a cycle first to see predictions.';

  @override
  String get forecastExplanation =>
      'These forecast settings are calculated from your saved previous cycles. Your latest cycle only sets the starting point for the first predicted date.';

  @override
  String get predictionDisclaimer =>
      'Predictions are estimates and may be inaccurate. They are not medical advice.';

  @override
  String get forecastSettings => 'FORECAST SETTINGS';

  @override
  String cycleLengthDays(int days) {
    return 'Cycle length: $days days';
  }

  @override
  String menstruationLengthDays(int days) {
    return 'Menstruation length: $days days';
  }

  @override
  String ovulationDay(int day) {
    return 'Ovulation day: $day';
  }

  @override
  String cycleStarting(String date) {
    return 'CYCLE STARTING - $date';
  }

  @override
  String dayCycle(int days) {
    return '$days day cycle';
  }

  @override
  String menstruationDateRange(String start, String end) {
    return 'Menstruation: $start - $end';
  }

  @override
  String ovulationDate(String date) {
    return 'Ovulation: $date';
  }

  @override
  String get predictedFullCyclePhaseTimeline =>
      'Predicted full cycle phase timeline';

  @override
  String get phaseMenstruation => 'Menstruation';

  @override
  String get phaseFollicular => 'Follicular phase';

  @override
  String get phaseFertileWindow => 'Fertile window';

  @override
  String get phaseOvulationDay => 'Ovulation day';

  @override
  String get phaseLuteal => 'Luteal phase';

  @override
  String get fertile => 'Fertile';

  @override
  String get ovulation => 'Ovulation';

  @override
  String get today => 'Today';

  @override
  String get current => 'CURRENT';

  @override
  String get profileDescription =>
      'Basic user details, privacy controls, and app settings are grouped here.';

  @override
  String get averageCycleSettings => 'Average cycle settings';

  @override
  String get noAverageCycleSettings =>
      'No averages saved yet. Complete onboarding to store your cycle and menstruation lengths.';

  @override
  String averageCycleSettingsBody(String cycleDays, String menstruationDays) {
    return 'Average cycle length: $cycleDays days\nAverage menstruation length: $menstruationDays days';
  }

  @override
  String get loadingSavedAverages => 'Loading your saved averages...';

  @override
  String get couldNotLoadSavedAverages => 'Could not load your saved averages.';

  @override
  String get profileSettingsDescription =>
      'Manage notifications, AI summaries, and other app preferences.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get account => 'Account';

  @override
  String get signedOutAccountDescription =>
      'You are not signed in. Create an account or log in to use secure sync.';

  @override
  String get signedInAccountDescription => 'You are signed in.';

  @override
  String signedInAsAccountDescription(String email) {
    return 'You are signed in as $email.';
  }

  @override
  String get checkingAccountStatus => 'Checking account status...';

  @override
  String get couldNotLoadAccountStatus => 'Could not load account status.';

  @override
  String get editAccount => 'Edit account';

  @override
  String get signOut => 'Sign out';

  @override
  String get signedOutMessage => 'Signed out.';

  @override
  String get createAccount => 'Create account';

  @override
  String get logIn => 'Log in';

  @override
  String get checking => 'Checking...';

  @override
  String get tryAgain => 'Try again';

  @override
  String get sync => 'Sync';

  @override
  String get syncSignedInDescription =>
      'Upload encrypted local records, then pull newer encrypted changes from the API into the local database.';

  @override
  String get syncSignedOutDescription =>
      'Sign in first to sync local encrypted data with the API.';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncNow => 'Sync now';

  @override
  String syncComplete(int uploaded, int downloaded, int applied) {
    return 'Sync complete. Uploaded $uploaded, downloaded $downloaded, applied $applied.';
  }

  @override
  String get syncCompleteShort => 'Sync complete';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get close => 'Close';

  @override
  String get resetSyncData => 'Reset sync data';

  @override
  String get syncDataReset => 'Sync data reset.';

  @override
  String get updateEmail => 'Update email';

  @override
  String get updateEmailDescription =>
      'Change the email address connected to your account.';

  @override
  String get newEmail => 'New email';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get currentPassword => 'Current password';

  @override
  String get saveEmail => 'Save email';

  @override
  String get updatePassword => 'Update password';

  @override
  String get updatePasswordDescription =>
      'Choose a new password for this account.';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get savePassword => 'Save password';

  @override
  String get enterCurrentPassword => 'Enter your current password.';

  @override
  String get enterNewEmail => 'Enter a new email address.';

  @override
  String get enterValidEmail => 'Enter a valid email address.';

  @override
  String get emailUpdated => 'Email updated.';

  @override
  String get newPasswordTooShort =>
      'New password must be at least 8 characters.';

  @override
  String get newPasswordsDoNotMatch => 'New passwords do not match.';

  @override
  String get passwordUpdated => 'Password updated.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountQuestion => 'Delete account?';

  @override
  String get deleteAccountWarning =>
      'This deletes your account and encrypted sync records. This cannot be undone.';

  @override
  String get deleteAccountDescription =>
      'Permanently delete your account and encrypted sync records.';

  @override
  String get deleting => 'Deleting...';

  @override
  String get cycleMonthRing => 'Cycle month ring';

  @override
  String get loadingCycleData => 'Loading cycle data...';

  @override
  String get couldNotLoadCycleMonthRing =>
      'Could not load cycle data for the month ring.';

  @override
  String dayOfCycle(int day, int length) {
    return 'Day $day of $length';
  }

  @override
  String get backToToday => 'Back to today';

  @override
  String get ovulationToday => 'Ovulation today';

  @override
  String ovulationInDays(int days) {
    return 'Ovulation in $days days';
  }

  @override
  String get menstruationToday => 'Menstruation today';

  @override
  String menstruationInDays(int days) {
    return 'Menstruation in $days days';
  }

  @override
  String get currentCycleSummary => 'Current cycle summary';

  @override
  String get currentCycleSummaryUnavailable =>
      'Current cycle summary unavailable';

  @override
  String get buildingCurrentCycleSummary =>
      'Building a summary from your cycle data and notes...';

  @override
  String get couldNotBuildCurrentCycleSummary =>
      'Could not build the current cycle summary.';

  @override
  String get privacyModeTitle => 'Privacy mode';

  @override
  String get secureSyncModeTitle => 'Secure sync';

  @override
  String get secureSyncModeDescription =>
      'You are currently using secure sync, so your data is also stored on the server. Do not worry, it is encrypted before it leaves this device.';

  @override
  String get localOnlyModeTitle => 'Local only';

  @override
  String get localOnlyModeDescription =>
      'You are currently using local only mode, so your data stays on this device and is not synced to the server.';

  @override
  String get loadingPrivacyMode => 'Loading privacy mode...';

  @override
  String get couldNotLoadPrivacyMode => 'Could not load privacy mode.';
}
