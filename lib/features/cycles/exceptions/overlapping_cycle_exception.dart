class OverlappingCycleException implements Exception {
  final String message;

  OverlappingCycleException([this.message = 'The new cycle overlaps with an existing cycle.']);

  @override
  String toString() => 'OverlappingCycleException: $message';
}