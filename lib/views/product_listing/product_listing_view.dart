import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/bottombar/common_bottom_bar.dart';
import '../../common/buttons/cart_icon_button.dart';
import '../../common/cards/app_card.dart';
import '../../common/searchbar/app_search_bar.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../../core/cart/cart_coordinator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_currency.dart';
import '../../core/utils/platform_helper.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/static_product_repository.dart';
import '../../viewmodels/product_listing_viewmodel.dart';
import '../main/main_view.dart';

class ProductListingView extends StatefulWidget {
  final ProductCategory category;
  final int currentBottomBarIndex;

  const ProductListingView({
    super.key,
    required this.category,
    this.currentBottomBarIndex = 0,
  });

  static Route<void> route({
    required ProductCategory category,
    int currentBottomBarIndex = 0,
  }) {
    Widget builder(BuildContext _) => ProductListingView(
      category: category,
      currentBottomBarIndex: currentBottomBarIndex,
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

  bool get _canPop => ModalRoute.of(context)?.canPop ?? false;

  @override
  void initState() {
    super.initState();
    _vm = ProductListingViewModel(
      repository: const StaticProductRepository(),
      category: widget.category,
    )..load();
  }

  @override
  void dispose() {
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
        onChanged: _vm.setSearchQuery,
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
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.normal,
            ),
            slivers: [
              // ── Collapsible / floating AppBar ─────────────────────────────
              SliverAppBar(
                backgroundColor: theme.scaffoldBackgroundColor.withValues(
                  alpha: 0.98,
                ),
                elevation: 0,
                floating: true,
                snap: true,
                pinned: false,
                toolbarHeight: 72,
                automaticallyImplyLeading: false,
                leading: _canPop
                    ? (PlatformHelper.isIOS
                          ? CupertinoNavigationBarBackButton(
                              color: primary,
                              onPressed: () => Navigator.of(context).pop(),
                            )
                          : BackButton(
                              onPressed: () => Navigator.of(context).pop(),
                            ))
                    : null,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                    right: 4.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: searchBar),
                      const SizedBox(width: 12),
                      CartIconButton(
                        currentBottomBarIndex: widget.currentBottomBarIndex,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Collapsible / floating Sort + Filter row ─────────────────
              SliverPersistentHeader(
                floating: true,
                pinned: false,
                delegate: _FixedExtentHeaderDelegate(
                  height: 48,
                  child: _SortFilterChipsBar(
                    sort: _vm.sort,
                    onSortTap: _openSortPicker,
                    onSortChanged: _vm.setSort,
                    onFilterTap: () {
                      HapticFeedback.selectionClick();
                    },
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
            ],
          ),
        );
      },
    );
  }
}

class _FixedExtentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  _FixedExtentHeaderDelegate({required this.height, required this.child});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    return Material(color: theme.scaffoldBackgroundColor, child: child);
  }

  @override
  bool shouldRebuild(covariant _FixedExtentHeaderDelegate oldDelegate) {
    return height != oldDelegate.height || child != oldDelegate.child;
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
          childAspectRatio: 0.62,
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
              AppSnackbar.success(context, '${p.name} added to cart');
            },
          );
        }, childCount: products.length),
      ),
    );
  }
}

class _SortFilterChipsBar extends StatelessWidget {
  final ProductSort sort;
  final VoidCallback onSortTap;
  final ValueChanged<ProductSort> onSortChanged;
  final VoidCallback onFilterTap;

  const _SortFilterChipsBar({
    required this.sort,
    required this.onSortTap,
    required this.onSortChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget chipSpacer() => const SizedBox(width: 10);

    final bool hasActiveSort = sort != ProductSort.popular;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: SizedBox(
        height: 36,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ActionChip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                avatar: Icon(Icons.sort, size: 18, color: theme.primaryColor),
                label: Text(
                  'Sort',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: onSortTap,
              ),
              chipSpacer(),
              ActionChip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                avatar: Icon(
                  Icons.filter_list,
                  size: 18,
                  color: theme.primaryColor,
                ),
                label: Text(
                  'Filter',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: onFilterTap,
              ),
              if (hasActiveSort) ...[
                chipSpacer(),
                InputChip(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  label: Text(
                    sort.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: true,
                  showCheckmark: false,
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    HapticFeedback.selectionClick();
                    onSortChanged(ProductSort.popular);
                  },
                ),
              ],
            ],
          ),
        ),
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

  void _handleAddToCart() {
    HapticFeedback.heavyImpact();
    if (_inCart) return;
    setState(() => _inCart = true);
    widget.onAddToCart();
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
    final discountBg = isDark ? AppColors.darkError : AppColors.lightError;
    final errorColor = discountBg;

    final hasDiscount =
        widget.product.originalPrice != null &&
        widget.product.originalPrice! > widget.product.price;

    final rating = widget.product.rating;
    final reviewCount = widget.product.reviewCount;

    return AppCard.action(
      onTap: () {},
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 1.12,
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
              if (widget.product.discountTag != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: discountBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.product.discountTag!,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(
                    _isWishlisted ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                  ),
                  color: _isWishlisted ? errorColor : Colors.grey[400],
                  onPressed: _toggleWishlist,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                        if (reviewCount != null)
                          Text(
                            ' ($reviewCount)',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                      ],
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${AppCurrency.symbol}${widget.product.price.toStringAsFixed(2)}',
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
                                '${AppCurrency.symbol}${widget.product.originalPrice!.toStringAsFixed(2)}',
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
                      Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: _handleAddToCart,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              _inCart
                                  ? Icons.local_grocery_store
                                  : Icons.local_grocery_store_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
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
