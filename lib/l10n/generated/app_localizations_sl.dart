// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get settingsTitle => 'Nastavitve';

  @override
  String get cycleNotifications => 'Obvestila o ciklu';

  @override
  String get cycleNotificationsDescription =>
      'Opomniki za prihajajočo menstruacijo, ovulacijo, plodno obdobje in zamudo.';

  @override
  String get appLock => 'Zaklep aplikacije';

  @override
  String get appLockBiometricsDescription =>
      'Odkleni Hero z biometrijo, PIN je rezervna možnost.';

  @override
  String get appLockPinDescription => 'Odkleni Hero s PIN-om.';

  @override
  String get appLockDisabledDescription =>
      'Zahtevaj biometrijo ali rezervni PIN ob odpiranju aplikacije.';

  @override
  String get notes => 'Zapisi';

  @override
  String get notesDescription =>
      'Prikaži shranjene zapise in omogoči dodajanje novih zapisov.';

  @override
  String get aiSummaries => 'AI povzetki';

  @override
  String get aiSummariesDescription =>
      'Dovoli Heri ustvarjanje povzetkov cikla iz lokalnih podatkov in zapisov.';

  @override
  String get automaticSync => 'Samodejna sinhronizacija';

  @override
  String get automaticSyncSignedInDescription =>
      'Samodejno sinhroniziraj šifrirane podatke s strežnikom.';

  @override
  String get automaticSyncSignedOutDescription =>
      'Za sinhronizacijo s strežnikom se najprej prijavi.';

  @override
  String get language => 'Jezik';

  @override
  String get languageDescription => 'Izberi jezik aplikacije.';

  @override
  String get english => 'Angleščina';

  @override
  String get slovenian => 'Slovenščina';

  @override
  String get home => 'Domov';

  @override
  String get calendar => 'Kolendar';

  @override
  String get profile => 'Profil';

  @override
  String get startNewCycle => 'Začni nov cikel';

  @override
  String get startNewCycleDescription =>
      'Začni spremljati nov začetni datum cikla.';

  @override
  String couldNotLoadSettings(String error) {
    return 'Nastavitev ni bilo mogoče naložiti: $error';
  }

  @override
  String routeNotFound(String route) {
    return 'Poti ni bilo mogoče najti: $route';
  }

  @override
  String get preparingPrivateSpace => 'Pripravljam tvoj zasebni prostor';

  @override
  String get cancel => 'Prekliči';

  @override
  String get save => 'Shrani';

  @override
  String get add => 'Dodaj';

  @override
  String get done => 'Končano';

  @override
  String get edit => 'Uredi';

  @override
  String get saving => 'Shranjujem...';

  @override
  String get calendarTitle => 'Kolendar';

  @override
  String get viewPredictions => 'Prikaži napovedi';

  @override
  String get editCurrentCycleStartDate =>
      'Uredi začetni datum trenutnega cikla';

  @override
  String get hideCalendarLegend => 'Skrij legendo kolendarja';

  @override
  String get showCalendarLegend => 'Prikaži legendo kolendarja';

  @override
  String get notesDisabledInSettings => 'Zapisi so izklopljeni v nastavitvah.';

  @override
  String couldNotLoadNotes(String error) {
    return 'Zapisov ni bilo mogoče naložiti: $error';
  }

  @override
  String couldNotLoadProfileSettings(String error) {
    return 'Nastavitev profila ni bilo mogoče naložiti: $error';
  }

  @override
  String couldNotLoadCalendar(String error) {
    return 'Kolendarja ni bilo mogoče naložiti: $error';
  }

  @override
  String get editCycleInstruction =>
      'Tapni dneve, ki jih želiš dodati ali odstraniti iz menstruacije.';

  @override
  String get selectNewCycleStartDate => 'Izberi začetni datum novega cikla.';

  @override
  String get selectNoteDate => 'Izberi datum za zapis.';

  @override
  String get newCycleDateRules =>
      'Prihodnji datumi so onemogočeni. Ob shranjevanju se uporabijo obstoječa pravila ciklov.';

  @override
  String get noteDateRules => 'Vsak datum ima lahko en zapis.';

  @override
  String selectedDate(String date) {
    return 'Izbrano: $date';
  }

  @override
  String get saveChanges => 'Shrani spremembe';

  @override
  String get newNote => 'Nov zapis';

  @override
  String get editNote => 'Uredi zapis';

  @override
  String get writePrivateNoteHint => 'Napiši zasebni zapis...';

  @override
  String get addSymptoms => 'Dodaj simptome';

  @override
  String flowLabel(String flow) {
    return 'Tok: $flow';
  }

  @override
  String get cancelNote => 'Prekliči zapis';

  @override
  String get saveNote => 'Shrani zapis';

  @override
  String get writeNoteOrSymptomsBeforeSaving =>
      'Pred shranjevanjem napiši zapis ali dodaj simptome.';

  @override
  String get noteSaved => 'Zapis shranjen.';

  @override
  String get noteUpdated => 'Zapis posodobljen.';

  @override
  String couldNotSaveNote(String error) {
    return 'Zapisa ni bilo mogoče shraniti: $error';
  }

  @override
  String get symptoms => 'Simptomi';

  @override
  String get editSymptoms => 'Uredi simptome';

  @override
  String get customSymptoms => 'Simptomi po meri';

  @override
  String get noCustomSymptomsYet => 'Ni še simptomov po meri.';

  @override
  String get symptomName => 'Ime simptoma';

  @override
  String get editCustomSymptom => 'Uredi simptom po meri';

  @override
  String get removeCustomSymptom => 'Odstrani simptom po meri';

  @override
  String get addSymptom => 'Dodaj simptom';

  @override
  String get menstrualFlow => 'Menstrualni tok';

  @override
  String get symptomCramps => 'Krči';

  @override
  String get symptomHeadache => 'Glavobol';

  @override
  String get symptomBloating => 'Napihnjenost';

  @override
  String get symptomBackPain => 'Bolečine v hrbtu';

  @override
  String get symptomBreastTenderness => 'Občutljive prsi';

  @override
  String get symptomAcne => 'Akne';

  @override
  String get symptomFatigue => 'Utrujenost';

  @override
  String get symptomMoodSwings => 'Nihanje razpoloženja';

  @override
  String get symptomNausea => 'Slabost';

  @override
  String get symptomCravings => 'Hrepenenje po hrani';

  @override
  String get flowSpotting => 'Izcedek';

  @override
  String get flowLight => 'Lahek';

  @override
  String get flowMedium => 'Srednji';

  @override
  String get flowHeavy => 'Močan';

  @override
  String get flowVeryHeavy => 'Zelo močan';

  @override
  String get noNotesYet => 'Ni še zapisov.';

  @override
  String noteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zapisov',
      two: '2 zapisa',
      one: '1 zapis',
    );
    return '$_temp0';
  }

  @override
  String get predictionsTitle => 'Napovedi';

  @override
  String couldNotLoadCycleHistory(String error) {
    return 'Zgodovine ciklov ni bilo mogoče naložiti: $error';
  }

  @override
  String couldNotCreatePredictions(String error) {
    return 'Napovedi ni bilo mogoče ustvariti: $error';
  }

  @override
  String get addCycleFirstForPredictions =>
      'Najprej dodaj cikel, da vidiš napovedi.';

  @override
  String get forecastExplanation =>
      'Te nastavitve napovedi so izračunane iz tvojih shranjenih prejšnjih ciklov. Zadnji cikel določi samo začetno točko prvega napovedanega datuma.';

  @override
  String get predictionDisclaimer =>
      'Napovedi so ocene in so lahko netočne. Niso zdravstveni nasvet.';

  @override
  String get forecastSettings => 'NASTAVITVE NAPOVEDI';

  @override
  String cycleLengthDays(int days) {
    return 'Dolžina cikla: $days dni';
  }

  @override
  String menstruationLengthDays(int days) {
    return 'Dolžina menstruacije: $days dni';
  }

  @override
  String ovulationDay(int day) {
    return 'Dan ovulacije: $day';
  }

  @override
  String cycleStarting(String date) {
    return 'CIKEL SE ZAČNE - $date';
  }

  @override
  String dayCycle(int days) {
    return '$days-dnevni cikel';
  }

  @override
  String menstruationDateRange(String start, String end) {
    return 'Menstruacija: $start - $end';
  }

  @override
  String ovulationDate(String date) {
    return 'Ovulacija: $date';
  }

  @override
  String get predictedFullCyclePhaseTimeline =>
      'Napovedana časovnica faz celotnega cikla';

  @override
  String get phaseMenstruation => 'Menstruacija';

  @override
  String get phaseFollicular => 'Folikularna faza';

  @override
  String get phaseFertileWindow => 'Plodno obdobje';

  @override
  String get phaseOvulationDay => 'Dan ovulacije';

  @override
  String get phaseLuteal => 'Lutealna faza';

  @override
  String get fertile => 'Plodno';

  @override
  String get ovulation => 'Ovulacija';

  @override
  String get today => 'Danes';

  @override
  String get current => 'TRENUTNO';

  @override
  String get profileDescription =>
      'Tukaj so zbrani osnovni podatki uporabnika, zasebnost in nastavitve aplikacije.';

  @override
  String get averageCycleSettings => 'Povprečne nastavitve cikla';

  @override
  String get noAverageCycleSettings =>
      'Povprečja še niso shranjena. Dokončaj uvod, da shraniš dolžino cikla in menstruacije.';

  @override
  String averageCycleSettingsBody(String cycleDays, String menstruationDays) {
    return 'Povprečna dolžina cikla: $cycleDays dni\nPovprečna dolžina menstruacije: $menstruationDays dni';
  }

  @override
  String get loadingSavedAverages => 'Nalagam shranjena povprečja...';

  @override
  String get couldNotLoadSavedAverages =>
      'Shranjena povprečja se niso mogla naložiti.';

  @override
  String get profileSettingsDescription =>
      'Upravljaj obvestila, AI povzetke in druge nastavitve aplikacije.';

  @override
  String get openSettings => 'Odpri nastavitve';

  @override
  String get account => 'Račun';

  @override
  String get signedOutAccountDescription =>
      'Nisi prijavljena. Ustvari račun ali se prijavi za varno sinhronizacijo.';

  @override
  String get signedInAccountDescription => 'Prijavljena si.';

  @override
  String signedInAsAccountDescription(String email) {
    return 'Prijavljena si kot $email.';
  }

  @override
  String get checkingAccountStatus => 'Preverjam stanje računa...';

  @override
  String get couldNotLoadAccountStatus =>
      'Stanja računa ni bilo mogoče naložiti.';

  @override
  String get editAccount => 'Uredi račun';

  @override
  String get signOut => 'Odjava';

  @override
  String get signedOutMessage => 'Odjavljena.';

  @override
  String get createAccount => 'Ustvari račun';

  @override
  String get logIn => 'Prijava';

  @override
  String get checking => 'Preverjam...';

  @override
  String get tryAgain => 'Poskusi znova';

  @override
  String get sync => 'Sinhronizacija';

  @override
  String get syncSignedInDescription =>
      'Naloži šifrirane lokalne zapise, nato prenesi novejše šifrirane spremembe iz API-ja v lokalno bazo.';

  @override
  String get syncSignedOutDescription =>
      'Najprej se prijavi za sinhronizacijo lokalnih šifriranih podatkov z API-jem.';

  @override
  String get syncing => 'Sinhroniziram...';

  @override
  String get syncNow => 'Sinhroniziraj zdaj';

  @override
  String syncComplete(int uploaded, int downloaded, int applied) {
    return 'Sinhronizacija končana. Naloženo $uploaded, preneseno $downloaded, uporabljeno $applied.';
  }

  @override
  String get syncCompleteShort => 'Sinhronizacija končana';

  @override
  String get syncFailed => 'Sinhronizacija ni uspela';

  @override
  String get close => 'Zapri';

  @override
  String get resetSyncData => 'Ponastavi sinhronizirane podatke';

  @override
  String get syncDataReset => 'Sinhronizirani podatki so ponastavljeni.';

  @override
  String get updateEmail => 'Posodobi e-pošto';

  @override
  String get updateEmailDescription =>
      'Spremeni e-poštni naslov, povezan z računom.';

  @override
  String get newEmail => 'Nova e-pošta';

  @override
  String get emailHint => 'ti@example.com';

  @override
  String get currentPassword => 'Trenutno geslo';

  @override
  String get saveEmail => 'Shrani e-pošto';

  @override
  String get updatePassword => 'Posodobi geslo';

  @override
  String get updatePasswordDescription => 'Izberi novo geslo za ta račun.';

  @override
  String get newPassword => 'Novo geslo';

  @override
  String get confirmNewPassword => 'Potrdi novo geslo';

  @override
  String get savePassword => 'Shrani geslo';

  @override
  String get enterCurrentPassword => 'Vnesi trenutno geslo.';

  @override
  String get enterNewEmail => 'Vnesi nov e-poštni naslov.';

  @override
  String get enterValidEmail => 'Vnesi veljaven e-poštni naslov.';

  @override
  String get emailUpdated => 'E-pošta posodobljena.';

  @override
  String get newPasswordTooShort => 'Novo geslo mora imeti vsaj 8 znakov.';

  @override
  String get newPasswordsDoNotMatch => 'Novi gesli se ne ujemata.';

  @override
  String get passwordUpdated => 'Geslo posodobljeno.';

  @override
  String get deleteAccount => 'Izbriši račun';

  @override
  String get deleteAccountQuestion => 'Izbrišem račun?';

  @override
  String get deleteAccountWarning =>
      'To izbriše tvoj račun in šifrirane sinhronizirane zapise. Tega ni mogoče razveljaviti.';

  @override
  String get deleteAccountDescription =>
      'Trajno izbriši račun in šifrirane sinhronizirane zapise.';

  @override
  String get deleting => 'Brišem...';

  @override
  String get cycleMonthRing => 'Krog mesečnega cikla';

  @override
  String get loadingCycleData => 'Nalagam podatke cikla...';

  @override
  String get couldNotLoadCycleMonthRing =>
      'Podatkov cikla za mesečni krog ni bilo mogoče naložiti.';

  @override
  String dayOfCycle(int day, int length) {
    return '$day. dan od $length';
  }

  @override
  String get backToToday => 'Nazaj na danes';

  @override
  String get ovulationToday => 'Ovulacija danes';

  @override
  String ovulationInDays(int days) {
    return 'Ovulacija čez $days dni';
  }

  @override
  String get menstruationToday => 'Menstruacija danes';

  @override
  String menstruationInDays(int days) {
    return 'Menstruacija čez $days dni';
  }

  @override
  String get currentCycleSummary => 'Povzetek trenutnega cikla';

  @override
  String get currentCycleSummaryUnavailable =>
      'Povzetek trenutnega cikla ni na voljo';

  @override
  String get buildingCurrentCycleSummary =>
      'Ustvarjam povzetek iz podatkov cikla in zapisov...';

  @override
  String get couldNotBuildCurrentCycleSummary =>
      'Povzetka trenutnega cikla ni bilo mogoče ustvariti.';

  @override
  String get privacyModeTitle => 'Način zasebnosti';

  @override
  String get secureSyncModeTitle => 'Varna sinhronizacija';

  @override
  String get secureSyncModeDescription =>
      'Trenutno uporabljaš varno sinhronizacijo, zato so tvoji podatki shranjeni tudi na strežniku. Brez skrbi, šifrirani so, preden zapustijo to napravo.';

  @override
  String get localOnlyModeTitle => 'Samo lokalno';

  @override
  String get localOnlyModeDescription =>
      'Trenutno uporabljaš samo lokalni način, zato tvoji podatki ostanejo na tej napravi in se ne sinhronizirajo s strežnikom.';

  @override
  String get loadingPrivacyMode => 'Nalagam način zasebnosti...';

  @override
  String get couldNotLoadPrivacyMode =>
      'Načina zasebnosti ni bilo mogoče naložiti.';
}
