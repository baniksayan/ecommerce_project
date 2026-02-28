import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

class ZoomableImageViewer extends StatefulWidget {
  final ImageProvider imageProvider;
  final String? heroTag;
  final Color backgroundColor;

  const ZoomableImageViewer({
    super.key,
    required this.imageProvider,
    this.heroTag,
    this.backgroundColor = Colors.black,
  });

  static Future<void> show(
    BuildContext context, {
    required ImageProvider imageProvider,
    String? heroTag,
    Color backgroundColor = Colors.black,
  }) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: backgroundColor,
        pageBuilder: (_, _, _) => ZoomableImageViewer(
          imageProvider: imageProvider,
          heroTag: heroTag,
          backgroundColor: backgroundColor,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<ZoomableImageViewer> createState() => _ZoomableImageViewerState();
}

class _ZoomableImageViewerState extends State<ZoomableImageViewer>
    with TickerProviderStateMixin {
  final String className = "Zoomable Image Viewer Screen";

  // ── Scale constants ───-
  static const double _minScale = 1.0;
  static const double _maxScale = 5.0;
  static const double _doubleTapZoomScale = 2.5;
  static const double _zoomedThreshold = 1.05;

  // Rubber-band: log-scale elasticity coefficient — higher = softer wall
  static const double _rubberBandK = 0.4;

  // ── Transform state -───
  double _scale = 1.0;
  double _tx = 0.0; // translation relative to the container centre
  double _ty = 0.0;

  // Snapshot taken at the start of each scale gesture
  double _startScale = 1.0;
  double _startTx = 0.0;
  double _startTy = 0.0;
  Offset _startFocal = Offset.zero;

  // Double-tap tap-down position
  Offset? _doubleTapPosition;

  // Container size (from LayoutBuilder)
  Size _containerSize = Size.zero;

  // Image natural aspect ratio (width / height); loaded asynchronously
  double _imageAspectRatio = 1.0;

  // ── Animation – spring-back ─────────
  late final AnimationController _springController;
  Animation<double>? _springScale;
  Animation<Offset>? _springOffset;

  // ── Animation – inertia (pan fling) -─────────────
  late final Ticker _inertiaTicker;
  FrictionSimulation? _simX;
  FrictionSimulation? _simY;
  Duration? _inertiaStart;

  // ── Friction coefficient for pan inertia -────────
  // Lower = longer glide (premium gallery feel); 0.003 ≈ iOS Photos
  static const double _friction = 0.003;

  @override
  void initState() {
    super.initState();

    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480), // overridden per spring sim
    )..addListener(_onSpringTick);

    _inertiaTicker = createTicker(_onInertiaTick);

