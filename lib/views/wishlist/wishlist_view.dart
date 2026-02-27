import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_currency.dart';
import '../../common/drawer/app_drawer.dart';
import '../../common/appbar/primary_sliver_app_bar.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../home/home_widgets.dart';
import '../main/main_view.dart';

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────

class WishlistItem {
  final String id;
  final String imageUrl;
  final String title;
  final double price;
  final double originalPrice;
  final String discountTag;
  final double rating;
  final int reviewCount;
  bool isAddedToCart;

  WishlistItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.discountTag,
    required this.rating,
    required this.reviewCount,
    this.isAddedToCart = false,
  });

  double get discountPercent =>
      ((originalPrice - price) / originalPrice * 100).roundToDouble();
}

// ─────────────────────────────────────────────
//  MAIN VIEW
// ─────────────────────────────────────────────

class WishlistView extends StatefulWidget {
  const WishlistView({Key? key}) : super(key: key);

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView>
    with TickerProviderStateMixin {
  String? _profilePicUrl;

  late AnimationController _emptyCtrl;
  late Animation<double> _floatAnimation;

  final List<WishlistItem> _wishlistItems = [
    WishlistItem(
      id: '1',
      imageUrl:
          'https://images.unsplash.com/photo-1583394838336-acd977736f90?auto=format&fit=crop&q=80&w=400',
      title: 'Premium Wireless Earbuds',
      price: 79.99,
      originalPrice: 129.99,
      discountTag: '38% OFF',
      rating: 4.6,
      reviewCount: 412,
    ),
    WishlistItem(
      id: '2',
      imageUrl:
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&q=80&w=400',
      title: 'Classic Sunglasses',
      price: 15.00,
      originalPrice: 40.00,
      discountTag: '62% OFF',
      rating: 4.2,
      reviewCount: 95,
    ),
    WishlistItem(
      id: '3',
      imageUrl:
          'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&q=80&w=400',
      title: 'Smart Watch Series 6',
      price: 199.99,
      originalPrice: 249.99,
      discountTag: '20% OFF',
      rating: 4.6,
      reviewCount: 382,
    ),
    WishlistItem(
      id: '4',
      imageUrl:
          'https://images.unsplash.com/photo-1491553895911-0055eca6402d?auto=format&fit=crop&q=80&w=400',
      title: 'Running Sneakers Pro',
      price: 89.99,
      originalPrice: 120.00,
      discountTag: '25% OFF',
      rating: 4.8,
      reviewCount: 217,
    ),
  ];

  final List<Map<String, dynamic>> _recommendedItems = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
      'title': 'Premium Headphones',
      'price': 199.99,
      'rating': 4.8,
      'reviewCount': 120,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
      'title': 'Smart Watch',
      'price': 129.50,
      'rating': 4.5,
      'reviewCount': 85,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
      'title': 'Running Shoes',
      'price': 89.99,
      'rating': 4.7,
      'reviewCount': 214,
    },
  ];

  @override
  void initState() {
    super.initState();
    _emptyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(parent: _emptyCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _emptyCtrl.dispose();
    super.dispose();
  }

  double get _totalSavings => _wishlistItems.fold(
    0,
    (sum, item) => sum + (item.originalPrice - item.price),
  );

  double get _totalWishlistValue =>
      _wishlistItems.fold(0, (sum, item) => sum + item.price);

  void _removeItem(WishlistItem item) {
    HapticFeedback.heavyImpact();
    setState(() => _wishlistItems.removeWhere((e) => e.id == item.id));
    AppSnackbar.destructive(
      context,
      '${item.title} removed',
      duration: const Duration(seconds: 1),
    );
  }

  void _addToCart(WishlistItem item) {
    HapticFeedback.heavyImpact();
    setState(() => item.isAddedToCart = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        item.isAddedToCart = false;
        _wishlistItems.removeWhere((e) => e.id == item.id);
      });
      AppSnackbar.success(context, '${item.title} added to cart');
    });
  }

  void _addAllToCart() {
    HapticFeedback.heavyImpact();
    final itemCount = _wishlistItems.length;
    setState(() {
      for (final item in _wishlistItems) {
        item.isAddedToCart = true;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _wishlistItems.clear();
      });
      AppSnackbar.success(context, '$itemCount items added to cart');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = _wishlistItems.isEmpty;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppDrawer(
        profilePicUrl: _profilePicUrl,
        currentBottomBarIndex: 1,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.normal,
        ),
        slivers: [
          // ── App Bar ─────────────────────────────
          PrimarySliverAppBar(
            searchHintText: 'Search groceries, beauty...',
            searchStaticPrefix: 'Search ',
            searchAnimatedHints: const [
              'groceries...',
              'beauty products...',
              'shoes...',
              'fresh items...',
              'snacks...',
              'drinks...',
              'dairy...',
            ],
            onSearchChanged: (val) => debugPrint('Searching: $val'),
          ),

          if (!isEmpty) ...[
            // ── Savings Banner ───────────────────
            SliverToBoxAdapter(
              child: _SavingsBanner(
                itemCount: _wishlistItems.length,
                totalSavings: _totalSavings,
                totalValue: _totalWishlistValue,
                onAddAll: _addAllToCart,
              ),
            ),

            // ── Wishlist Cards ───────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = _wishlistItems[index];
                  return _AnimatedWishlistCard(
                    key: ValueKey(item.id),
                    item: item,
                    index: index,
                    onRemove: () => _removeItem(item),
                    onAddToCart: () => _addToCart(item),
                  );
                }, childCount: _wishlistItems.length),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ] else ...[
            // ── Empty State ───────────────────────
            SliverToBoxAdapter(
              child: _EmptyWishlistState(floatAnimation: _floatAnimation),
            ),
          ],

          // ── Recommended Section ───────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: EcommerceSectionTitle(
                title: !isEmpty ? 'Similar Items' : 'Recommended for you',
                actionText: 'See All',
                onActionTap: () {},
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _recommendedItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _recommendedItems[index];
                  return EcommerceProductCard(
                    imageUrl: item['imageUrl'],
                    title: item['title'],
                    price: item['price'],
                    rating: item['rating'],
                    reviewCount: item['reviewCount'],
                    onTap: () {},
                    onAddToCart: () {
                      AppSnackbar.success(
                        context,
                        '${item['title']} added to cart',
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SAVINGS BANNER
// ─────────────────────────────────────────────

class _SavingsBanner extends StatelessWidget {
  final int itemCount;
  final double totalSavings;
  final double totalValue;
  final VoidCallback onAddAll;

  const _SavingsBanner({
    required this.itemCount,
    required this.totalSavings,
    required this.totalValue,
    required this.onAddAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withValues(alpha: 0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$itemCount saved item${itemCount != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'You\'re saving ${AppCurrency.symbol}${totalSavings.toStringAsFixed(2)} on this list!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _BannerStat(
                  label: 'List Total',
                  value:
                      '${AppCurrency.symbol}${totalValue.toStringAsFixed(2)}',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.25),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _BannerStat(
                  label: 'You Save',
                  value:
                      '${AppCurrency.symbol}${totalSavings.toStringAsFixed(2)}',
                  valueColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSuccess
                      : AppColors.teaGreenSoft,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onAddAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 15,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add All',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _BannerStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMATED WISHLIST CARD
// ─────────────────────────────────────────────

class _AnimatedWishlistCard extends StatefulWidget {
  final WishlistItem item;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _AnimatedWishlistCard({
    super.key,
    required this.item,
    required this.index,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  State<_AnimatedWishlistCard> createState() => _AnimatedWishlistCardState();
}

class _AnimatedWishlistCardState extends State<_AnimatedWishlistCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 380 + widget.index * 70),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 90), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {},
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: _WishlistCard(
              item: widget.item,
              onRemove: widget.onRemove,
              onAddToCart: widget.onAddToCart,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WISHLIST CARD
// ─────────────────────────────────────────────

class _WishlistCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  const _WishlistCard({
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ─────────────────
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    item.imageUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
                // Discount badge
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkError
                          : AppColors.lightError,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      item.discountTag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Info ──────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Star rating
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        final filled = i < item.rating.floor();
                        final half =
                            !filled &&
                            i < item.rating &&
                            (item.rating - i) >= 0.5;
                        return Icon(
                          filled
                              ? Icons.star_rounded
                              : half
                              ? Icons.star_half_rounded
                              : Icons.star_outline_rounded,
                          size: 13,
                          color: isDark
                              ? AppColors.darkWarning
                              : AppColors.lightWarning,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '${item.rating} (${item.reviewCount})',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${AppCurrency.symbol}${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: theme.primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${AppCurrency.symbol}${item.originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Actions ───────────────────────
            Column(
              children: [
                // Remove button
                _IconActionButton(
                  icon: Icons.favorite,
                  color: isDark ? AppColors.darkError : AppColors.lightError,
                  backgroundColor:
                      (isDark ? AppColors.darkError : AppColors.lightError)
                          .withValues(alpha: 0.1),
                  onTap: onRemove,
                  tooltip: 'Remove',
                ),
                const SizedBox(height: 8),
                // Add to cart button
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: item.isAddedToCart
                      ? _IconActionButton(
                          key: const ValueKey('added'),
                          icon: Icons.check_rounded,
                          color: isDark
                              ? AppColors.darkSuccess
                              : AppColors.lightSuccess,
                          backgroundColor:
                              (isDark
                                      ? AppColors.darkSuccess
                                      : AppColors.lightSuccess)
                                  .withValues(alpha: 0.12),
                          onTap: () {},
                          tooltip: 'Added!',
                        )
                      : _IconActionButton(
                          key: const ValueKey('cart'),
                          icon: Icons.shopping_cart_outlined,
                          color: theme.primaryColor,
                          backgroundColor: theme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          onTap: onAddToCart,
                          tooltip: 'Add to cart',
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ICON ACTION BUTTON
// ─────────────────────────────────────────────

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;
  final String tooltip;

  const _IconActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyWishlistState extends StatelessWidget {
  final Animation<double> floatAnimation;
  const _EmptyWishlistState({required this.floatAnimation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 8),
      child: Column(
        children: [
          // Floating icon with animated translate
          AnimatedBuilder(
            animation: floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withValues(alpha: 0.08),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 42,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Nothing saved yet',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the ♡ on any product to save it here.\nYour favourites are always one tap away.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainView(initialIndex: 0),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.storefront_rounded, size: 18),
            label: const Text('Discover Products'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
