import 'package:flutter/material.dart';

import 'tobacco_access_coordinator.dart';
import 'tobacco_keyword_matcher.dart';

class TobaccoSearchRedirector {
  TobaccoSearchRedirector._();

  static DateTime? _lastNavAt;

  static Future<bool> maybeRedirect(
    BuildContext context,
    String query, {
    required int currentBottomBarIndex,
  }) async {
    if (!TobaccoKeywordMatcher.isTobaccoQuery(query)) return false;

    // Prevent rapid duplicate pushes when debounced callbacks fire repeatedly.
    final now = DateTime.now();
    final last = _lastNavAt;
    if (last != null && now.difference(last) < const Duration(seconds: 1)) {
      return true;
    }
    _lastNavAt = now;

    if (!context.mounted) return true;

    await TobaccoAccessCoordinator.instance.openTobaccoListing(
      context,
      currentBottomBarIndex: currentBottomBarIndex,
      initialQuery: query,
    );

    return true;
  }
}
