class MenstruationLengthException implements Exception {
  final String message;

  MenstruationLengthException([this.message = 'Menstruation length must be in correct range.']);

  @override
  String toString() => 'MenstruationLengthException: $message';
}