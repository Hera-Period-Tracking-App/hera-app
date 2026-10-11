import 'package:flutter/material.dart';
import 'package:hera_app/features/notes/constants/note_options.dart';
import 'package:hera_app/features/notes/utils/note_option_labels.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';


Future<void> showSymptomPickerSheet(
    {required BuildContext context,
    required Set<String> selectedSymptoms,
    required Set<String> customSymptoms,
    required String? selectedFlow,
    required ValueChanged<
            ({Set<String> symptoms, Set<String> customSymptoms, String? flow})>
        onChanged}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _SymptomPickerSheet(
        selectedSymptoms: selectedSymptoms,
        customSymptoms: customSymptoms,
        selectedFlow: selectedFlow,
        onChanged: onChanged),
  );
}

class _SymptomPickerSheet extends StatefulWidget {
  const _SymptomPickerSheet(
      {required this.selectedSymptoms,
      required this.customSymptoms,
      required this.selectedFlow,
      required this.onChanged});
  final Set<String> selectedSymptoms;
  final Set<String> customSymptoms;
  final String? selectedFlow;
  final ValueChanged<
          ({Set<String> symptoms, Set<String> customSymptoms, String? flow})>
      onChanged;
  @override
  State<_SymptomPickerSheet> createState() => _SymptomPickerSheetState();
}

class _SymptomPickerSheetState extends State<_SymptomPickerSheet> {
  late final Set<String> _symptoms = {...widget.selectedSymptoms};
  late final Set<String> _customSymptoms = {...widget.customSymptoms};
  late String? _flow = widget.selectedFlow;
  final _customController = TextEditingController();
  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _publish() => widget.onChanged((
        symptoms: {..._symptoms},
        customSymptoms: {..._customSymptoms},
        flow: _flow
      ));
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
        child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            shrinkWrap: true,
            children: [
          Text(l10n.symptoms, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final symptom in availableSymptoms(_customSymptoms))
              FilterChip(
                label: Text(symptomLabel(l10n, symptom)),
                  selected: _symptoms.contains(symptom),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _symptoms.add(symptom)
                          : _symptoms.remove(symptom);
                    });
                    _publish();
                  })
          ]),
          const SizedBox(height: 16),
          TextField(
              controller: _customController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  hintText: l10n.symptomName,
                  suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: l10n.addSymptom,
                      onPressed: _addCustomSymptom))),
          const SizedBox(height: 20),
          Text(l10n.menstrualFlow,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final flow in menstrualFlowOptions)
              ChoiceChip(
                label: Text(flowLabel(l10n, flow)),
                  selected: _flow == flow,
                  onSelected: (selected) {
                    setState(() => _flow = selected ? flow : null);
                    _publish();
                  })
          ]),
        ]));
  }

  void _addCustomSymptom() {
    final symptom = _customController.text.trim();
    if (symptom.isEmpty) return;
    setState(() {
      _customSymptoms.add(symptom);
      _symptoms.add(symptom);
      _customController.clear();
    });
    _publish();
  }
}
