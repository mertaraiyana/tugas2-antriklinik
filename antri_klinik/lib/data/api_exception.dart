enum ApiErrorKind {
  noConnection,
  timeout,
  badRequest,
  serverError,
  invalidData,
}

class ApiException implements Exception {
  const ApiException(this.kind, this.message);

  final ApiErrorKind kind;
  final String message;

  @override
  String toString() => message;
}
