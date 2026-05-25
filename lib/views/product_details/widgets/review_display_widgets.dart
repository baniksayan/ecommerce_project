import 'package:flutter/material.dart';

import '../../../common/cards/app_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ReviewDisplayEntry {
  final String id;
  final String name;
  final int rating;
  final String text;
  final String? title;
  final bool isVerified;
  final int daysAgo;
  final String? createdAt;

  const ReviewDisplayEntry({
    required this.id,
    required this.name,
    required this.rating,
    required this.text,
    required this.title,
    required this.isVerified,
    required this.daysAgo,
    required this.createdAt,
  });

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  String get timeAgo {
    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yesterday';
    if (daysAgo < 7) return '$daysAgo days ago';
    if (daysAgo < 14) return '1 week ago';
    if (daysAgo < 30) return '${daysAgo ~/ 7} weeks ago';
    final months = daysAgo ~/ 30;
    return '$months month${months > 1 ? 's' : ''} ago';
  }
}

class RatingSummaryCard extends StatelessWidget {
  final double avgRating;
  final int totalRatings;
  final int reviewCount;
  final List<int> distribution;

  const RatingSummaryCard({
    super.key,
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
    final warningColor = isDark ? AppColors.darkWarning : AppColors.lightWarning;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;

    return AppCard(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            VerticalDivider(
              width: 24,
              thickness: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
            ),
            Expanded(
              flex: 62,
              child: Column(
                children: List.generate(
                  5,
                  (i) => _RatingBar(
                    star: 5 - i,
                    count: i < distribution.length ? distribution[i] : 0,
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

class ReviewDisplayCard extends StatefulWidget {
  final ReviewDisplayEntry entry;

  const ReviewDisplayCard({super.key, required this.entry});

  @override
  State<ReviewDisplayCard> createState() => _ReviewDisplayCardState();
}

class _ReviewDisplayCardState extends State<ReviewDisplayCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.primaryColor;
    final warningColor = isDark ? AppColors.darkWarning : AppColors.lightWarning;
    final successColor = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
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
          if ((review.title ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                review.title!.trim(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
            ),
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
