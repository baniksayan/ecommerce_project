import 'package:flutter/foundation.dart';

import '../core/network/network_error_utils.dart' as net;

/// Base viewmodel exposing common state elements like loading and error handling.
/// Extends ChangeNotifier for reactive UI bindings native to Flutter.
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  bool _isNetworkError = false;
  bool get isNetworkError => _isNetworkError;

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setError(String? message) {
    _isNetworkError = net.isNetworkError(message);
    _errorMessage = message;
    notifyListeners();
  }

  void setNetworkError({String message = net.kNetworkErrorMessage}) {
    _isNetworkError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null || _isNetworkError) {
      _errorMessage = null;
      _isNetworkError = false;
      notifyListeners();
    }
  }
}
