import 'package:hera_app/features/notes/models/note_draft.dart';

class NoteContentCodec {
  const NoteContentCodec._();

  static NoteDraft parse(String content) {
    final text = <String>[];
    final symptoms = <String>{};
    String? flow;
    for (final block in content.split('\n\n')) {
      final value = block.trim();
      if (value.isEmpty) continue;
      if (value.startsWith('Symptoms: ')) {
        symptoms.addAll(value.substring(10).split(',').map((item) => item.trim()).where((item) => item.isNotEmpty));
      } else if (value.startsWith('Menstrual flow: ')) {
        final parsedFlow = value.substring(16).trim();
        flow = parsedFlow.isEmpty ? null : parsedFlow;
      } else {
        text.add(value);
      }
    }
    return NoteDraft(text: text.join('\n\n'), symptoms: symptoms, flow: flow);
  }

  static String encode({required String text, required Set<String> symptoms, String? flow}) {
    final parts = <String>[];
    if (text.trim().isNotEmpty) parts.add(text.trim());
    if (symptoms.isNotEmpty) parts.add('Symptoms: ${symptoms.join(', ')}');
    if (flow != null) parts.add('Menstrual flow: $flow');
    return parts.join('\n\n');
  }
}
