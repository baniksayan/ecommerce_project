import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/bottombar/common_bottom_bar.dart';
import '../../common/buttons/cart_icon_button.dart';
import '../../common/searchbar/app_search_bar.dart';
import '../../core/cart/cart_coordinator.dart';
import '../../core/cart/cart_pricing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_currency.dart';
import '../../core/utils/platform_helper.dart';
import '../../core/tobacco/tobacco_keyword_matcher.dart';
import '../../core/tobacco/tobacco_search_redirector.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/static_product_repository.dart';
import '../../viewmodels/product_listing_viewmodel.dart';
import '../main/main_view.dart';

class ProductListingView extends StatefulWidget {
  final ProductCategory category;
  final int currentBottomBarIndex;
  final String? initialSearchQuery;

  const ProductListingView({
    super.key,
    required this.category,
    this.currentBottomBarIndex = 0,
    this.initialSearchQuery,
  });

  static Route<void> route({
    required ProductCategory category,
    int currentBottomBarIndex = 0,
    String? initialSearchQuery,
  }) {
    Widget builder(BuildContext _) => ProductListingView(
      category: category,
      currentBottomBarIndex: currentBottomBarIndex,
      initialSearchQuery: initialSearchQuery,
    );

    return PlatformHelper.isIOS
        ? CupertinoPageRoute<void>(builder: builder)
        : MaterialPageRoute<void>(builder: builder);
  }

  @override
  State<ProductListingView> createState() => _ProductListingViewState();
}

class _ProductListingViewState extends State<ProductListingView> {
  late final ProductListingViewModel _vm;
  late final ScrollController _scrollController;

  bool get _canPop => ModalRoute.of(context)?.canPop ?? false;

