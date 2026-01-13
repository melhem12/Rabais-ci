/// Exception thrown when refreshing the access token fails.
class RefreshTokenException implements Exception {
  RefreshTokenException({
    required this.message,
    this.isInvalidToken = false,
  });

  final String message;
  final bool isInvalidToken;

  @override
  String toString() => message;
}




