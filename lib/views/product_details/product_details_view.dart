import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/appbar/common_search_cart_app_bar.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../../common/buttons/app_button.dart';
import '../../common/cards/app_card.dart';
import '../../common/cards/product_grid_card.dart';
import '../../common/image_viewer/zoomable_image_viewer.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_currency.dart';
import '../../core/utils/platform_helper.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/hive_cart_repository.dart';
import '../../data/repositories/hive_wishlist_repository.dart';
import '../../data/repositories/static_product_repository.dart';
import '../../viewmodels/product_details_viewmodel.dart';
import '../main/main_view.dart';

class ProductDetailsView extends StatefulWidget {
  final ProductModel product;
  final int currentBottomBarIndex;

  const ProductDetailsView({
    super.key,
    required this.product,
    required this.currentBottomBarIndex,
  });

  static Route<void> route({
    required ProductModel product,
    required int currentBottomBarIndex,
  }) {
    Widget builder(BuildContext _) => ProductDetailsView(
      product: product,
      currentBottomBarIndex: currentBottomBarIndex,
    );

    return PlatformHelper.isIOS
        ? CupertinoPageRoute<void>(builder: builder)
        : MaterialPageRoute<void>(builder: builder);
  }

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  late final ProductDetailsViewModel _vm;
  late final PageController _pageController;

  bool _detailsExpanded = false;
  int _activeImageIndex = 0;

  bool _wishlistPulse = false;
  bool _addToCartPulse = false;
  bool _isAddingToCart = false;
  bool _sharePulse = false;

