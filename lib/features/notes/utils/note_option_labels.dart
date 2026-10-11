import 'package:hera_app/l10n/generated/app_localizations.dart';

String symptomLabel(AppLocalizations l10n, String symptom) => switch (symptom) {
      'Cramps' => l10n.symptomCramps,
      'Headache' => l10n.symptomHeadache,
      'Bloating' => l10n.symptomBloating,
      'Back pain' => l10n.symptomBackPain,
      'Breast tenderness' => l10n.symptomBreastTenderness,
      'Acne' => l10n.symptomAcne,
      'Fatigue' => l10n.symptomFatigue,
      'Mood swings' => l10n.symptomMoodSwings,
      'Nausea' => l10n.symptomNausea,
      'Cravings' => l10n.symptomCravings,
      _ => symptom,
    };

String flowLabel(AppLocalizations l10n, String flow) => switch (flow) {
      'Spotting' => l10n.flowSpotting,
      'Light' => l10n.flowLight,
      'Medium' => l10n.flowMedium,
      'Heavy' => l10n.flowHeavy,
      'Very heavy' => l10n.flowVeryHeavy,
      _ => flow,
    };