    _loadImageAspectRatio();
  }

  // Pre-load the image's aspect ratio for accurate vertical clamping.
  void _loadImageAspectRatio() {
    final stream = widget.imageProvider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      if (mounted) {
        setState(() {
          _imageAspectRatio =
              info.image.width.toDouble() / info.image.height.toDouble();
        });
      }
      stream.removeListener(listener);
    });
    stream.addListener(listener);
  }

  @override
  void dispose() {
    _springController
      ..removeListener(_onSpringTick)
      ..dispose();
    _inertiaTicker.dispose();
    super.dispose();
  }

  // ── Spring-back animation --

  void _onSpringTick() {
    if (_springScale == null || _springOffset == null) return;
    setState(() {
      _scale = _springScale!.value;
      _tx = _springOffset!.value.dx;
      _ty = _springOffset!.value.dy;
    });
  }

  static const SpringDescription _snapSpring = SpringDescription(
    mass: 1,
    stiffness: 200,
    damping: 24,
  );

  void _springToValidState({double? forceTargetScale}) {
    _inertiaTicker.stop();
    _inertiaStart = null;

    final targetScale = (forceTargetScale ?? _scale).clamp(
      _minScale,
      _maxScale,
    );
    final targetOffset = _clampOffset(Offset(_tx, _ty), targetScale);

    _springController.stop();

    final scaleSim = SpringSimulation(
      _snapSpring,
      _scale,
      targetScale,
      0 /* initial velocity */,
    );
    final txSim = SpringSimulation(_snapSpring, _tx, targetOffset.dx, 0);
    final tySim = SpringSimulation(_snapSpring, _ty, targetOffset.dy, 0);

    // Animate over a generous window; the spring will settle before it ends.
    _springController.duration = const Duration(milliseconds: 600);

    _springScale = _springController
        .drive(Tween(begin: 0.0, end: 1.0))
        .drive(_SpringAdaptor(scaleSim, _scale, targetScale));
    _springOffset = _springController
        .drive(Tween(begin: 0.0, end: 1.0))
        .drive(
          _OffsetSpringAdaptor(txSim, tySim, Offset(_tx, _ty), targetOffset),
        );

    _springController
      ..reset()
      ..forward();
  }

  // ── Pan inertia -───────

  void _startInertia(Velocity velocity) {
    final vx = velocity.pixelsPerSecond.dx;
    final vy = velocity.pixelsPerSecond.dy;
    if (vx.abs() < 50 && vy.abs() < 50) return;

    _simX = FrictionSimulation(_friction, _tx, vx);
    _simY = FrictionSimulation(_friction, _ty, vy);
    _inertiaStart = null;

    if (!_inertiaTicker.isTicking) _inertiaTicker.start();
  }

  void _onInertiaTick(Duration elapsed) {
    _inertiaStart ??= elapsed;
    final t = (elapsed - _inertiaStart!).inMicroseconds / 1e6;

    final doneX = _simX!.isDone(t);
    final doneY = _simY!.isDone(t);

    if (doneX && doneY) {
      _inertiaTicker.stop();
      _inertiaStart = null;
      _springToValidState();
      return;
    }

    final newTx = doneX ? _simX!.finalX : _simX!.x(t);
    final newTy = doneY ? _simY!.finalX : _simY!.x(t);
    final clamped = _clampOffset(Offset(newTx, newTy), _scale);

    setState(() {
      _tx = clamped.dx;
      _ty = clamped.dy;
    });

    // Stop inertia early if we've hit a hard edge
    if (clamped.dx != newTx || clamped.dy != newTy) {
      _inertiaTicker.stop();
      _inertiaStart = null;
    }
  }

  // ── Gesture callbacks -─

  void _onScaleStart(ScaleStartDetails d) {
    _springController.stop();
    _inertiaTicker.stop();
    _inertiaStart = null;

    _startScale = _scale;
    _startTx = _tx;
    _startTy = _ty;
    _startFocal = d.localFocalPoint;

    if (d.pointerCount >= 2) {
      // CommonFunction.TrackEvent("$className | Image Zoom/Pan Started");
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final rawScale = _startScale * d.scale;

    // Rubber-band resistance beyond limits
    final newScale = _rubberBand(rawScale);

    final focal = d.localFocalPoint;
    final W = _containerSize.width;
    final H = _containerSize.height;

    final dAnchorX = _startFocal.dx - (W / 2 + _startTx);
    final dAnchorY = _startFocal.dy - (H / 2 + _startTy);

    final newCentreX = focal.dx - dAnchorX * (newScale / _startScale);
    final newCentreY = focal.dy - dAnchorY * (newScale / _startScale);

    // tx/ty = image centre offset from container centre
    final rawTx = newCentreX - W / 2;
    final rawTy = newCentreY - H / 2;

    final isInValidRange = newScale >= _minScale && newScale <= _maxScale;
    final offset = isInValidRange
        ? _clampOffset(Offset(rawTx, rawTy), newScale)
        : Offset(rawTx, rawTy);

    setState(() {
      _scale = newScale;
      _tx = offset.dx;
      _ty = offset.dy;
    });
  }

  void _onScaleEnd(ScaleEndDetails d) {
    final outsideLimits = _scale < _minScale || _scale > _maxScale;

    if (outsideLimits) {
      _springToValidState();
      return;
    }

    // Apply inertia for pan flings
    _startInertia(d.velocity);

    if (!_inertiaTicker.isTicking) {
      final clamped = _clampOffset(Offset(_tx, _ty), _scale);
      if (clamped != Offset(_tx, _ty)) _springToValidState();
    }
  }

  // ── Double-tap -────────

  void _onDoubleTapDown(TapDownDetails d) {
    _doubleTapPosition = d.localPosition;
  }

  void _onDoubleTap() {
    _springController.stop();
    _inertiaTicker.stop();

    final isZoomed = _scale > _zoomedThreshold;
    if (isZoomed) {
      // CommonFunction.TrackEvent("$className | Double Tap Zoom Out");
      _springToValidState(forceTargetScale: _minScale);
    } else {
      // CommonFunction.TrackEvent("$className | Double Tap Zoom In");
      final tap =
          _doubleTapPosition ??
          Offset(_containerSize.width / 2, _containerSize.height / 2);
      final s = _doubleTapZoomScale;
      final W = _containerSize.width;
      final H = _containerSize.height;

      // Focal-point zoom to tap position
      final dAnchorX = tap.dx - (W / 2 + _tx);
      final dAnchorY = tap.dy - (H / 2 + _ty);
      final targetCentreX = tap.dx - dAnchorX * (s / _scale);
      final targetCentreY = tap.dy - dAnchorY * (s / _scale);
      final targetTx = targetCentreX - W / 2;
      final targetTy = targetCentreY - H / 2;
      final clamped = _clampOffset(Offset(targetTx, targetTy), s);

      _springController.stop();
      _springController.duration = const Duration(milliseconds: 480);
      final scaleSim = SpringSimulation(_snapSpring, _scale, s, 0);
      final txSim = SpringSimulation(_snapSpring, _tx, clamped.dx, 0);
      final tySim = SpringSimulation(_snapSpring, _ty, clamped.dy, 0);
      _springScale = _springController
          .drive(Tween(begin: 0.0, end: 1.0))
          .drive(_SpringAdaptor(scaleSim, _scale, s));
      _springOffset = _springController
          .drive(Tween(begin: 0.0, end: 1.0))
          .drive(_OffsetSpringAdaptor(txSim, tySim, Offset(_tx, _ty), clamped));
      _springController
        ..reset()
        ..forward();
    }
  }

  double _rubberBand(double raw) {
    if (raw > _maxScale) {
      final over = raw - _maxScale;
      return _maxScale + math.log(1 + over) * _rubberBandK;
    } else if (raw < _minScale) {
      final under = _minScale - raw;
      return _minScale - math.log(1 + under) * _rubberBandK;
    }
    return raw;
  }

  /// Clamp [offset] (= tx, ty relative to container centre) so the image
  Offset _clampOffset(Offset offset, double scale) {
    if (_containerSize == Size.zero) return offset;

    final W = _containerSize.width;
    final H = _containerSize.height;

    // Scaled image dimensions
    final imgW = W * scale;
    final imgH = (W / _imageAspectRatio) * scale;

    // Max allowed translation (image edge flush with container edge)
    final maxTx = math.max(0.0, (imgW - W) / 2);
    final maxTy = math.max(0.0, (imgH - H) / 2);

    // If scaled image is smaller than container, centre it (tx/ty = 0)
    final clampedX = imgW <= W ? 0.0 : offset.dx.clamp(-maxTx, maxTx);
    final clampedY = imgH <= H ? 0.0 : offset.dy.clamp(-maxTy, maxTy);

    return Offset(clampedX, clampedY);
  }

  bool get _isZoomed => _scale > _zoomedThreshold;

  // ── Build -─────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Keep container size in sync for clamping calculations.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _containerSize != constraints.biggest) {
                setState(() => _containerSize = constraints.biggest);
              }
            });

            return Stack(
              children: [
                // ── Full-screen gesture layer -────
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onDoubleTapDown: _onDoubleTapDown,
                    onDoubleTap: _onDoubleTap,
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onScaleEnd: _onScaleEnd,
                    // Single tap closes only when not zoomed
                    onTap: () {
                      if (!_isZoomed) {
                        Navigator.of(context).maybePop();
                      }
                    },
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),

                IgnorePointer(
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(_tx, _ty)
                        ..scale(_scale),
                      child: widget.heroTag != null
                          ? Hero(
                              tag: widget.heroTag!,
                              child: Image(image: widget.imageProvider),
                            )
                          : Image(image: widget.imageProvider),
                    ),
                  ),
                ),

                // ── Close button -────────────────
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).maybePop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SpringAdaptor extends Animatable<double> {
  final SpringSimulation sim;
  final double begin;
  final double end;

  const _SpringAdaptor(this.sim, this.begin, this.end);

  @override
  double transform(double t) {
    final duration = sim.isDone(1.0) ? 1.0 : 0.6; // max 0.6 s window
    return sim.x(t * duration);
  }
}

class _OffsetSpringAdaptor extends Animatable<Offset> {
  final SpringSimulation simX;
  final SpringSimulation simY;
  final Offset begin;
  final Offset end;

  const _OffsetSpringAdaptor(this.simX, this.simY, this.begin, this.end);

  @override
  Offset transform(double t) {
    const dur = 0.6;
    return Offset(simX.x(t * dur), simY.x(t * dur));
  }
}
