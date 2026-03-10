import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Shimmer skeleton shown while [ProductDetailsView] is loading.
///
/// Mirrors the narrow single-column layout: image gallery → info block
/// (chip, name, rating, price, delivery tiles, description, reviews header,
/// review cards) + a frosted bottom-bar placeholder.
///
/// Static minimum display: 1.8 s (enforced in [ProductDetailsView]).
class ProductDetailsSkeleton extends StatefulWidget {
  const ProductDetailsSkeleton({super.key});

  @override
  State<ProductDetailsSkeleton> createState() =>
      _ProductDetailsSkeletonState();
}

class _ProductDetailsSkeletonState extends State<ProductDetailsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? AppColors.carbonBlack : AppColors.lightSurface;
    final boneBase = isDark
        ? AppColors.skeletonWithShimmerEffectDarkGrey
        : AppColors.skeletonWithShimmerEffectLightGrey;
    final boneHighlight = isDark
        ? AppColors.skeletonWithShimmerEffectDarkWhite
        : AppColors.skeletonWithShimmerEffectWhite;
    final barBg = isDark
        ? AppColors.carbonBlack.withValues(alpha: 0.96)
        : AppColors.lightSurface.withValues(alpha: 0.96);

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        final pos = -0.5 + _shimmer.value * 2.0;

        Shader buildShader(Rect bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            boneBase,
            boneBase,
            boneHighlight,
            boneBase,
            boneBase,
          ],
          stops: [
            0.0,
            (pos - 0.3).clamp(0.0, 1.0),
            pos.clamp(0.0, 1.0),
            (pos + 0.3).clamp(0.0, 1.0),
            1.0,
          ],
        ).createShader(bounds);

        return Stack(
          children: [
            // ── Scrollable content ─────────────────────────────────────
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: buildShader,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image gallery placeholder ────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: AspectRatio(
                        aspectRatio: 0.95,
                        child: Container(
                          decoration: BoxDecoration(
                            color: boneBase,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),

                    // ── Info section ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category chip
                          _Bone(
                            height: 24,
                            width: 88,
                            boneBase: boneBase,
                            borderRadius: 20,
                          ),
                          const SizedBox(height: 14),

                          // Product name — line 1
                          _Bone(
                            height: 20,
                            widthFactor: 0.92,
                            boneBase: boneBase,
                          ),
                          const SizedBox(height: 6),

                          // Product name — line 2
                          _Bone(
                            height: 20,
                            widthFactor: 0.62,
                            boneBase: boneBase,
                          ),
                          const SizedBox(height: 16),

                          // Rating row
                          Row(
                            children: [
                              for (int i = 0; i < 5; i++) ...[
                                _Bone(
                                  height: 14,
                                  width: 14,
                                  boneBase: boneBase,
                                  borderRadius: 2,
                                ),
                                const SizedBox(width: 4),
                              ],
                              const SizedBox(width: 4),
                              _Bone(
                                height: 14,
                                width: 60,
                                boneBase: boneBase,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Price
                          _Bone(
                            height: 28,
                            width: 110,
                            boneBase: boneBase,
                          ),
                          const SizedBox(height: 20),

                          // Delivery info tiles — 2 side-by-side
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: boneBase,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: boneBase,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Description paragraph — 4 lines
                          _Bone(
                            height: 12,
                            widthFactor: 0.95,
                            boneBase: boneBase,
                          ),
                          const SizedBox(height: 6),
                          _Bone(
                            height: 12,
                            widthFactor: 0.88,
                            boneBase: boneBase,
                          ),
                          const SizedBox(height: 6),
                          _Bone(
                            height: 12,
                            widthFactor: 0.72,
                            boneBase: boneBase,
                          ),
                          const SizedBox(height: 24),

                          // Product details card
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: boneBase,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Reviews header
                          Row(
                            children: [
                              _Bone(
                                height: 18,
                                width: 130,
                                boneBase: boneBase,
                              ),
                              const Spacer(),
                              _Bone(
                                height: 14,
                                width: 60,
                                boneBase: boneBase,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Review card 1
                          _ReviewCardBone(
                            cardBg: cardBg,
                            boneBase: boneBase,
                          ),
                          const SizedBox(height: 10),

                          // Review card 2
                          _ReviewCardBone(
                            cardBg: cardBg,
                            boneBase: boneBase,
                          ),
                          const SizedBox(height: 10),

                          // View all reviews CTA bone
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: boneBase,
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          // Bottom padding for the frosted bar
                          const SizedBox(height: 104),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Frosted bottom bar placeholder ─────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: barBg,
                child: SafeArea(
                  top: false,
                  child: ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: buildShader,
                    child: Row(
                      children: [
                        // Qty stepper outline
                        Container(
                          width: 100,
                          height: 48,
                          decoration: BoxDecoration(
                            color: boneBase,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Add to cart button
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: boneBase,
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCardBone extends StatelessWidget {
  final Color cardBg;
  final Color boneBase;

  const _ReviewCardBone({required this.cardBg, required this.boneBase});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: boneBase,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(height: 12, width: 90, boneBase: boneBase),
                  const SizedBox(height: 5),
                  _Bone(height: 10, width: 60, boneBase: boneBase),
                ],
              ),
              const Spacer(),
              _Bone(height: 12, width: 38, boneBase: boneBase),
            ],
          ),
          const SizedBox(height: 10),
          _Bone(height: 11, widthFactor: 0.95, boneBase: boneBase),
          const SizedBox(height: 5),
          _Bone(height: 11, widthFactor: 0.72, boneBase: boneBase),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Bone extends StatelessWidget {
  final double height;
  final Color boneBase;
  final double? width;
  final double? widthFactor;
  final double borderRadius;

  const _Bone({
    required this.height,
    required this.boneBase,
    this.width,
    this.widthFactor,
    this.borderRadius = 5,
  });

  @override
  Widget build(BuildContext context) {
    Widget box = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: boneBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    if (widthFactor != null) {
      box = FractionallySizedBox(widthFactor: widthFactor, child: box);
    }

    return box;
  }
}
