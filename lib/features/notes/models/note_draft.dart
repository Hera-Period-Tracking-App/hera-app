class NoteDraft {
  const NoteDraft({
    required this.text,
    required this.symptoms,
    required this.flow,
  });

  final String text;
  final Set<String> symptoms;
  final String? flow;
}
