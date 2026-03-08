import 'package:flutter/material.dart';

// ============================================================================
// ONBOARDING VIEWMODEL
// Manages page state and fade-in animation for the onboarding flow.
// Structured for easy expansion to a full multi-slide PageView.
// ============================================================================

class OnboardingViewModel {
  final int totalPages = 3;

  // ── Fade-in animation for content elements ───────────────────────────────
  late final AnimationController fadeCtrl;

  late final Animation<double> illustrationFade;
  late final Animation<double> titleFade;
  late final Animation<double> subtitleFade;

  OnboardingViewModel({
    required TickerProvider vsync,
  }) {
    _initAnimations(vsync);
  }

  void _initAnimations(TickerProvider vsync) {
    fadeCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 600),
    );

    illustrationFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: fadeCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: fadeCtrl,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOut),
      ),
    );

    subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: fadeCtrl,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  /// Slide data for all onboarding pages.
  /// Extend this list to add more slides without changing the view.
  static const List<OnboardingSlideData> slides = [
    OnboardingSlideData(
      imagePath: 'assets/images/onboarding/delivery_splash_1.PNG',
      title: 'Order groceries easily',
      subtitle:
          'Browse fresh groceries, snacks, drinks, and daily essentials all in one place.',
    ),
    OnboardingSlideData(
      imagePath: 'assets/images/onboarding/delivery_splash_2.PNG',
      title: 'Fast & reliable delivery',
      subtitle:
          'Get your order delivered straight to your door in minutes.',
    ),
    OnboardingSlideData(
      imagePath: 'assets/images/onboarding/delivery_splash_3.PNG',
      title: 'Track your order',
      subtitle:
          'Follow your delivery in real time and know exactly when it arrives.',
    ),
  ];

  Listenable get listenable => fadeCtrl;

  /// Resets the fade animation to zero and replays it forward.
  /// Call this whenever the active slide changes.
  void resetAndPlay() {
    fadeCtrl.reset();
    fadeCtrl.forward();
  }

  void dispose() {
    fadeCtrl.dispose();
  }
}

// ============================================================================
// ONBOARDING SLIDE DATA MODEL
// ============================================================================

class OnboardingSlideData {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingSlideData({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}
