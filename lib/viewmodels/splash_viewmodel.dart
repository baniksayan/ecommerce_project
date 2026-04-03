import 'package:flutter/material.dart';

class SplashViewModel {
  late final AnimationController masterCtrl;
  late final AnimationController bgPulseCtrl;
  late final AnimationController dotCtrl;

  // Background pulse
  late final Animation<double> bgPulse;

  // Logo fade-in + slide up
  late final Animation<double> logoFade;
  late final Animation<double> logoSlide;

  // Tagline fade-in (delayed)
  late final Animation<double> taglineFade;

  // Basket bounce-in from bottom
  late final Animation<double> basketY;
  late final Animation<double> basketScale;

  // Grocery item drops
  late final Animation<double> milkY;
  late final Animation<double> milkOpacity;

  late final Animation<double> appleY;
  late final Animation<double> appleOpacity;

  late final Animation<double> croissantY;
  late final Animation<double> croissantOpacity;

  late final Animation<double> breadY;
  late final Animation<double> breadOpacity;

  late final Animation<double> baguetteY;
  late final Animation<double> baguetteOpacity;

  late final Animation<double> tomatoY;
  late final Animation<double> tomatoOpacity;

  // Scooter slide across screen
  late final Animation<double> scooterX;
  late final Animation<double> scooterOpacity;

  // Floating leaf decoration animations
  late final Animation<double> leaf1X;
  late final Animation<double> leaf1Y;
  late final Animation<double> leaf1Rot;
  late final Animation<double> leaf2X;
  late final Animation<double> leaf2Y;
  late final Animation<double> leaf2Rot;

  // Loading dot pulse
  late final Animation<double> dot1;
  late final Animation<double> dot2;
  late final Animation<double> dot3;

  Listenable get listenable =>
      Listenable.merge([masterCtrl, bgPulseCtrl, dotCtrl]);

  SplashViewModel({required TickerProvider vsync, required VoidCallback onComplete}) {
    _initAnimations(vsync, onComplete);
  }

  void _initAnimations(TickerProvider vsync, VoidCallback onComplete) {
    // ── Master controller (6 s loop) ──────────────────────────────────────
    masterCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 6000),
    );

    // ── Background pulse ──────────────────────────────────────────────────
    bgPulseCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 3000),
    );
    bgPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: bgPulseCtrl, curve: Curves.easeInOut),
    );
    bgPulseCtrl.repeat(reverse: true);

    // ── Logo ──────────────────────────────────────────────────────────────
    logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.0, 0.12, curve: Curves.easeOut),
      ),
    );
    logoSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.0, 0.14, curve: Curves.easeOut),
      ),
    );

    // ── Tagline ───────────────────────────────────────────────────────────
    taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.10, 0.22, curve: Curves.easeOut),
      ),
    );

    // ── Basket ────────────────────────────────────────────────────────────
    basketY = Tween<double>(begin: 1.8, end: 0.78).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.08, 0.22, curve: Curves.elasticOut),
      ),
    );
    basketScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.08, 0.22, curve: Curves.elasticOut),
      ),
    );

    // ── Milk Carton ───────────────────────────────────────────────────────
    milkY = Tween<double>(begin: -1.8, end: 0.08).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.16, 0.32, curve: Curves.bounceOut),
      ),
    );
    milkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.16, 0.20, curve: Curves.easeIn),
      ),
    );

    // ── Apple ─────────────────────────────────────────────────────────────
    appleY = Tween<double>(begin: -1.8, end: 0.06).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.24, 0.40, curve: Curves.bounceOut),
      ),
    );
    appleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.24, 0.28, curve: Curves.easeIn),
      ),
    );

    // ── Croissant ─────────────────────────────────────────────────────────
    croissantY = Tween<double>(begin: -1.8, end: -0.10).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.30, 0.46, curve: Curves.bounceOut),
      ),
    );
    croissantOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.30, 0.34, curve: Curves.easeIn),
      ),
    );

    // ── Bread ─────────────────────────────────────────────────────────────
    breadY = Tween<double>(begin: -1.8, end: -0.22).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.36, 0.52, curve: Curves.bounceOut),
      ),
    );
    breadOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.36, 0.40, curve: Curves.easeIn),
      ),
    );

    // ── Baguette ──────────────────────────────────────────────────────────
    baguetteY = Tween<double>(begin: -1.8, end: -0.32).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.40, 0.56, curve: Curves.bounceOut),
      ),
    );
    baguetteOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.40, 0.44, curve: Curves.easeIn),
      ),
    );

    // ── Tomato ────────────────────────────────────────────────────────────
    tomatoY = Tween<double>(begin: -1.8, end: -0.42).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.44, 0.60, curve: Curves.bounceOut),
      ),
    );
    tomatoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.44, 0.48, curve: Curves.easeIn),
      ),
    );

    // ── Scooter ───────────────────────────────────────────────────────────
    scooterX = Tween<double>(begin: -1.6, end: 1.6).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.60, 0.96, curve: Curves.easeInOut),
      ),
    );
    scooterOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: masterCtrl,
        curve: const Interval(0.60, 0.65, curve: Curves.easeIn),
      ),
    );

    // ── Decorative floating leaves ────────────────────────────────────────
    leaf1X = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: bgPulseCtrl, curve: Curves.easeInOut),
    );
    leaf1Y = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: bgPulseCtrl, curve: Curves.easeInOut),
    );
    leaf1Rot = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: bgPulseCtrl, curve: Curves.easeInOut),
    );
    leaf2X = Tween<double>(begin: 0.04, end: -0.04).animate(
      CurvedAnimation(parent: bgPulseCtrl, curve: Curves.easeInOut),
    );
    leaf2Y = Tween<double>(begin: 0.02, end: -0.02).animate(
      CurvedAnimation(parent: bgPulseCtrl, curve: Curves.easeInOut),
    );
    leaf2Rot = Tween<double>(begin: 0.15, end: -0.15).animate(
      CurvedAnimation(parent: bgPulseCtrl, curve: Curves.easeInOut),
    );

    // ── Loading dots ──────────────────────────────────────────────────────
    dotCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1200),
    );
    dot1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: dotCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    dot2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: dotCtrl,
        curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
      ),
    );
    dot3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: dotCtrl,
        curve: const Interval(0.4, 0.9, curve: Curves.easeInOut),
      ),
    );
    dotCtrl.repeat(reverse: true);

    masterCtrl.forward().then((_) => onComplete());
  }

  void dispose() {
    masterCtrl.dispose();
    bgPulseCtrl.dispose();
    dotCtrl.dispose();
  }
}
