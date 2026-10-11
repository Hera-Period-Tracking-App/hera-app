const commonSymptoms = <String>[
  'Cramps', 'Headache', 'Bloating', 'Back pain', 'Breast tenderness',
  'Acne', 'Fatigue', 'Mood swings', 'Nausea', 'Cravings',
];

const menstrualFlowOptions = <String>[
  'Spotting', 'Light', 'Medium', 'Heavy', 'Very heavy',
];

List<String> availableSymptoms(Iterable<String> customSymptoms) {
  final values = <String>{...commonSymptoms};
  values.addAll(
    customSymptoms
        .map((symptom) => symptom.trim())
        .where((symptom) => symptom.isNotEmpty),
  );
  return values.toList()..sort();
}
