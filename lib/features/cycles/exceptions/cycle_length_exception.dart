class CycleLengthException implements Exception {
  final String message;

  CycleLengthException([this.message = 'Cycle length must be in correct range.']);

  @override
  String toString() => 'CycleLengthException: $message';
}