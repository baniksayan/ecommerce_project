import 'package:flutter/material.dart';

import '../../common/appbar/common_app_bar.dart';
import '../../common/cards/app_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../data/models/product_review_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AllReviewsView
// ─────────────────────────────────────────────────────────────────────────────

class AllReviewsView extends StatefulWidget {
  final ProductModel product;

  const AllReviewsView({super.key, required this.product});

  @override
  State<AllReviewsView> createState() => _AllReviewsViewState();
}

class _AllReviewsViewState extends State<AllReviewsView> {
  int _sortIndex = 0;

  static const _sortLabels = ['Most Helpful', 'Latest', 'Positive', 'Negative'];

  // ── Derived data from ProductModel ────────────────────────────────────────

  List<ProductReviewModel> get _sortedReviews {
    final list = List<ProductReviewModel>.from(widget.product.reviews);
    switch (_sortIndex) {
      case 0: // Most Helpful — highest rating first; within same rating, most recent first
        list.sort((a, b) {
          final ratingCmp = b.rating.compareTo(a.rating);
          if (ratingCmp != 0) return ratingCmp;
          return a.daysAgo.compareTo(b.daysAgo);
        });
      case 1: // Latest — most recent first
        list.sort((a, b) => a.daysAgo.compareTo(b.daysAgo));
      case 2: // Positive — highest rating first
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 3: // Negative — lowest rating first
        list.sort((a, b) => a.rating.compareTo(b.rating));
    }
    return list;
  }

  /// Counts per star, index 0 = 5★ … index 4 = 1★.
  List<int> get _distribution {
    final reviews = widget.product.reviews;
    return List.generate(5, (i) => reviews.where((r) => r.rating == 5 - i).length);
  }

  double get _avgRating {
    final r = widget.product.rating;
    if (r != null) return r;
    final reviews = widget.product.reviews;
    if (reviews.isEmpty) return 0.0;
    return reviews.fold<double>(0, (s, rv) => s + rv.rating) / reviews.length;
  }

  int get _totalRatings => widget.product.reviewCount ?? widget.product.reviews.length;

  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.colorScheme.outline.withValues(alpha: 0.15);
    final reviews = _sortedReviews;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(title: 'All Reviews'),
      body: reviews.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'No reviews available for this product yet.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Rating summary card ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _RatingSummaryCard(
                      avgRating: _avgRating,
                      totalRatings: _totalRatings,
                      reviewCount: widget.product.reviews.length,
                      distribution: _distribution,
                    ),
                  ),
                ),

                // ── Sort section ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User reviews sorted by',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PillChipRow(
                          labels: _sortLabels,
                          selectedIndex: _sortIndex,
                          onSelect: (i) => setState(() => _sortIndex = i),
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, thickness: 1, color: dividerColor),
                      ],
                    ),
                  ),
                ),

                // ── Review cards ───────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ReviewCard(entry: reviews[i]),
                      ),
                      childCount: reviews.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PillChipRow — horizontally scrollable row of pill-shaped selector chips
// ─────────────────────────────────────────────────────────────────────────────