  @override
  void initState() {
    super.initState();
    _vm = ProductListingViewModel(
      repository: const StaticProductRepository(),
      category: widget.category,
    );

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    final initial = widget.initialSearchQuery;
    if (initial != null && initial.trim().isNotEmpty) {
      _vm.setSearchQuery(initial);
    }

    _vm.load();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!position.hasPixels) return;
    if (position.pixels >= position.maxScrollExtent - 520) {
      _vm.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _openSortPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final textPrimary = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;

        Widget buildTile(ProductSort sort) {
          final selected = _vm.sort == sort;

          return RadioListTile<ProductSort>(
            value: sort,
            groupValue: _vm.sort,
            onChanged: (v) {
              if (v == null) return;
              HapticFeedback.selectionClick();
              Navigator.pop(ctx);
              _vm.setSort(v);
            },
            title: Text(
              sort.label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            controlAffinity: ListTileControlAffinity.trailing,
            selected: selected,
          );
        }

        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sheetHeight = (constraints.maxHeight * 0.75)
                  .clamp(0.0, 420.0)
                  .toDouble();

              return SizedBox(
                height: sheetHeight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                        child: Text(
                          'Sort by',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(
                            decelerationRate: ScrollDecelerationRate.normal,
                          ),
                          children: [
                            for (final s in ProductSort.values) buildTile(s),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.primaryColor;

    final headerBg = theme.scaffoldBackgroundColor.withValues(alpha: 0.98);
    final topInset = MediaQuery.paddingOf(context).top;

    final searchBar = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: AppSearchBar(
        hintText: 'Search ${widget.category.searchHint}...',
        staticPrefix: 'Search ',
        initialText: widget.initialSearchQuery,
        onChanged: (q) {
          if (widget.category != ProductCategory.tobacco &&
              TobaccoKeywordMatcher.isTobaccoQuery(q)) {
            TobaccoSearchRedirector.maybeRedirect(
              context,
              q,
              currentBottomBarIndex: widget.currentBottomBarIndex,
            );
            return;
          }
          _vm.setSearchQuery(q);
        },
        onSubmitted: (q) {
          if (widget.category != ProductCategory.tobacco &&
              TobaccoKeywordMatcher.isTobaccoQuery(q)) {
            TobaccoSearchRedirector.maybeRedirect(
              context,
              q,
              currentBottomBarIndex: widget.currentBottomBarIndex,
            );
            return;
          }
          _vm.setSearchQuery(q);
        },
      ),
    );

    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          extendBody: false,
          backgroundColor: theme.scaffoldBackgroundColor,
          bottomNavigationBar: CommonBottomBar(
            currentIndex: widget.currentBottomBarIndex,
            onTap: (index) {
              if (index == widget.currentBottomBarIndex) {
                Navigator.pop(context);
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainView(initialIndex: index),
                  ),
                  (route) => false,
                );
              }
            },
            items: [
              CommonBottomBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
              ),
              CommonBottomBarItem(
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: 'Wishlist',
              ),
              CommonBottomBarItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Orders',
              ),
            ],
          ),
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  decelerationRate: ScrollDecelerationRate.normal,
                ),
                slivers: [
                  // ── Compact header (search + chips + sort) ──────────────
                  SliverAppBar(
                    backgroundColor: headerBg,
                    elevation: 0,
                    floating: true,
                    snap: true,
                    pinned: false,
                    primary: false,
                    automaticallyImplyLeading: false,
                    toolbarHeight: 0,
                    collapsedHeight: topInset + 100,
                    expandedHeight: topInset + 100,
                    flexibleSpace: Padding(
                      padding: EdgeInsets.fromLTRB(0, topInset + 3, 0, 3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Row(
                              children: [
                                if (_canPop)
                                  SizedBox(
                                    width: kToolbarHeight,
                                    height: kToolbarHeight,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: PlatformHelper.isIOS
                                          ? CupertinoNavigationBarBackButton(
                                              color: primary,
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).maybePop(),
                                            )
                                          : BackButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).maybePop(),
                                            ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 16),
                                Expanded(child: searchBar),
                                const SizedBox(width: 12),
                                CartIconButton(
                                  currentBottomBarIndex:
                                      widget.currentBottomBarIndex,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _QuickChipsRow(
                              selected: _vm.quickFilter,
                              onSelected: (f) {
                                HapticFeedback.selectionClick();
                                _vm.setQuickFilter(f);
                              },
                              onSortTap: () {
                                HapticFeedback.selectionClick();
                                _openSortPicker();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_vm.isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_vm.hasError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _vm.errorMessage ?? 'Something went wrong.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    _ProductGridSliver(products: _vm.filteredProducts),

                  if (_vm.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 18.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 84)),
                ],
              ),

              ValueListenableBuilder<int>(
                valueListenable: CartCoordinator.instance.itemCount,
                builder: (context, itemCount, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: CartCoordinator.instance.subtotal,
                    builder: (context, subtotal, _) {
                      final remaining = CartPricing.remainingForFreeDelivery(
                        subtotal,
                      );
                      final show = itemCount > 0 && remaining > 0;

                      return IgnorePointer(
                        ignoring: !show,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: SafeArea(
                            top: false,
                            minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              offset: show
                                  ? Offset.zero
                                  : const Offset(0, 0.25),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 160),
                                curve: Curves.easeOut,
                                opacity: show ? 1 : 0,
                                child: _FreeDeliveryCueBar(
                                  subtotal: subtotal,
                                  remaining: remaining,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProductGridSliver extends StatelessWidget {
  final List<ProductModel> products;

  const _ProductGridSliver({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No products found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.58,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final p = products[index];
          return _ProductGridCard(
            key: ValueKey(p.id),
            product: p,
            onAddToCart: () {
              CartCoordinator.instance.addItem(
                CartItemModel(
                  productId: p.id,
                  name: p.name,
                  imageUrl: p.imageUrl,
                  unitPrice: p.price,
                  quantity: 1,
                ),
              );
            },
          );
        }, childCount: products.length),
      ),
    );
  }
}

class _QuickChipsRow extends StatelessWidget {
  final ProductQuickFilter selected;
  final ValueChanged<ProductQuickFilter> onSelected;
  final VoidCallback onSortTap;

  const _QuickChipsRow({
    required this.selected,
    required this.onSelected,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final selectedBg = theme.primaryColor.withValues(alpha: 0.10);
    final selectedBorder = theme.primaryColor.withValues(alpha: 0.22);
    final unselectedBorder = theme.dividerColor.withValues(alpha: 0.70);

    Widget sortChip() {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sort, size: 16, color: theme.primaryColor),
              const SizedBox(width: 6),
              Text(
                'Sort',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          selected: false,
          onSelected: (_) => onSortTap(),
          backgroundColor: theme.colorScheme.surface,
          side: BorderSide(color: unselectedBorder, width: 1),
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          showCheckmark: false,
          shape: const StadiumBorder(),
        ),
      );
    }

    Widget chip(ProductQuickFilter filter) {
      final isSelected = filter == selected;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(
            filter.label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(filter),
          selectedColor: selectedBg,
          backgroundColor: theme.colorScheme.surface,
          side: BorderSide(
            color: isSelected ? selectedBorder : unselectedBorder,
            width: 1,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 10),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          showCheckmark: false,
          shape: const StadiumBorder(),
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.normal,
              ),
              child: Row(
                children: [
                  sortChip(),
                  for (final f in ProductQuickFilter.values) chip(f),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeDeliveryCueBar extends StatelessWidget {
  final double subtotal;
  final double remaining;

  const _FreeDeliveryCueBar({required this.subtotal, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = theme.colorScheme.surface;
    final border = theme.dividerColor.withValues(alpha: isDark ? 0.32 : 0.40);
    final accent = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;
    final info = isDark ? AppColors.darkInfo : AppColors.lightInfo;

    final progress = (subtotal / CartPricing.freeDeliveryThreshold)
        .clamp(0.0, 1.0)
        .toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: 0.7),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: isDark ? 0.22 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, size: 16, color: info),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add ${AppCurrency.format(remaining, decimals: 0, freeForZero: false)} more for free delivery',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: accent.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGridCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const _ProductGridCard({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<_ProductGridCard> createState() => _ProductGridCardState();
}

class _ProductGridCardState extends State<_ProductGridCard> {
  bool _inCart = false;
  bool _isWishlisted = false;
  bool _justAddedPulse = false;

  void _handleAddToCart() {
    if (_inCart) return;
    HapticFeedback.heavyImpact();
    setState(() => _inCart = true);
    _pulseAdded();
    widget.onAddToCart();
  }

  void _pulseAdded() {
    if (!mounted) return;
    setState(() => _justAddedPulse = true);
    Future<void>.delayed(const Duration(milliseconds: 140), () {
      if (!mounted) return;
      setState(() => _justAddedPulse = false);
    });
  }

  void _toggleWishlist() {
    HapticFeedback.heavyImpact();
    setState(() => _isWishlisted = !_isWishlisted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final discountBase = isDark ? AppColors.darkError : AppColors.lightError;
    final discountBg = discountBase.withValues(alpha: 0.92);
    final wishlistActive = discountBase;
    final warning = isDark ? AppColors.darkWarning : AppColors.lightWarning;
    final fastDeliveryAccent = isDark
        ? AppColors.darkSuccess
        : AppColors.lightSuccess;
    final fastDeliveryBg = theme.colorScheme.surface.withValues(alpha: 0.86);

    final hasDiscount =
        widget.product.originalPrice != null &&
        widget.product.originalPrice! > widget.product.price;

    final rating = widget.product.rating;
    final reviewCount = widget.product.reviewCount;

    final cardBase = theme.colorScheme.surfaceContainerHighest;
    final cardRadius = BorderRadius.circular(20);
    final cardBorder = theme.colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.30 : 0.75,
    );
    final inCartBorder = theme.primaryColor.withValues(alpha: 0.55);

    final inCartBg = Color.alphaBlend(
      theme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
      cardBase,
    );

    final bool showLowStock =
        widget.product.stockLeft != null && widget.product.stockLeft! <= 5;
    final bool showFastDelivery = widget.product.isFastDelivery == true;
    final int nameMaxLines = (rating != null && showLowStock) ? 1 : 2;

    Widget tagPill({
      required String text,
      required Color background,
      required Color foreground,
      Color? border,
      EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
    }) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: border == null ? null : Border.all(color: border, width: 1),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return AnimatedScale(
      scale: _justAddedPulse ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Material(
        color: _inCart ? inCartBg : cardBase,
        elevation: isDark ? 1.2 : 2.0,
        shadowColor: theme.shadowColor.withValues(alpha: isDark ? 0.55 : 0.28),
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: _inCart ? inCartBorder : cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.08,
                      child: Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: theme.disabledColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.product.discountTag != null)
                                tagPill(
                                  text: widget.product.discountTag!,
                                  background: discountBg,
                                  foreground: theme.colorScheme.onError,
                                ),
                              const Spacer(),
                              Material(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.80,
                                ),
                                shape: const CircleBorder(),
                                child: InkResponse(
                                  onTap: _toggleWishlist,
                                  radius: 20,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      _isWishlisted
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 18,
                                      color: _isWishlisted
                                          ? wishlistActive
                                          : onSurface.withValues(alpha: 0.55),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (showFastDelivery)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: tagPill(
                                text: 'Fast Delivery',
                                background: fastDeliveryBg,
                                foreground: fastDeliveryAccent,
                                border: fastDeliveryAccent.withValues(
                                  alpha: 0.55,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: nameMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (rating != null)
                        Row(
                          children: [
                            Icon(Icons.star, size: 14, color: warning),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                            if (reviewCount != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '($reviewCount)',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.disabledColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (showLowStock) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Only ${widget.product.stockLeft} left',
                          style: AppTextStyles.caption.copyWith(
                            color: discountBase,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppCurrency.format(widget.product.price),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                    height: 1.05,
                                  ),
                                ),
                                if (hasDiscount)
                                  Text(
                                    AppCurrency.format(
                                      widget.product.originalPrice!,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      color: theme.disabledColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _AddToCartButton(
                            inCart: _inCart,
                            onTap: _handleAddToCart,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final bool inCart;
  final VoidCallback onTap;

  const _AddToCartButton({required this.inCart, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(12);

    return Material(
      color: theme.primaryColor,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            inCart
                ? Icons.local_grocery_store
                : Icons.local_grocery_store_outlined,
            color: theme.colorScheme.onPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
