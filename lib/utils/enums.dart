enum EnumBuildEnvironment {
  dg,
  uat,
  live,
}

/// Standardized error message identifiers for network and API error handling.
///
/// Encapsulates string literals into strongly typed enums with default user-facing messages.
enum EnumErrorMessage {
  // Network connection messages
  checkInternet('Please check your internet connection and try again'),
  requestCancelled('The request has been cancelled.'),
  untrustedCertificate('Encountered an untrusted SSL/TLS certificate.'),
  unknownNetworkError('Unknown network error occurred.'),

  // Response validation messages
  emptyServerResponse('The response is empty from server'),
  emptyServerData('The data received from server is empty'),
  invalidResultType('Invalid result type from API response'),
  serverError('API response error from server'),
  validationError('Validation Error'),
  emptyTokenFromServer('Unable to receive the token from server. Please try after sometime'),
  tokenExpired('Token expired');

  final String message;

  const EnumErrorMessage(this.message);

  @override
  String toString() => message;
}