  @override
  void initState() {
    super.initState();

    _vm = ProductDetailsViewModel(
      product: widget.product,
      productRepository: const StaticProductRepository(),
      cartRepository: HiveCartRepository(),
      wishlistRepository: HiveWishlistRepository(),
    );

    _pageController = PageController();

    _vm.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _pulseWishlist() {
    if (!mounted) return;
    setState(() => _wishlistPulse = true);
    Future<void>.delayed(const Duration(milliseconds: 140), () {
      if (!mounted) return;
      setState(() => _wishlistPulse = false);
    });
  }

  void _pulseAddToCart() {
    if (!mounted) return;
    setState(() => _addToCartPulse = true);
    Future<void>.delayed(const Duration(milliseconds: 140), () {
      if (!mounted) return;
      setState(() => _addToCartPulse = false);
    });
  }

  void _pulseShare() {
    if (!mounted) return;
    setState(() => _sharePulse = true);
    Future<void>.delayed(const Duration(milliseconds: 140), () {
      if (!mounted) return;
      setState(() => _sharePulse = false);
    });
  }

  Future<void> _handleToggleWishlist() async {
    HapticFeedback.selectionClick();
    _pulseWishlist();
    await _vm.toggleWishlist();
  }

  Future<void> _handleAddToCart() async {
    if (_isAddingToCart || _vm.isInCart) return;
    HapticFeedback.lightImpact();
    _pulseAddToCart();

    setState(() => _isAddingToCart = true);
    try {
      await _vm.addToCart();
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _handleShare() {
    HapticFeedback.selectionClick();
    _pulseShare();
    AppSnackbar.info(context, 'Sharing coming soon');
  }

  Future<void> _incrementQty() async {
    HapticFeedback.selectionClick();
    await _vm.incrementQuantity();
  }

  Future<void> _decrementQty() async {
    if (_vm.quantity <= 1) return;
    HapticFeedback.selectionClick();
    await _vm.decrementQuantity();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    final discountBase = isDark ? AppColors.darkError : AppColors.lightError;
    final ratingColor = isDark ? AppColors.darkWarning : AppColors.lightWarning;

    final bool showLowStock =
        widget.product.stockLeft != null && widget.product.stockLeft! <= 5;
    final bool showFastDelivery = widget.product.isFastDelivery == true;

    final outOfStock =
        widget.product.stockLeft != null && widget.product.stockLeft! <= 0;

    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: CommonSearchCartAppBar(
            searchHintText: 'Search ${widget.product.category.searchHint}...',
            searchStaticPrefix: 'Search ',
            currentBottomBarIndex: widget.currentBottomBarIndex,
            showBackButton: true,
          ),
          bottomNavigationBar: CommonBottomBar(
            currentIndex: widget.currentBottomBarIndex,
            onTap: (index) {
              if (index == widget.currentBottomBarIndex) {
                Navigator.of(context).maybePop();
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
          body: _vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _vm.hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _vm.errorMessage ?? 'Something went wrong.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Stack(
                  children: [
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(
                        decelerationRate: ScrollDecelerationRate.normal,
                      ),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _ProductImageSection(
                            imageUrls: _vm.imageUrls,
                            pageController: _pageController,
                            activeIndex: _activeImageIndex,
                            onPageChanged: (i) {
                              setState(() => _activeImageIndex = i);
                            },
                            onZoomTap: (url) {
                              ZoomableImageViewer.show(
                                context,
                                imageProvider: NetworkImage(url),
                              );
                            },
                            isWishlisted: _vm.isWishlisted,
                            wishlistPulse: _wishlistPulse,
                            onWishlistTap: _handleToggleWishlist,
                            sharePulse: _sharePulse,
                            onShareTap: _handleShare,
                            discountTag: widget.product.discountTag,
                            showFastDelivery: showFastDelivery,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: AppTextStyles.heading3.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (widget.product.rating != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 16,
                                        color: ratingColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.product.rating!.toStringAsFixed(
                                          1,
                                        ),
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: onSurface,
                                            ),
                                      ),
                                      if (widget.product.reviewCount != null)
                                        Text(
                                          ' (${widget.product.reviewCount} reviews)',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: onSurface.withValues(
                                                  alpha: 0.7,
                                                ),
                                              ),
                                        ),
                                    ],
                                  ),
                                const SizedBox(height: 12),
                                _PriceRow(
                                  price: widget.product.price,
                                  originalPrice: widget.product.originalPrice,
                                  discountTag: widget.product.discountTag,
                                ),
                                if (widget.product.stockLeft != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    outOfStock
                                        ? 'Out of stock'
                                        : showLowStock
                                        ? 'Only ${widget.product.stockLeft} left'
                                        : 'Stock: ${widget.product.stockLeft}',
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: outOfStock
                                          ? discountBase
                                          : onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                AppCard(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.event_outlined,
                                        size: 18,
                                        color: onSurface.withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Expiry: 12 Aug 2026',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: onSurface,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _QuantitySelector(
                                  quantity: _vm.quantity,
                                  canDecrement: _vm.quantity > 1,
                                  onDecrement: _decrementQty,
                                  onIncrement: _incrementQty,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: AppCard(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined,
                                    size: 18,
                                    color: isDark
                                        ? AppColors.darkInfo
                                        : AppColors.lightInfo,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          outOfStock
                                              ? 'Delivery may take up to 24 hours'
                                              : 'Delivery in 30–45 minutes',
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: onSurface,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '*Delivery time may vary. Holidays not included.',
                                          style: AppTextStyles.caption.copyWith(
                                            color: onSurface.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: AppCard.action(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(
                                  () => _detailsExpanded = !_detailsExpanded,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Product Details',
                                          style: AppTextStyles.bodyLarge
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: onSurface,
                                              ),
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: _detailsExpanded ? 0.5 : 0.0,
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        curve: Curves.easeOut,
                                        child: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: onSurface.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  AnimatedCrossFade(
                                    firstChild: const SizedBox.shrink(),
                                    secondChild: Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        _vm.productDescription,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: onSurface.withValues(
                                                alpha: 0.75,
                                              ),
                                              height: 1.35,
                                            ),
                                      ),
                                    ),
                                    crossFadeState: _detailsExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 180),
                                    sizeCurve: Curves.easeOut,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 18,
                                        color: ratingColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${widget.product.rating?.toStringAsFixed(1) ?? '--'} (${widget.product.reviewCount ?? 0} ratings)',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: onSurface,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Top review',
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: onSurface.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Great quality and fast delivery. Will order again!',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: onSurface.withValues(alpha: 0.75),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                            child: Text(
                              'Similar Products',
                              style: AppTextStyles.heading3.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                          ),
                        ),
                        if (_vm.similarProducts.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'No similar products found',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: onSurface.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          )
                        else
                          ProductGridSliver(
                            products: _vm.similarProducts,
                            onProductTap: (p) {
                              Navigator.of(context).push(
                                ProductDetailsView.route(
                                  product: p,
                                  currentBottomBarIndex:
                                      widget.currentBottomBarIndex,
                                ),
                              );
                            },
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 184)),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _BottomCartBar(
                          enabled: !outOfStock,
                          inCart: _vm.isInCart,
                          quantity: _vm.quantity,
                          canDecrement: _vm.quantity > 1,
                          isLoading: _isAddingToCart,
                          pulse: _addToCartPulse,
                          onAddToCart: _handleAddToCart,
                          onIncrement: _incrementQty,
                          onDecrement: _decrementQty,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ProductImageSection extends StatelessWidget {
  final List<String> imageUrls;
  final PageController pageController;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<String> onZoomTap;

  final bool isWishlisted;
  final bool wishlistPulse;
  final VoidCallback onWishlistTap;

  final bool sharePulse;
  final VoidCallback onShareTap;

  final String? discountTag;
  final bool showFastDelivery;

  const _ProductImageSection({
    required this.imageUrls,
    required this.pageController,
    required this.activeIndex,
    required this.onPageChanged,
    required this.onZoomTap,
    required this.isWishlisted,
    required this.wishlistPulse,
    required this.onWishlistTap,
    required this.sharePulse,
    required this.onShareTap,
    required this.discountTag,
    required this.showFastDelivery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;

    final discountBase = isDark ? AppColors.darkError : AppColors.lightError;
    final discountBg = discountBase.withValues(alpha: 0.92);

    final fastDeliveryAccent = isDark
        ? AppColors.darkSuccess
        : AppColors.lightSuccess;
    final fastDeliveryBg = theme.colorScheme.surface.withValues(alpha: 0.86);

    Widget tagPill(
      String text, {
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

    final urls = imageUrls.isEmpty ? const <String>[] : imageUrls;

    return AspectRatio(
      aspectRatio: 1.05,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: urls.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final url = urls[index];
              return GestureDetector(
                onTap: () => onZoomTap(url),
                child: Hero(
                  tag: 'product_image_$url',
                  child: Image.network(
                    url,
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
              );
            },
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (discountTag != null)
                        tagPill(
                          discountTag!,
                          background: discountBg,
                          foreground: theme.colorScheme.onError,
                        ),
                      const Spacer(),
                      AnimatedScale(
                        scale: sharePulse ? 0.92 : 1.0,
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOut,
                        child: Material(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.86,
                          ),
                          shape: const CircleBorder(),
                          child: InkResponse(
                            onTap: onShareTap,
                            radius: 22,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Icon(
                                Icons.share_outlined,
                                size: 20,
                                color: onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedScale(
                        scale: wishlistPulse ? 0.92 : 1.0,
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOut,
                        child: Material(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.86,
                          ),
                          shape: const CircleBorder(),
                          child: InkResponse(
                            onTap: onWishlistTap,
                            radius: 22,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 160),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeOut,
                                child: Icon(
                                  isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  key: ValueKey(isWishlisted),
                                  size: 20,
                                  color: isWishlisted
                                      ? discountBase
                                      : onSurface.withValues(alpha: 0.55),
                                ),
                              ),
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
                        'Fast Delivery',
                        background: fastDeliveryBg,
                        foreground: fastDeliveryAccent,
                        border: fastDeliveryAccent.withValues(alpha: 0.55),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  if (urls.length > 1)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _DotsIndicator(
                        count: urls.length,
                        activeIndex: activeIndex,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _DotsIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = theme.colorScheme.surface.withValues(alpha: 0.75);
    final dotOff = theme.disabledColor.withValues(alpha: isDark ? 0.6 : 0.5);
    final dotOn = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.35),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          final selected = i == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: selected ? 16 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: selected ? dotOn : dotOff,
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final String? discountTag;

  const _PriceRow({
    required this.price,
    required this.originalPrice,
    required this.discountTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    final hasDiscount = originalPrice != null && originalPrice! > price;

    return Row(
      children: [
        Text(
          AppCurrency.format(price),
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 10),
          Text(
            AppCurrency.format(originalPrice!),
            style: AppTextStyles.bodyMedium.copyWith(
              decoration: TextDecoration.lineThrough,
              color: onSurface.withValues(alpha: 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (discountTag != null) ...[
          const SizedBox(width: 10),
          Text(
            discountTag!,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final bool canDecrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantitySelector({
    required this.quantity,
    required this.canDecrement,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    Widget iconButton({
      required IconData icon,
      required bool enabled,
      required VoidCallback onTap,
    }) {
      return Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 18,
              color: enabled
                  ? onSurface.withValues(alpha: 0.85)
                  : theme.disabledColor,
            ),
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          iconButton(
            icon: Icons.remove,
            enabled: canDecrement,
            onTap: onDecrement,
          ),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                child: Text(
                  quantity.toString(),
                  key: ValueKey(quantity),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: onSurface,
                  ),
                ),
              ),
            ),
          ),
          iconButton(icon: Icons.add, enabled: true, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _BottomCartBar extends StatelessWidget {
  final bool enabled;
  final bool inCart;
  final int quantity;
  final bool canDecrement;
  final bool isLoading;
  final bool pulse;
  final Future<void> Function() onAddToCart;
  final Future<void> Function() onIncrement;
  final Future<void> Function() onDecrement;

  const _BottomCartBar({
    required this.enabled,
    required this.inCart,
    required this.quantity,
    required this.canDecrement,
    required this.isLoading,
    required this.pulse,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: SafeArea(
        top: false,
        bottom: false,
        child: inCart
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      'In Cart',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _BottomQuantityStepper(
                    quantity: quantity,
                    canDecrement: canDecrement,
                    onDecrement: () => onDecrement(),
                    onIncrement: () => onIncrement(),
                  ),
                ],
              )
            : AnimatedScale(
                scale: pulse ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                child: AppButton.primary(
                  text: 'Add to Cart',
                  isLoading: isLoading,
                  isFullWidth: true,
                  onPressed: enabled ? () => onAddToCart() : null,
                ),
              ),
      ),
    );
  }
}

class _BottomQuantityStepper extends StatelessWidget {
  final int quantity;
  final bool canDecrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _BottomQuantityStepper({
    required this.quantity,
    required this.canDecrement,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = theme.colorScheme.surface;
    final border = theme.dividerColor.withValues(alpha: isDark ? 0.40 : 0.55);
    final onSurface = theme.colorScheme.onSurface;

    Widget iconBtn({
      required IconData icon,
      required bool enabled,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: enabled
                ? onSurface.withValues(alpha: 0.9)
                : theme.disabledColor,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconBtn(
            icon: Icons.remove,
            enabled: canDecrement,
            onTap: onDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              quantity.toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: onSurface,
              ),
            ),
          ),
          iconBtn(icon: Icons.add, enabled: true, onTap: onIncrement),
        ],
      ),
    );
  }
}
