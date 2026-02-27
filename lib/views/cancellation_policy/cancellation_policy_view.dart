import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../main/main_view.dart';

// ─────────────────────────────────────────────
// Data model for a Cancellation Policy section
// ─────────────────────────────────────────────
class _CancellationSection {
  final String number;
  final String title;
  final String content;
  final IconData icon;

  const _CancellationSection({
    required this.number,
    required this.title,
    required this.content,
    required this.icon,
  });
}

// ─────────────────────────────────────────────
// Expandable row – self-managing expansion state
// ─────────────────────────────────────────────
class _ExpandableSection extends StatefulWidget {
  final _CancellationSection section;
  final bool initiallyExpanded;

  const _ExpandableSection({
    required this.section,
    this.initiallyExpanded = false,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;
  late final Animation<double> _rotateAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _rotateAnim = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic));
    if (_expanded) _ctrl.value = 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    final chipBg = isDark
        ? AppColors.darkPrimary.withValues(alpha: 0.12)
        : AppColors.lightPrimary.withValues(alpha: 0.10);

    return Semantics(
      button: true,
      expanded: _expanded,
      label: widget.section.title,
      child: InkWell(
        onTap: _toggle,
        borderRadius: BorderRadius.circular(16),
        splashColor: primary.withValues(alpha: 0.06),
        highlightColor: primary.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _expanded
                ? (isDark
                      ? AppColors.darkPrimary.withValues(alpha: 0.07)
                      : AppColors.lightPrimary.withValues(alpha: 0.05))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _expanded
                  ? primary.withValues(alpha: 0.25)
                  : onSurface.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──────────────────────────────────
              Row(
                children: [
                  // Icon chip
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.section.icon, size: 20, color: primary),
                  ),
                  const SizedBox(width: 12),
                  // Title + number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.section.number,
                          style: AppTextStyles.caption.copyWith(
                            color: primary.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.section.title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chevron
                  RotationTransition(
                    turns: _rotateAnim,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: onSurface.withValues(alpha: 0.45),
                      size: 22,
                    ),
                  ),
                ],
              ),
              // ── Expandable content ───────────────────────────
              SizeTransition(
                sizeFactor: _expandAnim,
                axisAlignment: -1,
                child: FadeTransition(
                  opacity: _expandAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      Container(
                        height: 1,
                        margin: const EdgeInsets.only(bottom: 14),
                        color: onSurface.withValues(alpha: 0.07),
                      ),
                      Text(
                        widget.section.content,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: onSurface.withValues(alpha: 0.72),
                          height: 1.65,
                        ),
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

// ─────────────────────────────────────────────
// Main view
// ─────────────────────────────────────────────
class CancellationPolicyView extends StatefulWidget {
  final int currentBottomBarIndex;

  const CancellationPolicyView({
    super.key,
    required this.currentBottomBarIndex,
  });

  @override
  State<CancellationPolicyView> createState() => _CancellationPolicyViewState();
}

class _CancellationPolicyViewState extends State<CancellationPolicyView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  // ── Static policy sections ────────────────────────────────────────────────
  // Structured for straightforward future API integration:
  // replace this list with a mapped API response to populate sections dynamically.
  static const List<_CancellationSection> _sections = [
    _CancellationSection(
      number: 'SECTION 01',
      title: 'Order Cancellation Window',
      icon: Icons.timer_outlined,
      content:
          'You may cancel your order at any time before it is marked as "Out for Delivery". Once a delivery partner has been assigned and the order is dispatched, cancellation is no longer possible through the app. For urgent cases after dispatch, please contact us directly.',
    ),
    _CancellationSection(
      number: 'SECTION 02',
      title: 'How to Cancel an Order',
      icon: Icons.cancel_outlined,
      content:
          'To cancel an order, navigate to the Orders section in the app, select the relevant order, and tap "Cancel Order". You will be prompted to confirm cancellation. Once confirmed, the order will be cancelled and you will receive a notification.',
    ),
    _CancellationSection(
      number: 'SECTION 03',
      title: 'Non-Cancellable Items',
      icon: Icons.block_outlined,
      content:
          'Certain items cannot be cancelled once the order is placed, including perishable goods (fresh produce, dairy, bakery items), items already prepared or packaged for dispatch, and products marked as "Non-Cancellable" on the product page.',
    ),
    _CancellationSection(
      number: 'SECTION 04',
      title: 'Refunds for Cancelled Orders',
      icon: Icons.currency_rupee_outlined,
      content:
          'Since we currently operate on Cash on Delivery (COD) only, no payment is collected at the time of ordering. Therefore, no refund is applicable for a standard cancellation. If a payment was collected in error, please contact us and we will resolve it promptly.',
    ),
    _CancellationSection(
      number: 'SECTION 05',
      title: 'Cancellations by Mandal Variety',
      icon: Icons.store_outlined,
      content:
          'We reserve the right to cancel any order under circumstances including but not limited to: product unavailability, delivery address outside our service area, suspected fraudulent activity, or force majeure events. You will be notified immediately if your order is cancelled by us.',
    ),
    _CancellationSection(
      number: 'SECTION 06',
      title: 'Repeated Cancellations',
      icon: Icons.warning_amber_outlined,
      content:
          'Frequent or repeated cancellations may affect your ability to place future orders. We monitor cancellation patterns to ensure fair use of our service. Accounts with an unusually high cancellation rate may be temporarily restricted or reviewed by our team.',
    ),
    _CancellationSection(
      number: 'SECTION 07',
      title: 'Contact Us for Assistance',
      icon: Icons.support_agent_outlined,
      content:
          'If you encounter any issues while cancelling an order, or if you believe a cancellation was processed incorrectly, please reach out to us through the Help & Support section or contact the store directly during working hours. We are committed to resolving issues quickly.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    final progress = (_scrollController.offset / max).clamp(0.0, 1.0);
    if ((progress - _scrollProgress).abs() > 0.005) {
      setState(() => _scrollProgress = progress);
    }
  }

  void _onBottomBarTap(BuildContext context, int index) {
    if (index == widget.currentBottomBarIndex) {
      Navigator.pop(context);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainView(initialIndex: index)),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isIOS = theme.platform == TargetPlatform.iOS;
    final primary = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      // ── App bar ────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        leading: Semantics(
          label: 'Go back',
          button: true,
          child: IconButton(
            icon: Icon(
              isIOS
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_back_rounded,
              color: onSurface,
            ),
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Cancellation Policy',
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Semantics(
                  label: 'Cart, 2 items',
                  button: true,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(alpha: 0.08),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.shopping_cart_outlined, color: primary),
                      tooltip: 'Cart',
                      onPressed: () => HapticFeedback.lightImpact(),
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 6,
                  child: IgnorePointer(
                    child: Container(
                      width: 17,
                      height: 17,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // ── Read progress bar ──────────────────────────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: AnimatedBuilder(
            animation: _scrollController,
            builder: (_, __) => LinearProgressIndicator(
              value: _scrollProgress,
              minHeight: 3,
              backgroundColor: onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                primary.withValues(alpha: 0.65),
              ),
            ),
          ),
        ),
      ),
      // ── Bottom bar ─────────────────────────────────────────
      bottomNavigationBar: CommonBottomBar(
        currentIndex: widget.currentBottomBarIndex,
        onTap: (index) => _onBottomBarTap(context, index),
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
      // ── Body ───────────────────────────────────────────────
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero header ─────────────────────────────────
            _HeroHeader(isDark: isDark, primary: primary, onSurface: onSurface),
            // ── Sections list ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < _sections.length; i++) ...[
                    _ExpandableSection(
                      section: _sections[i],
                      initiallyExpanded: i == 0,
                    ),
                    if (i < _sections.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            // ── Footer acknowledgment ─────────────────────
            _FooterAcknowledgment(onSurface: onSurface),
            // Safe bottom padding for bottom bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Hero header widget
// ─────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color onSurface;

  const _HeroHeader({
    required this.isDark,
    required this.primary,
    required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Icon + description row ────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.22),
                    width: 1.5,
                  ),
                ),
                child: Icon(Icons.cancel_outlined, size: 28, color: primary),
              ),
              const SizedBox(width: 16),
              // Description + last-updated badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Understand when and how you can cancel an order placed on Mandal Variety Store, and what to expect when a cancellation occurs.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onSurface.withValues(alpha: 0.62),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Last updated badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: isDark ? 0.14 : 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.update_rounded,
                            size: 13,
                            color: primary.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Last updated: February 2026',
                            style: AppTextStyles.caption.copyWith(
                              color: primary.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: onSurface.withValues(alpha: 0.08), height: 1),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Footer acknowledgment widget
// ─────────────────────────────────────────────
class _FooterAcknowledgment extends StatelessWidget {
  final Color onSurface;

  const _FooterAcknowledgment({required this.onSurface});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
      child: Text(
        'By placing an order on Mandal Variety Store, you acknowledge that you have read and agree to this Cancellation Policy.',
        textAlign: TextAlign.center,
        style: AppTextStyles.caption.copyWith(
          color: onSurface.withValues(alpha: 0.35),
          height: 1.6,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
