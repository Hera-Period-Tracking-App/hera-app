import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sl')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @cycleNotifications.
  ///
  /// In en, this message translates to:
  /// **'Cycle notifications'**
  String get cycleNotifications;

  /// No description provided for @cycleNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminders for upcoming menstruation, ovulation, fertile window, and late periods.'**
  String get cycleNotificationsDescription;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get appLock;

  /// No description provided for @appLockBiometricsDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock Hera with biometrics, with PIN as backup.'**
  String get appLockBiometricsDescription;

  /// No description provided for @appLockPinDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock Hera with your PIN.'**
  String get appLockPinDescription;

  /// No description provided for @appLockDisabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Require biometrics or a backup PIN when opening the app.'**
  String get appLockDisabledDescription;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesDescription.
  ///
  /// In en, this message translates to:
  /// **'Show saved notes and allow adding new notes from the app.'**
  String get notesDescription;

  /// No description provided for @aiSummaries.
  ///
  /// In en, this message translates to:
  /// **'AI summaries'**
  String get aiSummaries;

  /// No description provided for @aiSummariesDescription.
  ///
  /// In en, this message translates to:
  /// **'Allow Hera to generate cycle summaries from your local cycle data and notes.'**
  String get aiSummariesDescription;

  /// No description provided for @automaticSync.
  ///
  /// In en, this message translates to:
  /// **'Automatic sync'**
  String get automaticSync;

  /// No description provided for @automaticSyncSignedInDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically sync encrypted data with the server when the app runs.'**
  String get automaticSyncSignedInDescription;

  /// No description provided for @automaticSyncSignedOutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in to enable automatic server sync.'**
  String get automaticSyncSignedOutDescription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language.'**
  String get languageDescription;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @slovenian.
  ///
  /// In en, this message translates to:
  /// **'Slovenian'**
  String get slovenian;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @startNewCycle.
  ///
  /// In en, this message translates to:
  /// **'Start new cycle'**
  String get startNewCycle;

  /// No description provided for @startNewCycleDescription.
  ///
  /// In en, this message translates to:
  /// **'Begin tracking a fresh cycle start date.'**
  String get startNewCycleDescription;

  /// No description provided for @couldNotLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not load settings: {error}'**
  String couldNotLoadSettings(String error);

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found: {route}'**
  String routeNotFound(String route);

  /// No description provided for @preparingPrivateSpace.
  ///
  /// In en, this message translates to:
  /// **'Preparing your private space'**
  String get preparingPrivateSpace;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @viewPredictions.
  ///
  /// In en, this message translates to:
  /// **'View predictions'**
  String get viewPredictions;

  /// No description provided for @editCurrentCycleStartDate.
  ///
  /// In en, this message translates to:
  /// **'Edit current cycle start date'**
  String get editCurrentCycleStartDate;

  /// No description provided for @hideCalendarLegend.
  ///
  /// In en, this message translates to:
  /// **'Hide calendar legend'**
  String get hideCalendarLegend;

  /// No description provided for @showCalendarLegend.
  ///
  /// In en, this message translates to:
  /// **'Show calendar legend'**
  String get showCalendarLegend;

  /// No description provided for @notesDisabledInSettings.
  ///
  /// In en, this message translates to:
  /// **'Notes are disabled in Settings.'**
  String get notesDisabledInSettings;

  /// No description provided for @couldNotLoadNotes.
  ///
  /// In en, this message translates to:
  /// **'Could not load notes: {error}'**
  String couldNotLoadNotes(String error);

  /// No description provided for @couldNotLoadProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile settings: {error}'**
  String couldNotLoadProfileSettings(String error);

  /// No description provided for @couldNotLoadCalendar.
  ///
  /// In en, this message translates to:
  /// **'Could not load calendar: {error}'**
  String couldNotLoadCalendar(String error);

  /// No description provided for @editCycleInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap on days you want your period to be added or removed.'**
  String get editCycleInstruction;

  /// No description provided for @selectNewCycleStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select a start date for your new cycle.'**
  String get selectNewCycleStartDate;

  /// No description provided for @selectNoteDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date for your note.'**
  String get selectNoteDate;

  /// No description provided for @newCycleDateRules.
  ///
  /// In en, this message translates to:
  /// **'Future dates are disabled. Existing cycle rules are applied when saving.'**
  String get newCycleDateRules;

  /// No description provided for @noteDateRules.
  ///
  /// In en, this message translates to:
  /// **'Each date can have one note.'**
  String get noteDateRules;

  /// No description provided for @selectedDate.
  ///
  /// In en, this message translates to:
  /// **'Selected: {date}'**
  String selectedDate(String date);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get editNote;

  /// No description provided for @writePrivateNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Write a private note...'**
  String get writePrivateNoteHint;

  /// No description provided for @addSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Add symptoms'**
  String get addSymptoms;

  /// No description provided for @flowLabel.
  ///
  /// In en, this message translates to:
  /// **'Flow: {flow}'**
  String flowLabel(String flow);

  /// No description provided for @cancelNote.
  ///
  /// In en, this message translates to:
  /// **'Cancel note'**
  String get cancelNote;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get saveNote;

  /// No description provided for @writeNoteOrSymptomsBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Write a note or add symptoms before saving.'**
  String get writeNoteOrSymptomsBeforeSaving;

  /// No description provided for @noteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved.'**
  String get noteSaved;

  /// No description provided for @noteUpdated.
  ///
  /// In en, this message translates to:
  /// **'Note updated.'**
  String get noteUpdated;

  /// No description provided for @couldNotSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Could not save note: {error}'**
  String couldNotSaveNote(String error);

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @editSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Edit symptoms'**
  String get editSymptoms;

  /// No description provided for @customSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Custom symptoms'**
  String get customSymptoms;

  /// No description provided for @noCustomSymptomsYet.
  ///
  /// In en, this message translates to:
  /// **'No custom symptoms yet.'**
  String get noCustomSymptomsYet;

  /// No description provided for @symptomName.
  ///
  /// In en, this message translates to:
  /// **'Symptom name'**
  String get symptomName;

  /// No description provided for @editCustomSymptom.
  ///
  /// In en, this message translates to:
  /// **'Edit custom symptom'**
  String get editCustomSymptom;

  /// No description provided for @removeCustomSymptom.
  ///
  /// In en, this message translates to:
  /// **'Remove custom symptom'**
  String get removeCustomSymptom;

  /// No description provided for @addSymptom.
  ///
  /// In en, this message translates to:
  /// **'Add a symptom'**
  String get addSymptom;

  /// No description provided for @menstrualFlow.
  ///
  /// In en, this message translates to:
  /// **'Menstrual flow'**
  String get menstrualFlow;

  /// No description provided for @symptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomBloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get symptomBloating;

  /// No description provided for @symptomBackPain.
  ///
  /// In en, this message translates to:
  /// **'Back pain'**
  String get symptomBackPain;

  /// No description provided for @symptomBreastTenderness.
  ///
  /// In en, this message translates to:
  /// **'Breast tenderness'**
  String get symptomBreastTenderness;

  /// No description provided for @symptomAcne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get symptomAcne;

  /// No description provided for @symptomFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get symptomFatigue;

  /// No description provided for @symptomMoodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get symptomMoodSwings;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @symptomCravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get symptomCravings;

  /// No description provided for @flowSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get flowSpotting;

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @flowVeryHeavy.
  ///
  /// In en, this message translates to:
  /// **'Very heavy'**
  String get flowVeryHeavy;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get noNotesYet;

  /// No description provided for @noteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note} other{{count} notes}}'**
  String noteCount(int count);

  /// No description provided for @predictionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get predictionsTitle;

  /// No description provided for @couldNotLoadCycleHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load cycle history: {error}'**
  String couldNotLoadCycleHistory(String error);

  /// No description provided for @couldNotCreatePredictions.
  ///
  /// In en, this message translates to:
  /// **'Could not create predictions: {error}'**
  String couldNotCreatePredictions(String error);

  /// No description provided for @addCycleFirstForPredictions.
  ///
  /// In en, this message translates to:
  /// **'Add a cycle first to see predictions.'**
  String get addCycleFirstForPredictions;

  /// No description provided for @forecastExplanation.
  ///
  /// In en, this message translates to:
  /// **'These forecast settings are calculated from your saved previous cycles. Your latest cycle only sets the starting point for the first predicted date.'**
  String get forecastExplanation;

  /// No description provided for @predictionDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Predictions are estimates and may be inaccurate. They are not medical advice.'**
  String get predictionDisclaimer;

  /// No description provided for @forecastSettings.
  ///
  /// In en, this message translates to:
  /// **'FORECAST SETTINGS'**
  String get forecastSettings;

  /// No description provided for @cycleLengthDays.
  ///
  /// In en, this message translates to:
  /// **'Cycle length: {days} days'**
  String cycleLengthDays(int days);

  /// No description provided for @menstruationLengthDays.
  ///
  /// In en, this message translates to:
  /// **'Menstruation length: {days} days'**
  String menstruationLengthDays(int days);

  /// No description provided for @ovulationDay.
  ///
  /// In en, this message translates to:
  /// **'Ovulation day: {day}'**
  String ovulationDay(int day);

  /// No description provided for @cycleStarting.
  ///
  /// In en, this message translates to:
  /// **'CYCLE STARTING - {date}'**
  String cycleStarting(String date);

  /// No description provided for @dayCycle.
  ///
  /// In en, this message translates to:
  /// **'{days} day cycle'**
  String dayCycle(int days);

  /// No description provided for @menstruationDateRange.
  ///
  /// In en, this message translates to:
  /// **'Menstruation: {start} - {end}'**
  String menstruationDateRange(String start, String end);

  /// No description provided for @ovulationDate.
  ///
  /// In en, this message translates to:
  /// **'Ovulation: {date}'**
  String ovulationDate(String date);

  /// No description provided for @predictedFullCyclePhaseTimeline.
  ///
  /// In en, this message translates to:
  /// **'Predicted full cycle phase timeline'**
  String get predictedFullCyclePhaseTimeline;

  /// No description provided for @phaseMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Menstruation'**
  String get phaseMenstruation;

  /// No description provided for @phaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular phase'**
  String get phaseFollicular;

  /// No description provided for @phaseFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get phaseFertileWindow;

  /// No description provided for @phaseOvulationDay.
  ///
  /// In en, this message translates to:
  /// **'Ovulation day'**
  String get phaseOvulationDay;

  /// No description provided for @phaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal phase'**
  String get phaseLuteal;

  /// No description provided for @fertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile'**
  String get fertile;

  /// No description provided for @ovulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get ovulation;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get current;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'Basic user details, privacy controls, and app settings are grouped here.'**
  String get profileDescription;

  /// No description provided for @averageCycleSettings.
  ///
  /// In en, this message translates to:
  /// **'Average cycle settings'**
  String get averageCycleSettings;

  /// No description provided for @noAverageCycleSettings.
  ///
  /// In en, this message translates to:
  /// **'No averages saved yet. Complete onboarding to store your cycle and menstruation lengths.'**
  String get noAverageCycleSettings;

  /// No description provided for @averageCycleSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Average cycle length: {cycleDays} days\nAverage menstruation length: {menstruationDays} days'**
  String averageCycleSettingsBody(String cycleDays, String menstruationDays);

  /// No description provided for @loadingSavedAverages.
  ///
  /// In en, this message translates to:
  /// **'Loading your saved averages...'**
  String get loadingSavedAverages;

  /// No description provided for @couldNotLoadSavedAverages.
  ///
  /// In en, this message translates to:
  /// **'Could not load your saved averages.'**
  String get couldNotLoadSavedAverages;

  /// No description provided for @profileSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications, AI summaries, and other app preferences.'**
  String get profileSettingsDescription;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signedOutAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in. Create an account or log in to use secure sync.'**
  String get signedOutAccountDescription;

  /// No description provided for @signedInAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'You are signed in.'**
  String get signedInAccountDescription;

  /// No description provided for @signedInAsAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'You are signed in as {email}.'**
  String signedInAsAccountDescription(String email);

  /// No description provided for @checkingAccountStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking account status...'**
  String get checkingAccountStatus;

  /// No description provided for @couldNotLoadAccountStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not load account status.'**
  String get couldNotLoadAccountStatus;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signedOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Signed out.'**
  String get signedOutMessage;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @syncSignedInDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload encrypted local records, then pull newer encrypted changes from the API into the local database.'**
  String get syncSignedInDescription;

  /// No description provided for @syncSignedOutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign in first to sync local encrypted data with the API.'**
  String get syncSignedOutDescription;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete. Uploaded {uploaded}, downloaded {downloaded}, applied {applied}.'**
  String syncComplete(int uploaded, int downloaded, int applied);

  /// No description provided for @syncCompleteShort.
  ///
  /// In en, this message translates to:
  /// **'Sync complete'**
  String get syncCompleteShort;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @resetSyncData.
  ///
  /// In en, this message translates to:
  /// **'Reset sync data'**
  String get resetSyncData;

  /// No description provided for @syncDataReset.
  ///
  /// In en, this message translates to:
  /// **'Sync data reset.'**
  String get syncDataReset;

  /// No description provided for @updateEmail.
  ///
  /// In en, this message translates to:
  /// **'Update email'**
  String get updateEmail;

  /// No description provided for @updateEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Change the email address connected to your account.'**
  String get updateEmailDescription;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get newEmail;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @saveEmail.
  ///
  /// In en, this message translates to:
  /// **'Save email'**
  String get saveEmail;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @updatePasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password for this account.'**
  String get updatePasswordDescription;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password.'**
  String get enterCurrentPassword;

  /// No description provided for @enterNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a new email address.'**
  String get enterNewEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get enterValidEmail;

  /// No description provided for @emailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Email updated.'**
  String get emailUpdated;

  /// No description provided for @newPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters.'**
  String get newPasswordTooShort;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get passwordUpdated;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountQuestion;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This deletes your account and encrypted sync records. This cannot be undone.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and encrypted sync records.'**
  String get deleteAccountDescription;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deleting;

  /// No description provided for @cycleMonthRing.
  ///
  /// In en, this message translates to:
  /// **'Cycle month ring'**
  String get cycleMonthRing;

  /// No description provided for @loadingCycleData.
  ///
  /// In en, this message translates to:
  /// **'Loading cycle data...'**
  String get loadingCycleData;

  /// No description provided for @couldNotLoadCycleMonthRing.
  ///
  /// In en, this message translates to:
  /// **'Could not load cycle data for the month ring.'**
  String get couldNotLoadCycleMonthRing;

  /// No description provided for @dayOfCycle.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {length}'**
  String dayOfCycle(int day, int length);

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get backToToday;

  /// No description provided for @ovulationToday.
  ///
  /// In en, this message translates to:
  /// **'Ovulation today'**
  String get ovulationToday;

  /// No description provided for @ovulationInDays.
  ///
  /// In en, this message translates to:
  /// **'Ovulation in {days} days'**
  String ovulationInDays(int days);

  /// No description provided for @menstruationToday.
  ///
  /// In en, this message translates to:
  /// **'Menstruation today'**
  String get menstruationToday;

  /// No description provided for @menstruationInDays.
  ///
  /// In en, this message translates to:
  /// **'Menstruation in {days} days'**
  String menstruationInDays(int days);

  /// No description provided for @currentCycleSummary.
  ///
  /// In en, this message translates to:
  /// **'Current cycle summary'**
  String get currentCycleSummary;

  /// No description provided for @currentCycleSummaryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Current cycle summary unavailable'**
  String get currentCycleSummaryUnavailable;

  /// No description provided for @buildingCurrentCycleSummary.
  ///
  /// In en, this message translates to:
  /// **'Building a summary from your cycle data and notes...'**
  String get buildingCurrentCycleSummary;

  /// No description provided for @couldNotBuildCurrentCycleSummary.
  ///
  /// In en, this message translates to:
  /// **'Could not build the current cycle summary.'**
  String get couldNotBuildCurrentCycleSummary;

  /// No description provided for @privacyModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy mode'**
  String get privacyModeTitle;

  /// No description provided for @secureSyncModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure sync'**
  String get secureSyncModeTitle;

  /// No description provided for @secureSyncModeDescription.
  ///
  /// In en, this message translates to:
  /// **'You are currently using secure sync, so your data is also stored on the server. Do not worry, it is encrypted before it leaves this device.'**
  String get secureSyncModeDescription;

  /// No description provided for @localOnlyModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get localOnlyModeTitle;

  /// No description provided for @localOnlyModeDescription.
  ///
  /// In en, this message translates to:
  /// **'You are currently using local only mode, so your data stays on this device and is not synced to the server.'**
  String get localOnlyModeDescription;

  /// No description provided for @loadingPrivacyMode.
  ///
  /// In en, this message translates to:
  /// **'Loading privacy mode...'**
  String get loadingPrivacyMode;

  /// No description provided for @couldNotLoadPrivacyMode.
  ///
  /// In en, this message translates to:
  /// **'Could not load privacy mode.'**
  String get couldNotLoadPrivacyMode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sl':
      return AppLocalizationsSl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