class _PillChipRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _PillChipRow({
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: labels.length,
        itemBuilder: (_, index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding:
                EdgeInsets.only(right: index < labels.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : onSurface.withValues(alpha: 0.25),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Text(
                  labels[index],
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? primary
                        : onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RatingSummaryCard — left: avg + stars + count | right: distribution bars
// ─────────────────────────────────────────────────────────────────────────────

class _RatingSummaryCard extends StatelessWidget {
  final double avgRating;
  final int totalRatings;
  final int reviewCount;

  /// Counts from 5★ (index 0) down to 1★ (index 4).
  final List<int> distribution;

  const _RatingSummaryCard({
    required this.avgRating,
    required this.totalRatings,
    required this.reviewCount,
    required this.distribution,
  });

  IconData _starIcon(int index) {
    if (index + 1 <= avgRating.floor()) return Icons.star_rounded;
    if (index < avgRating) return Icons.star_half_rounded;
    return Icons.star_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final warningColor =
        isDark ? AppColors.darkWarning : AppColors.lightWarning;
    final successColor =
        isDark ? AppColors.darkSuccess : AppColors.lightSuccess;

    return AppCard(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Left: average rating ──────────────────────────────────────
            Expanded(
              flex: 38,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        _starIcon(i),
                        size: 20,
                        color: i < avgRating
                            ? warningColor
                            : onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.w900,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalRatings ratings\n& $reviewCount reviews',
                    style: AppTextStyles.caption.copyWith(
                      color: onSurface.withValues(alpha: 0.55),
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Vertical divider ──────────────────────────────────────────
            VerticalDivider(
              width: 24,
              thickness: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),

            // ── Right: distribution bars ──────────────────────────────────
            Expanded(
              flex: 62,
              child: Column(
                children: List.generate(
                  5,
                  (i) => _RatingBar(
                    star: 5 - i,
                    count: distribution[i],
                    total: totalRatings,
                    barColor: successColor,
                    onSurface: onSurface,
                    warningColor: warningColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RatingBar — a single row in the distribution section
// ─────────────────────────────────────────────────────────────────────────────

class _RatingBar extends StatelessWidget {
  final int star;
  final int count;
  final int total;
  final Color barColor;
  final Color onSurface;
  final Color warningColor;

  const _RatingBar({
    required this.star,
    required this.count,
    required this.total,
    required this.barColor,
    required this.onSurface,
    required this.warningColor,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$star',
            style: AppTextStyles.caption.copyWith(
              color: onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 3),
          Icon(Icons.star_rounded, size: 11, color: warningColor),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: onSurface.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 26,
            child: Text(
              '$count',
              style: AppTextStyles.caption.copyWith(
                color: onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatefulWidget {
  final ProductReviewModel entry;

  const ReviewCard({super.key, required this.entry});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.primaryColor;
    final warningColor = isDark
        ? AppColors.darkWarning
        : AppColors.lightWarning;
    final successColor = isDark
        ? AppColors.darkSuccess
        : AppColors.lightSuccess;
    final review = widget.entry;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  review.initials,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: successColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Verified',
                              style: AppTextStyles.caption.copyWith(
                                color: successColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 13,
                            color: index < review.rating
                                ? warningColor
                                : onSurface.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          review.timeAgo,
                          style: AppTextStyles.caption.copyWith(
                            color: onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          const SizedBox(height: 10),
          _buildText(onSurface, primary),
        ],
      ),
    );
  }

  Widget _buildText(Color onSurface, Color primary) {
    final textStyle = AppTextStyles.bodyMedium.copyWith(
      color: onSurface.withValues(alpha: 0.75),
      height: 1.45,
    );
    final linkStyle = AppTextStyles.caption.copyWith(
      color: primary,
      fontWeight: FontWeight.w700,
    );

    if (_expanded) {
      return GestureDetector(
        onTap: () => setState(() => _expanded = false),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.entry.text, style: textStyle),
            const SizedBox(height: 2),
            Text('See less', style: linkStyle),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.entry.text, style: textStyle),
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (!textPainter.didExceedMaxLines) {
          return Text(widget.entry.text, style: textStyle);
        }

        const ellipsis = '... ';
        const seeMore = 'See more';
        var low = 0;
        var high = widget.entry.text.length;

        while (low < high) {
          final mid = (low + high + 1) ~/ 2;
          final testPainter = TextPainter(
            text: TextSpan(
              text: widget.entry.text.substring(0, mid) + ellipsis + seeMore,
              style: textStyle,
            ),
            maxLines: 2,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);

          if (testPainter.didExceedMaxLines) {
            high = mid - 1;
          } else {
            low = mid;
          }
        }

        return GestureDetector(
          onTap: () => setState(() => _expanded = true),
          behavior: HitTestBehavior.opaque,
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.clip,
            text: TextSpan(
              style: textStyle,
              children: [
                TextSpan(text: widget.entry.text.substring(0, low) + ellipsis),
                TextSpan(text: seeMore, style: linkStyle),
              ],
            ),
          ),
        );
      },
    );
  }
}
