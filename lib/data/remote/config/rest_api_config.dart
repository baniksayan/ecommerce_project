class RestApiConfig {
  const RestApiConfig._();

  // Override at build/run time with:
  // flutter run --dart-define=REST_API_BASE_URL=https://your-api.com
  static const String baseUrl = String.fromEnvironment(
    'REST_API_BASE_URL',
    defaultValue: 'https://api.mandal-variety.com',
  );

  static const Duration requestTimeout = Duration(seconds: 20);

  static Uri buildUri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    final sanitizedPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('$baseUrl/$sanitizedPath');

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: queryParameters.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
