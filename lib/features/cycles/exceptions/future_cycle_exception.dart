class FutureCycleException implements Exception {
  const FutureCycleException([this.message = 'Start date cannot be in the future']);

  final String message;

  @override
  String toString() => 'FutureCycleException: $message';
}
