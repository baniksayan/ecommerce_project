import 'dart:async';
import 'dart:ui';

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
import '../cart/cart_view.dart';
import '../home/home_widgets.dart';
import '../main/main_view.dart';
import '../product_listing/product_listing_view.dart';
import 'reviews_view.dart';
import 'widgets/product_details_skeleton.dart';

const String _fallbackImageAsset = 'assets/logo/mandal_logo.png';

bool _isUnsplashDemoUrl(String value) => value.contains('images.unsplash.com');

bool _isHttpUrl(String value) =>
    value.startsWith('http://') || value.startsWith('https://');

ImageProvider _resolveImageProvider(String source) {
  final value = source.trim();
  if (value.isEmpty || _isUnsplashDemoUrl(value) || !_isHttpUrl(value)) {
    return const AssetImage(_fallbackImageAsset);
  }
  return NetworkImage(value);
}

// ═══════════════════════════════════════════════════════════════════════════════
// ProductDetailsView
// ═══════════════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════════════════════════
// State
// ═══════════════════════════════════════════════════════════════════════════════

class _ProductDetailsViewState extends State<ProductDetailsView>
    with TickerProviderStateMixin {
  late final ProductDetailsViewModel _vm;
  late final PageController _pageController;
  late final AnimationController _firePulseController;
  late final Animation<double> _firePulse;

  bool _descExpanded = true;
  int _activeImageIndex = 0;

  bool _wishlistPulse = false;
  bool _addToCartPulse = false;
  bool _isAddingToCart = false;
  bool _sharePulse = false;
  bool _shareShown = false;

  // Skeleton stays visible for a minimum of 1.8 s (static timing).
  // Switch to API loading duration once live network calls are in place.
  bool _skeletonVisible = true;
  Timer? _skeletonTimer;

  final GlobalKey _reviewsKey = GlobalKey();

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

    // Enforce minimum skeleton visibility so the shimmer is readable
    _skeletonTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _skeletonVisible = false);
    });

    _firePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _firePulse = Tween<double>(begin: 0.75, end: 1.25).animate(
      CurvedAnimation(parent: _firePulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _skeletonTimer?.cancel();
    _firePulseController.dispose();
    _pageController.dispose();
    _vm.dispose();
    super.dispose();
  }

  // ── Pulse helpers ─────────────────────────────────────────────────────────

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

  // ── Handlers ──────────────────────────────────────────────────────────────

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
    if (_shareShown) return;
    _shareShown = true;
    HapticFeedback.selectionClick();
    _pulseShare();
    AppSnackbar.info(context, 'Sharing coming soon');
    Future<void>.delayed(const Duration(seconds: 5), () {
      _shareShown = false;
    });
  }

  void _scrollToReviews() {
    final ctx = _reviewsKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      alignment: 0.05,
    );
  }

  void _showAllReviews() {
    Navigator.of(context).push(
      PlatformHelper.isIOS
          ? CupertinoPageRoute<void>(
              builder: (_) => AllReviewsView(product: widget.product),
            )
          : MaterialPageRoute<void>(
              builder: (_) => AllReviewsView(product: widget.product),
            ),
    );
  }

  void _goToCart() {
    Navigator.of(context).push(
      PlatformHelper.isIOS
          ? CupertinoPageRoute<void>(
              builder: (_) =>
                  CartView(currentBottomBarIndex: widget.currentBottomBarIndex),
            )
          : MaterialPageRoute<void>(
              builder: (_) =>
                  CartView(currentBottomBarIndex: widget.currentBottomBarIndex),
            ),
    );
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenW = MediaQuery.of(context).size.width;
    final isWide = screenW >= 600;

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
            onTap: (i) {
              if (i == widget.currentBottomBarIndex) {
                Navigator.of(context).maybePop();
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => MainView(initialIndex: i)),
                  (_) => false,
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
          body: _buildBody(theme, isWide),
        );
      },
    );
  }

  Widget _buildBody(ThemeData theme, bool isWide) {
    final onSurface = theme.colorScheme.onSurface;

    if (_vm.isLoading || _skeletonVisible) {
      return const ProductDetailsSkeleton();
    }

    if (_vm.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _vm.errorMessage ?? 'Something went wrong.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final outOfStock =
        widget.product.stockLeft != null && widget.product.stockLeft! <= 0;

    if (isWide) return _wideLayout(theme, outOfStock);
    return _narrowLayout(theme, outOfStock);
  }

  // ── Static banner content (reused across both layouts) ─────────────────
  static const _bannerImages = [
    'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
    'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800',
  ];
  static const _bannerTitles = [
    'Exclusive Deals Today',
    'Fresh Picks Just for You',
  ];
  static const _bannerSubtitles = [
    'Save big on top-rated products.',
    'Handpicked based on your taste.',
  ];

  // ── Mobile single-column ─────────────────────────────────────────────────

  Widget _narrowLayout(ThemeData theme, bool outOfStock) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _imageSection()),
            SliverToBoxAdapter(child: _infoSection(theme)),
            if (_vm.similarProducts.isNotEmpty) ..._youMightAlsoLikeSlivers(),
            if (_vm.recommendedProducts.isNotEmpty) ..._recommendedSlivers(),
            if (_vm.categorySearchProducts.isNotEmpty)
              ..._categorySearchSlivers(),
            const SliverToBoxAdapter(child: SizedBox(height: 104)),
          ],
        ),
        _positionedBottomBar(theme, outOfStock),
      ],
    );
  }

  // ── Tablet two-column ────────────────────────────────────────────────────

  Widget _wideLayout(ThemeData theme, bool outOfStock) {
    final screenW = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: (screenW * 0.42).clamp(240.0, 480.0),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 104),
                physics: const BouncingScrollPhysics(),
                child: _imageSection(tabletMode: true),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _infoSection(theme, tabletMode: true),
                  ),
                  if (_vm.similarProducts.isNotEmpty)
                    ..._youMightAlsoLikeSlivers(),
                  if (_vm.recommendedProducts.isNotEmpty)
                    ..._recommendedSlivers(),
                  if (_vm.categorySearchProducts.isNotEmpty)
                    ..._categorySearchSlivers(),
                  const SliverToBoxAdapter(child: SizedBox(height: 104)),
                ],
              ),
            ),
          ],
        ),
        _positionedBottomBar(theme, outOfStock),
      ],
    );
  }

  // ── Section builders ──────────────────────────────────────────────────────

  Widget _imageSection({bool tabletMode = false}) {
    return _ImageGallery(
      imageUrls: _vm.imageUrls,
      pageController: _pageController,
      activeIndex: _activeImageIndex,
      onPageChanged: (i) => setState(() => _activeImageIndex = i),
      onZoomTap: (url) => ZoomableImageViewer.show(
        context,
        imageProvider: _resolveImageProvider(url),
      ),
      isWishlisted: _vm.isWishlisted,
      wishlistPulse: _wishlistPulse,
      onWishlistTap: _handleToggleWishlist,
      sharePulse: _sharePulse,
      onShareTap: _handleShare,
      discountTag: widget.product.discountTag,
      showFastDelivery: widget.product.isFastDelivery == true,
      aspectRatio: tabletMode ? 0.85 : 0.95,
    );
  }

  Widget _infoSection(ThemeData theme, {bool tabletMode = false}) {
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.primaryColor;
    final discountColor = isDark ? AppColors.darkError : AppColors.lightError;
    final warningColor = isDark
        ? AppColors.darkWarning
        : AppColors.lightWarning;
    final successColor = isDark
        ? AppColors.darkSuccess
        : AppColors.lightSuccess;
    final infoColor = isDark ? AppColors.darkInfo : AppColors.lightInfo;
    // Highlight colour for "Only X left" — vibrant amber, distinct from yellow
    final lowStockColor = isDark
        ? AppColors.darkLowStock
        : AppColors.lightLowStock;

    final product = widget.product;
    final outOfStock = product.stockLeft != null && product.stockLeft! <= 0;
    final lowStock =
        product.stockLeft != null && product.stockLeft! <= 5 && !outOfStock;
    final hPad = tabletMode ? 20.0 : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category chip + Low Stock badge (inline) ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.category.displayName,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (lowStock) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: lowStockColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _firePulse,
                        child: Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 13,
                          color: lowStockColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Only ${product.stockLeft} left',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: lowStockColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // ── Product name ──
          Text(
            product.name,
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.bold,
              color: onSurface,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 10),

          // ── Rating badge + review count (tappable → scroll to reviews) ──
          if (product.rating != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: _scrollToReviews,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: warningColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.rating!.toStringAsFixed(1),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (product.reviewCount != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${product.reviewCount} reviews',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: onSurface.withValues(alpha: 0.35),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // ── Price section ──
          _PriceDisplay(
            price: product.price,
            originalPrice: product.originalPrice,
            discountTag: product.discountTag,
          ),

          const SizedBox(height: 16),

          // ── Status pills (out-of-stock only; Fast Delivery is on the image) ──
          if (outOfStock)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _StatusPill(
                icon: Icons.cancel_outlined,
                label: 'Out of Stock',
                color: discountColor,
                backgroundColor: discountColor.withValues(alpha: 0.1),
              ),
            ),

          // ── Delivery & Expiry info tiles ──
          Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 18,
                        color: infoColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              outOfStock ? 'Up to 24 hrs' : '30–45 min',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Delivery*',
                              style: AppTextStyles.caption.copyWith(
                                color: onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 18,
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '12 Aug 2026',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Expiry',
                              style: AppTextStyles.caption.copyWith(
                                color: onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '*Delivery time may vary. Holidays not included.',
              style: AppTextStyles.caption.copyWith(
                color: onSurface.withValues(alpha: 0.4),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Expandable product details (table layout, expanded by default) ──
          AppCard.action(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _descExpanded = !_descExpanded);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Product Details',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _descExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _ProductDetailsTable(
                      product: product,
                      outOfStock: outOfStock,
                      dividerColor: theme.dividerColor,
                      onSurface: onSurface,
                      successColor: successColor,
                      errorColor: discountColor,
                    ),
                  ),
                  crossFadeState: _descExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                  sizeCurve: Curves.easeOut,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Customer Reviews (keyed for scroll-to) ──
          _buildReviewsSection(theme),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  SliverToBoxAdapter _similarHeader(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: EcommerceSectionTitle(
          title: 'You might also like',
          actionText: 'See All',
          onActionTap: () {
            Navigator.of(context).push(
              ProductListingView.route(
                category: widget.product.category,
                currentBottomBarIndex: widget.currentBottomBarIndex,
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Section sliver groups ─────────────────────────────────────────────────

  List<Widget> _youMightAlsoLikeSlivers() => [
    _similarHeader(Theme.of(context)),
    SliverToBoxAdapter(child: _productCarousel(_vm.similarProducts)),
    SliverToBoxAdapter(
      child: EcommerceOfferBanner(
        title: _bannerTitles[0],
        subtitle: _bannerSubtitles[0],
        imageUrl: _bannerImages[0],
        onTap: () {},
      ),
    ),
  ];

  List<Widget> _recommendedSlivers() => [
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: EcommerceSectionTitle(
          title: 'Recommended for You',
          actionText: 'See All',
          onActionTap: () {
            final allCats = ProductCategory.values;
            final nextCat = allCats[
              (widget.product.category.index + 1) % allCats.length
            ];
            Navigator.of(context).push(
              ProductListingView.route(
                category: nextCat,
                currentBottomBarIndex: widget.currentBottomBarIndex,
              ),
            );
          },
        ),
      ),
    ),
    SliverToBoxAdapter(child: _productCarousel(_vm.recommendedProducts)),
    SliverToBoxAdapter(
      child: EcommerceOfferBanner(
        title: _bannerTitles[1],
        subtitle: _bannerSubtitles[1],
        imageUrl: _bannerImages[1],
        onTap: () {},
      ),
    ),
  ];

  List<Widget> _categorySearchSlivers() => [
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: EcommerceSectionTitle(
          title:
              'Because you searched ${widget.product.category.displayName}',
          actionText: 'See All',
          onActionTap: () {
            Navigator.of(context).push(
              ProductListingView.route(
                category: widget.product.category,
                currentBottomBarIndex: widget.currentBottomBarIndex,
              ),
            );
          },
        ),
      ),
    ),
    SliverToBoxAdapter(child: _productCarousel(_vm.categorySearchProducts)),
  ];

  Widget _productCarousel(List<ProductModel> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 280,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) {
            final p = products[i];
            return SizedBox(
              width: 164,
              child: ProductGridCard(
                key: ValueKey(p.id),
                product: p,
                onTap: () => Navigator.of(context).push(
                  ProductDetailsView.route(
                    product: p,
                    currentBottomBarIndex: widget.currentBottomBarIndex,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _positionedBottomBar(ThemeData theme, bool outOfStock) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: _FrostedBottomBar(
        enabled: !outOfStock,
        inCart: _vm.isInCart,
        quantity: _vm.quantity,
        canDecrement: _vm.quantity > 1,
        isLoading: _isAddingToCart,
        pulse: _addToCartPulse,
        onAddToCart: _handleAddToCart,
        onIncrement: _incrementQty,
        onDecrement: _decrementQty,
        onGoToCart: _goToCart,
      ),
    );
  }

  // ── Customer Reviews section ───────────────────────────────────────────────

  Widget _buildReviewsSection(ThemeData theme) {
    final product = widget.product;
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final primary = theme.primaryColor;
    final warningColor = isDark
        ? AppColors.darkWarning
        : AppColors.lightWarning;
    final reviews = product.reviews;
    final reviewPreview = reviews.take(3).toList(growable: false);
    final avgRating =
        product.rating ??
        (reviews.isEmpty
            ? 0.0
            : reviews.fold<double>(0, (s, r) => s + r.rating) / reviews.length);
    final reviewCount = product.reviewCount ?? reviews.length;
    final hiddenReviewCount = (reviewCount - reviewPreview.length).clamp(
      0,
      9999,
    );

    return Column(
      key: _reviewsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            Text(
              'Customer Reviews',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, size: 15, color: warningColor),
                  const SizedBox(width: 4),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($reviewCount)',
                    style: AppTextStyles.caption.copyWith(
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'No reviews available for this product yet.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        if (reviews.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              reviewCount <= 3
                  ? 'Showing all customer feedback'
                  : 'Showing the latest 3 of $reviewCount reviews',
              style: AppTextStyles.caption.copyWith(
                color: onSurface.withValues(alpha: 0.52),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        // Individual review cards
        ...reviewPreview.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ReviewCard(entry: r),
          ),
        ),
        if (reviews.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _ReviewCtaCard(
              hiddenReviewCount: hiddenReviewCount,
              primary: primary,
              onSurface: onSurface,
              onTap: _showAllReviews,
            ),
          ),
      ],
    );
  }
}

class _ReviewCtaCard extends StatelessWidget {
  final int hiddenReviewCount;
  final Color primary;
  final Color onSurface;
  final VoidCallback onTap;

  const _ReviewCtaCard({
    required this.hiddenReviewCount,
    required this.primary,
    required this.onSurface,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primary.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.reviews_outlined,
                  size: 18,
                  color: primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'See all reviews',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Read $hiddenReviewCount more ${hiddenReviewCount == 1 ? 'review' : 'reviews'} from customers',
                      style: AppTextStyles.caption.copyWith(
                        color: onSurface.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 20, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Image Gallery — rounded carousel with floating overlays
// ═══════════════════════════════════════════════════════════════════════════════

class _ImageGallery extends StatelessWidget {
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
  final double aspectRatio;

  const _ImageGallery({
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
    this.aspectRatio = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final discountBase = isDark ? AppColors.darkError : AppColors.lightError;
    final successBase = isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
    final urls = imageUrls.isEmpty ? const <String>[] : imageUrls;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(
                  alpha: isDark ? 0.25 : 0.10,
                ),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fallback background
                ColoredBox(color: theme.colorScheme.surfaceContainerHighest),

                // Image carousel
                if (urls.isNotEmpty)
                  PageView.builder(
                    controller: pageController,
                    itemCount: urls.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (_, index) {
                      final url = urls[index];
                      return GestureDetector(
                        onTap: () => onZoomTap(url),
                        child: Hero(
                          tag: 'product_image_$url',
                          child: Image(
                            image: _resolveImageProvider(url),
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: theme.disabledColor,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                // Bottom gradient for overlay readability
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 80,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating overlays
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Top: discount badge + action column ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (discountTag != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: discountBase,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                discountTag!,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Column(
                            children: [
                              _ActionCircle(
                                icon: Icons.share_outlined,
                                onTap: onShareTap,
                                pulse: sharePulse,
                                surfaceColor: theme.colorScheme.surface
                                    .withValues(alpha: 0.88),
                                iconColor: onSurface.withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 8),
                              _ActionCircle(
                                icon: isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                onTap: onWishlistTap,
                                pulse: wishlistPulse,
                                surfaceColor: theme.colorScheme.surface
                                    .withValues(alpha: 0.88),
                                iconColor: isWishlisted
                                    ? discountBase
                                    : onSurface.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const Spacer(),

                      // ── Bottom: fast delivery + dots ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (showFastDelivery)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: successBase.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt_rounded,
                                    size: 14,
                                    color: successBase,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Fast Delivery',
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: successBase,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          if (urls.length > 1)
                            _DotIndicator(
                              count: urls.length,
                              activeIndex: activeIndex,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Action Circle — floating circle action button (share, wishlist)
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool pulse;
  final Color surfaceColor;
  final Color iconColor;

  const _ActionCircle({
    required this.icon,
    required this.onTap,
    required this.pulse,
    required this.surfaceColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pulse ? 0.88 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Material(
        color: surfaceColor,
        shape: const CircleBorder(),
        child: InkResponse(
          onTap: onTap,
          radius: 22,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              child: Icon(
                icon,
                key: ValueKey(icon),
                size: 20,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Dot Indicator — frosted pill with animated dots
// ═══════════════════════════════════════════════════════════════════════════════

class _DotIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _DotIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(count, (i) {
          final active = i == activeIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? theme.primaryColor
                  : theme.disabledColor.withValues(alpha: isDark ? 0.5 : 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Price Display — price with discount styling
// ═══════════════════════════════════════════════════════════════════════════════

class _PriceDisplay extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final String? discountTag;

  const _PriceDisplay({
    required this.price,
    this.originalPrice,
    this.discountTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final hasDiscount = originalPrice != null && originalPrice! > price;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        Text(
          AppCurrency.format(price),
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.primaryColor,
          ),
        ),
        if (hasDiscount)
          Text(
            AppCurrency.format(originalPrice!),
            style: AppTextStyles.bodyLarge.copyWith(
              decoration: TextDecoration.lineThrough,
              color: onSurface.withValues(alpha: 0.45),
              fontWeight: FontWeight.w500,
            ),
          ),
        if (discountTag != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              discountTag!,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Status Pill — colored badge for stock / delivery status
// ═══════════════════════════════════════════════════════════════════════════════

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;

  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Quantity Pill — modern inline quantity selector
// ═══════════════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════════════
// Product Details Table — clean table-style key-value layout
// ═══════════════════════════════════════════════════════════════════════════════

class _ProductDetailsTable extends StatelessWidget {
  final ProductModel product;
  final bool outOfStock;
  final Color dividerColor;
  final Color onSurface;
  final Color successColor;
  final Color errorColor;

  const _ProductDetailsTable({
    required this.product,
    required this.outOfStock,
    required this.dividerColor,
    required this.onSurface,
    required this.successColor,
    required this.errorColor,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      _TableEntry('Category', product.category.displayName),
      _TableEntry('Pack Size', '1 unit'),
      _TableEntry('Origin', 'Locally sourced'),
      if (product.stockLeft != null)
        _TableEntry(
          'Availability',
          outOfStock ? 'Out of stock' : '${product.stockLeft} units available',
          valueColor: outOfStock ? errorColor : successColor,
        ),
      if (product.isFastDelivery == true)
        _TableEntry('Delivery', 'Fast Delivery'),
    ];

    return Column(
      children: List.generate(rows.length, (i) {
        final entry = rows[i];
        final isLast = i == rows.length - 1;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 112,
                    child: Text(
                      entry.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: entry.valueColor ?? onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Divider(
                height: 1,
                thickness: 0.7,
                color: dividerColor.withValues(alpha: 0.4),
              ),
          ],
        );
      }),
    );
  }
}

class _TableEntry {
  final String label;
  final String value;
  final Color? valueColor;

  const _TableEntry(this.label, this.value, {this.valueColor});
}

// ═══════════════════════════════════════════════════════════════════════════════
// Frosted Bottom Bar — frosted glass CTA bar
// ═══════════════════════════════════════════════════════════════════════════════

class _FrostedBottomBar extends StatelessWidget {
  final bool enabled;
  final bool inCart;
  final int quantity;
  final bool canDecrement;
  final bool isLoading;
  final bool pulse;
  final Future<void> Function() onAddToCart;
  final Future<void> Function() onIncrement;
  final Future<void> Function() onDecrement;
  final VoidCallback onGoToCart;

  const _FrostedBottomBar({
    required this.enabled,
    required this.inCart,
    required this.quantity,
    required this.canDecrement,
    required this.isLoading,
    required this.pulse,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
    required this.onGoToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.25),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: inCart
                ? IntrinsicHeight(
                    child: Row(
                      children: [
                        // Quantity stepper — left
                        _BottomStepper(
                          quantity: quantity,
                          canDecrement: canDecrement,
                          onDecrement: () => onDecrement(),
                          onIncrement: () => onIncrement(),
                          theme: theme,
                        ),
                        const SizedBox(width: 12),
                        // Go to Cart button — right, same height as stepper
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: onGoToCart,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Go to Cart',
                                style: AppTextStyles.button.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : AnimatedScale(
                    scale: pulse ? 0.97 : 1.0,
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
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Bottom Stepper — quantity stepper inside the bottom bar
// ═══════════════════════════════════════════════════════════════════════════════

class _BottomStepper extends StatelessWidget {
  final int quantity;
  final bool canDecrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ThemeData theme;

  const _BottomStepper({
    required this.quantity,
    required this.canDecrement,
    required this.onDecrement,
    required this.onIncrement,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final border = theme.dividerColor.withValues(alpha: isDark ? 0.40 : 0.55);
    final onSurface = theme.colorScheme.onSurface;

    return SizedBox(
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: canDecrement ? onDecrement : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.remove_rounded,
                  size: 18,
                  color: canDecrement
                      ? onSurface.withValues(alpha: 0.9)
                      : theme.disabledColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                quantity.toString(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                ),
              ),
            ),
            InkWell(
              onTap: onIncrement,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: onSurface.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
