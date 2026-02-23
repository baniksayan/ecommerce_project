import 'package:flutter/material.dart';

/// Reusable interactive full-screen image viewer.
/// Handles zooming, panning, double tap to zoom, and dismissing.
class ZoomableImageViewer extends StatefulWidget {
  final ImageProvider imageProvider;
  final String heroTag;

  const ZoomableImageViewer({
    Key? key,
    required this.imageProvider,
    required this.heroTag,
  }) : super(key: key);

  static void show(BuildContext context, {required ImageProvider imageProvider, required String heroTag}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => ZoomableImageViewer(
          imageProvider: imageProvider,
          heroTag: heroTag,
        ),
      ),
    );
  }

  @override
  State<ZoomableImageViewer> createState() => _ZoomableImageViewerState();
}

class _ZoomableImageViewerState extends State<ZoomableImageViewer> with SingleTickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        _transformationController.value = _animation!.value;
      });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails!.localPosition;
    
    const double doubleTapScale = 2.5;

    // Determine current scale
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    
    // Zoom out if already zoomed in, otherwise zoom in
    if (currentScale > 1.0) {
      _animateScale(Matrix4.identity());
    } else {
      final x = -position.dx * (doubleTapScale - 1);
      final y = -position.dy * (doubleTapScale - 1);
      final zoomedMatrix = Matrix4.identity()
        ..translate(x, y)
        ..scale(doubleTapScale);
      
      _animateScale(zoomedMatrix);
    }
  }

  void _animateScale(Matrix4 endMatrix) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurveTween(curve: Curves.easeOut).animate(_animationController));
    
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Always black background for media viewers
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: InteractiveViewer(
          transformationController: _transformationController,
          panEnabled: true,
          scaleEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: Center(
            child: Hero(
              tag: widget.heroTag,
              child: Image(
                image: widget.imageProvider,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
