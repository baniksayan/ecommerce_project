import 'package:flutter/foundation.dart';

/// Abstraction utility to check platforms without repetitive `Platform.isX`
/// and ensuring safe checks for web.
class PlatformHelper {
  static bool get isIOS {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  static bool get isAndroid {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.fuchsia;
  }
}
