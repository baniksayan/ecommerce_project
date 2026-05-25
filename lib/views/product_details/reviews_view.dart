import 'package:flutter/material.dart';

import '../../common/appbar/common_app_bar.dart';
import '../../common/cards/app_card.dart';
import '../../core/auth/auth_guard.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../models/list_review_model.dart';
import '../../services/api_service.dart';

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
  final ApiService _apiService = ApiService();

  int _sortIndex = 0;
  bool _isLoading = true;
  String? _loadError;
  List<_UiReview> _reviews = const <_UiReview>[];

  static const _sortLabels = ['Most Helpful', 'Latest', 'Positive', 'Negative'];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  int? get _productId => int.tryParse(widget.product.id);

  Future<void> _loadReviews() async {
    final productId = _productId;
    if (productId == null) {
      setState(() {
        _isLoading = false;
        _loadError = 'Unable to load reviews: invalid product id.';
        _reviews = _fallbackReviews();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final response = await _apiService.getReviewsList(productId: productId);
      final mapped = (response.data ?? const <ReviewData>[])
          .where(_shouldRenderReview)
          .map(_mapApiReview)
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _reviews = mapped;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString();
        _reviews = _fallbackReviews();
      });
    }
  }

  bool _shouldRenderReview(ReviewData review) {
    final status = (review.status ?? '').trim().toLowerCase();
    if (status.isEmpty) return true;
    return status == 'approved' ||
        status == 'active' ||
        status == 'published' ||
        status == '1';
  }

  _UiReview _mapApiReview(ReviewData review) {
    final rating = (review.rating ?? 0).clamp(1, 5);
    final title = (review.title ?? '').trim();
    final comment = (review.comment ?? '').trim();
    final body = [
      if (title.isNotEmpty) title,
      if (comment.isNotEmpty) comment,
    ].join(' - ').trim();

    return _UiReview(
      id: review.id?.toString() ?? '',
      name: (review.userName ?? '').trim().isEmpty
          ? 'Anonymous User'
          : review.userName!.trim(),
      rating: rating,
      text: body.isEmpty ? 'No review text provided.' : body,
      title: title,
      isVerified: true,
      daysAgo: _daysAgoFromIso(review.createdAt),
      createdAt: review.createdAt,
    );
  }

  List<_UiReview> _fallbackReviews() {
    return widget.product.reviews
        .asMap()
        .entries
        .map(
          (entry) => _UiReview(
            id: 'local-${entry.key}',
            name: entry.value.name,
            rating: entry.value.rating,
            text: entry.value.text,
            title: null,
            isVerified: entry.value.isVerified,
            daysAgo: entry.value.daysAgo,
            createdAt: null,
          ),
        )
        .toList(growable: false);
  }

  int _daysAgoFromIso(String? iso) {
    if ((iso ?? '').trim().isEmpty) return 0;
    final parsed = DateTime.tryParse(iso!.trim());
    if (parsed == null) return 0;
    final now = DateTime.now();
    final diff = now.difference(parsed.toLocal()).inDays;
    return diff < 0 ? 0 : diff;
  }

  DateTime _safeDate(_UiReview review) {
    final parsed = DateTime.tryParse((review.createdAt ?? '').trim());
    if (parsed != null) return parsed;
    return DateTime.now().subtract(Duration(days: review.daysAgo));
  }

  List<_UiReview> get _sortedReviews {
    final list = List<_UiReview>.from(_reviews);
    switch (_sortIndex) {
      case 0:
        list.sort((a, b) {
          final ratingCmp = b.rating.compareTo(a.rating);
          if (ratingCmp != 0) return ratingCmp;
          return _safeDate(b).compareTo(_safeDate(a));
        });
      case 1:
        list.sort((a, b) => _safeDate(b).compareTo(_safeDate(a)));
      case 2:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case 3:
        list.sort((a, b) => a.rating.compareTo(b.rating));
    }
    return list;
  }

  List<int> get _distribution {
    final reviews = _reviews;
    return List.generate(
      5,
      (i) => reviews.where((r) => r.rating == 5 - i).length,
    );
  }

  double get _avgRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<int>(0, (sum, rv) => sum + rv.rating);
    return total / _reviews.length;
  }

  int get _totalRatings => _reviews.length;

  Future<void> _openAddReviewSheet() async {
    final productId = _productId;
    if (productId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid product id for review submission.'),
        ),
      );
      return;
    }

    final allowed = await handleProtectedAction(context);
    if (!allowed || !mounted) return;

    final submittedMessage = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AddReviewSheet(
        onSubmit: (rating, title, comment) {
          return _apiService.addReview(
            productId: productId,
            rating: rating,
            title: title,
            comment: comment,
          );
        },
      ),
    );

    if (!mounted) return;
    if (submittedMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(submittedMessage)));
      await _loadReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = theme.colorScheme.outline.withValues(alpha: 0.15);
    final reviews = _sortedReviews;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(title: 'All Reviews'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddReviewSheet,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Add Review'),
      ),
      body: _isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : reviews.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No reviews available for this product yet.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_loadError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _loadError!,
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: _loadReviews,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                if (_loadError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Using fallback data. ${_loadError!}',
                          style: AppTextStyles.caption.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _RatingSummaryCard(
                      avgRating: _avgRating,
                      totalRatings: _totalRatings,
                      reviewCount: _reviews.length,
                      distribution: _distribution,
                    ),
                  ),
                ),

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

                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 90 + bottomInset),
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

class _AddReviewSheet extends StatefulWidget {
  const _AddReviewSheet({required this.onSubmit});

  final Future<dynamic> Function(int rating, String title, String comment)
  onSubmit;

  @override
  State<_AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends State<_AddReviewSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty || _selectedRating <= 0 || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final title = _titleController.text.trim();
      final result = await widget.onSubmit(
        _selectedRating,
        title.isEmpty ? 'Review' : title,
        comment,
      );

      if (!mounted) return;
      final success = result?.success == true;
      final message = (result?.message ?? '').toString().trim();

      if (success) {
        Navigator.of(
          context,
        ).pop(message.isEmpty ? 'Review submitted successfully.' : message);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isEmpty ? 'Could not submit review.' : message),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canSubmit =
        _selectedRating > 0 && _commentController.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Write a review',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Your rating',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final starValue = i + 1;
                final active = starValue <= _selectedRating;
                return IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => setState(() {
                          _selectedRating = starValue;
                        }),
                  icon: Icon(
                    active ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: active
                        ? (theme.brightness == Brightness.dark
                              ? AppColors.darkWarning
                              : AppColors.lightWarning)
                        : theme.disabledColor,
                    size: 28,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              enabled: !_isSubmitting,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              enabled: !_isSubmitting,
              maxLines: 4,
              minLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Your review',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSubmit && !_isSubmitting ? _handleSubmit : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UiReview {
  final String id;
  final String name;
  final int rating;
  final String text;
  final String? title;
  final bool isVerified;
  final int daysAgo;
  final String? createdAt;

  const _UiReview({
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
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
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
            padding: EdgeInsets.only(right: index < labels.length - 1 ? 8 : 0),
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
    final warningColor = isDark
        ? AppColors.darkWarning
        : AppColors.lightWarning;
    final successColor = isDark
        ? AppColors.darkSuccess
        : AppColors.lightSuccess;

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
                    '$totalRatings ratings\\n& $reviewCount reviews',
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
  final _UiReview entry;

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
