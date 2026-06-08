class DuplicateCycleException implements Exception {
  final String message;

  DuplicateCycleException([this.message = 'A cycle with the same start date already exists.']);

  @override
  String toString() => 'DuplicateCycleException: $message';
}