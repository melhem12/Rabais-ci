/// Represents the pair of tokens returned by `/auth/refresh`
class TokenRefreshResult {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;

  const TokenRefreshResult({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
  });
}




