class DuplicateNoteDateException implements Exception {
  const DuplicateNoteDateException([
    this.message = 'A note already exists for this date.',
  ]);

  final String message;
}
