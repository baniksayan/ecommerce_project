import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Abstraction utility to check platforms without repetitive `Platform.isX`
/// and ensuring safe checks for web.
class PlatformHelper {
  static bool get isIOS {
    if (kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS;
    }
    return Platform.isIOS || Platform.isMacOS;
  }

  static bool get isAndroid {
    if (kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.fuchsia;
    }
    return Platform.isAndroid || Platform.isFuchsia;
  }
}
