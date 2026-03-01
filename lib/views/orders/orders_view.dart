import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/product_listing/product_listing_coordinator.dart';
import '../../common/drawer/app_drawer.dart';
import '../../common/appbar/primary_sliver_app_bar.dart';
import '../../common/buttons/app_button.dart';
import '../../data/models/product_model.dart';
import '../home/home_widgets.dart';
import '../main/main_view.dart';

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────

enum OrderStatus { delivered, inTransit, processing, cancelled }

class Order {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final double total;
  final OrderStatus status;
  final DateTime date;
  final int itemCount;

  const Order({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.total,
    required this.status,
    required this.date,
    required this.itemCount,
  });
}

// ─────────────────────────────────────────────
//  MAIN VIEW
// ─────────────────────────────────────────────

class OrdersView extends StatefulWidget {
  const OrdersView({super.key});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> with TickerProviderStateMixin {
  String? _profilePicUrl;
  OrderStatus? _selectedFilter;
  late AnimationController _emptyStateController;
  late Animation<double> _floatAnimation;

  // Toggle between empty / populated for demo
  bool _hasOrders = false;

  final List<Order> _orders = [
    Order(
      id: '#ORD-8821',
      title: 'Premium Headphones',
      subtitle: 'Sony WH-1000XM5 · Midnight Black',
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
      total: 199.99,
      status: OrderStatus.delivered,
      date: DateTime.now().subtract(const Duration(days: 3)),
      itemCount: 1,
    ),
    Order(
      id: '#ORD-8744',
      title: 'Smart Watch',
      subtitle: 'Apple Watch SE · Starlight',
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&q=80&w=400',
      total: 129.50,
      status: OrderStatus.inTransit,
      date: DateTime.now().subtract(const Duration(days: 1)),
      itemCount: 1,
    ),
    Order(
      id: '#ORD-8700',
      title: 'Running Shoes Bundle',
      subtitle: 'Nike Air Max 270 + Socks Pack',
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=400',
      total: 119.97,
      status: OrderStatus.processing,
      date: DateTime.now().subtract(const Duration(hours: 5)),
      itemCount: 3,
    ),
    Order(
      id: '#ORD-8601',
      title: 'Wireless Earbuds',
      subtitle: 'AirPods Pro 2nd Gen',
      imageUrl:
          'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?auto=format&fit=crop&q=80&w=400',
      total: 249.00,
      status: OrderStatus.cancelled,
      date: DateTime.now().subtract(const Duration(days: 7)),
      itemCount: 1,
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
    _emptyStateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _emptyStateController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emptyStateController.dispose();
    super.dispose();
  }

  List<Order> get _filteredOrders {
    if (_selectedFilter == null) return _orders;
    return _orders.where((o) => o.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppDrawer(
        profilePicUrl: _profilePicUrl,
        currentBottomBarIndex: 2,
      ),
      // FAB to toggle empty/populated (for demo – remove in prod)
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Toggle empty/populated',
        onPressed: () => setState(() => _hasOrders = !_hasOrders),
        child: Icon(_hasOrders ? Icons.inbox : Icons.add_shopping_cart),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.normal,
        ),
        slivers: [
          // ── App Bar ─────────────────────────────
          PrimarySliverAppBar(
            searchHintText: 'Search your orders...',
            searchStaticPrefix: 'Search ',
            searchAnimatedHints: const [
              'orders...',
              'order history...',
              'order status...',
              'recent orders...',
              'delivered orders...',
              'cancelled orders...',
            ],
            onSearchChanged: (val) => debugPrint('Searching orders: $val'),
            currentBottomBarIndex: 2,
            enableTobaccoRedirect: false,
          ),

          if (_hasOrders) ...[
            // ── Summary Strip ────────────────────
            SliverToBoxAdapter(child: _OrderSummaryStrip(orders: _orders)),

            // ── Filter Chips ─────────────────────
            SliverToBoxAdapter(
              child: _FilterChipRow(
                selected: _selectedFilter,
                onSelect: (s) => setState(() {
                  _selectedFilter = _selectedFilter == s ? null : s;
                }),
              ),
            ),

            // ── Order Cards ──────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (_filteredOrders.isEmpty) {
                      return const _EmptyFilterResult();
                    }
                    return _AnimatedOrderCard(
                      order: _filteredOrders[index],
                      index: index,
                    );
                  },
                  childCount: _filteredOrders.isEmpty
                      ? 1
                      : _filteredOrders.length,
                ),
              ),
            ),
          ] else ...[
            // ── Empty State ───────────────────────
            SliverToBoxAdapter(
              child: _EmptyOrdersState(floatAnimation: _floatAnimation),
            ),
          ],

          // ── Recommended Section ───────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: EcommerceSectionTitle(
                title: _hasOrders ? 'Buy Again' : 'Recommended for you',
                actionText: 'See All',
                onActionTap: () {
                  ProductListingCoordinator.instance.openListing(
                    context,
                    category: ProductCategory.grocery,
                    currentBottomBarIndex: 2,
                  );
                },
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
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _recommendedItems[index];
                  return EcommerceProductCard(
                    imageUrl: item['imageUrl'],
                    title: item['title'],
                    price: item['price'],
                    rating: item['rating'],
                    reviewCount: item['reviewCount'],
                    onTap: () {},
                    onAddToCart: () {},
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
//  SUMMARY STRIP
// ─────────────────────────────────────────────

class _OrderSummaryStrip extends StatelessWidget {
  final List<Order> orders;
  const _OrderSummaryStrip({required this.orders});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = orders
        .where((o) => o.status == OrderStatus.inTransit)
        .length;
    final delivered = orders
        .where((o) => o.status == OrderStatus.delivered)
        .length;
    final total = orders.fold<double>(0, (sum, o) => sum + o.total);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _SummaryItem(
            label: 'In Transit',
            value: '$active',
            icon: Icons.local_shipping_rounded,
          ),
          _divider(),
          _SummaryItem(
            label: 'Delivered',
            value: '$delivered',
            icon: Icons.check_circle_rounded,
          ),
          _divider(),
          _SummaryItem(
            label: 'Total Spent',
            value: '\$${total.toStringAsFixed(0)}',
            icon: Icons.receipt_long_rounded,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 36,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: Colors.white.withValues(alpha: 0.25),
  );
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FILTER CHIP ROW
// ─────────────────────────────────────────────

class _FilterChipRow extends StatelessWidget {
  final OrderStatus? selected;
  final ValueChanged<OrderStatus> onSelect;

  const _FilterChipRow({required this.selected, required this.onSelect});

  static const _filters = [
    (OrderStatus.inTransit, 'In Transit'),
    (OrderStatus.processing, 'Processing'),
    (OrderStatus.delivered, 'Delivered'),
    (OrderStatus.cancelled, 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 52,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: _filters.map((f) {
          final isSelected = selected == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                label: Text(f.$2),
                selected: isSelected,
                onSelected: (_) => onSelect(f.$1),
                selectedColor: theme.primaryColor.withValues(alpha: 0.15),
                checkmarkColor: theme.primaryColor,
                labelStyle: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected
                      ? theme.primaryColor
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ANIMATED ORDER CARD
// ─────────────────────────────────────────────

class _AnimatedOrderCard extends StatefulWidget {
  final Order order;
  final int index;
  const _AnimatedOrderCard({required this.order, required this.index});

  @override
  State<_AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends State<_AnimatedOrderCard>
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
      duration: Duration(milliseconds: 350 + widget.index * 60),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Stagger entry
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
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
          onTap: () {
            HapticFeedback.lightImpact();
            // Navigate to order detail
          },
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: _OrderCard(order: widget.order),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                order.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 72,
                  height: 72,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_outlined),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _StatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.subtitle,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        order.id,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${order.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _StatusProgressBar(status: order.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STATUS BADGE
// ─────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (label, color, bg) = switch (status) {
      OrderStatus.delivered => (
        'Delivered',
        isDark ? AppColors.darkSuccess : AppColors.lightSuccess,
        (isDark ? AppColors.darkSuccess : AppColors.lightSuccess).withValues(
          alpha: 0.2,
        ),
      ),
      OrderStatus.inTransit => (
        'In Transit',
        isDark ? AppColors.darkInfo : AppColors.lightInfo,
        (isDark ? AppColors.darkInfo : AppColors.lightInfo).withValues(
          alpha: 0.2,
        ),
      ),
      OrderStatus.processing => (
        'Processing',
        isDark ? AppColors.darkWarning : AppColors.lightWarning,
        (isDark ? AppColors.darkWarning : AppColors.lightWarning).withValues(
          alpha: 0.2,
        ),
      ),
      OrderStatus.cancelled => (
        'Cancelled',
        isDark ? AppColors.darkError : AppColors.lightError,
        (isDark ? AppColors.darkError : AppColors.lightError).withValues(
          alpha: 0.2,
        ),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  STATUS PROGRESS BAR
// ─────────────────────────────────────────────

class _StatusProgressBar extends StatelessWidget {
  final OrderStatus status;
  const _StatusProgressBar({required this.status});

  double get _progress => switch (status) {
    OrderStatus.processing => 0.25,
    OrderStatus.inTransit => 0.65,
    OrderStatus.delivered => 1.0,
    OrderStatus.cancelled => 0.0,
  };

  Color _getColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (status) {
      OrderStatus.delivered =>
        isDark ? AppColors.darkSuccess : AppColors.lightSuccess,
      OrderStatus.inTransit =>
        isDark ? AppColors.darkInfo : AppColors.lightInfo,
      OrderStatus.processing =>
        isDark ? AppColors.darkWarning : AppColors.lightWarning,
      OrderStatus.cancelled =>
        isDark ? AppColors.darkError : AppColors.lightError,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);

    if (status == OrderStatus.cancelled) {
      return Row(
        children: [
          Icon(Icons.cancel_outlined, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            'Order was cancelled',
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 5,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  EMPTY STATE
// ─────────────────────────────────────────────

class _EmptyOrdersState extends StatelessWidget {
  final Animation<double> floatAnimation;
  const _EmptyOrdersState({required this.floatAnimation});

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
                    Icons.receipt_long_rounded,
                    size: 42,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Your orders live here',
            textAlign: TextAlign.center,
            style: AppTextStyles.heading2.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Every purchase you make will show up here.\nStart exploring — something great is waiting.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 28),
          AppButton.primary(
            text: 'Start Shopping',
            icon: Icons.storefront_rounded,
            isFullWidth: true,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainView(initialIndex: 0),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  EMPTY FILTER RESULT
// ─────────────────────────────────────────────

class _EmptyFilterResult extends StatelessWidget {
  const _EmptyFilterResult();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          Text(
            'No orders match this filter',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
