const String kNetworkErrorMessage =
    'No internet connection. Please check your network and try again.';

bool isNetworkError(Object? error) {
  if (error == null) return false;
  final msg = error.toString().toLowerCase();
  return msg.contains('internet') ||
      msg.contains('dns') ||
      msg.contains('timed out') ||
      msg.contains('timeout') ||
      msg.contains('socket') ||
      msg.contains('failed host lookup') ||
      msg.contains('network') ||
      msg.contains('connection refused') ||
      msg.contains('host lookup');
}
