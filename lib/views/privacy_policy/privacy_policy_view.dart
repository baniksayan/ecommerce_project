import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../main/main_view.dart';

// ─────────────────────────────────────────────
// Data model for a Privacy Policy section entry
// ─────────────────────────────────────────────
class _PolicySection {
  final String number;
  final String title;
  final String content;
  final IconData icon;

  const _PolicySection({
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
  final _PolicySection section;
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
class PrivacyPolicyView extends StatefulWidget {
  final int currentBottomBarIndex;

  const PrivacyPolicyView({
    super.key,
    required this.currentBottomBarIndex,
  });

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  // ── Static policy sections ────────────────────────────────────────────────
  // Structured for straightforward future API integration:
  // replace this list with a mapped API response to populate sections dynamically.
  static const List<_PolicySection> _sections = [
    _PolicySection(
      number: 'SECTION 01',
      title: 'Information We Collect',
      icon: Icons.manage_search_rounded,
      content:
          'We collect information you provide directly when you register, place an order, or contact us — such as your name, phone number, delivery address, and order history. We may also collect non-personal usage data such as device type and app interaction patterns to improve your experience.',
    ),
    _PolicySection(
      number: 'SECTION 02',
      title: 'How We Use Your Information',
      icon: Icons.data_usage_rounded,
      content:
          'Your information is used to process orders, arrange delivery, send order status notifications, and provide customer support. We may also use aggregated, anonymised data to analyse trends and improve our services. We do not use personal data for unsolicited marketing without your consent.',
    ),
    _PolicySection(
      number: 'SECTION 03',
      title: 'Data Sharing & Disclosure',
      icon: Icons.share_outlined,
      content:
          'We do not sell, trade, or rent your personal information to third parties. We may share data with trusted delivery partners solely to fulfil your order, and with service providers who assist us in operating the app, all of whom are bound by confidentiality obligations. We may disclose information when required by law.',
    ),
    _PolicySection(
      number: 'SECTION 04',
      title: 'Data Retention',
      icon: Icons.history_rounded,
      content:
          'We retain your personal information for as long as your account remains active or as needed to provide services. Order records may be retained for accounting and legal compliance purposes. You may request deletion of your account and associated data at any time by contacting us.',
    ),
    _PolicySection(
      number: 'SECTION 05',
      title: 'Data Security',
      icon: Icons.lock_outline_rounded,
      content:
          'We implement appropriate technical and organisational measures to protect your personal data against unauthorised access, alteration, disclosure, or destruction. However, no method of electronic transmission is 100% secure, and we cannot guarantee absolute security.',
    ),
    _PolicySection(
      number: 'SECTION 06',
      title: 'Cookies & Tracking',
      icon: Icons.cookie_outlined,
      content:
          'Our app may use local storage or session tokens to maintain your login state and preferences. We do not use cross-site tracking cookies. Any analytics data collected is anonymised and used solely to improve app performance and usability.',
    ),
    _PolicySection(
      number: 'SECTION 07',
      title: 'Your Rights',
      icon: Icons.verified_user_outlined,
      content:
          'You have the right to access, correct, or delete the personal information we hold about you. You may also opt out of non-essential communications at any time. To exercise these rights, please contact us through the Help section or reach out directly during our working hours.',
    ),
    _PolicySection(
      number: 'SECTION 08',
      title: 'Changes to This Policy',
      icon: Icons.update_rounded,
      content:
          'We may update this Privacy Policy periodically to reflect changes in our practices or applicable law. We will notify you of significant changes by updating the "Last updated" date at the top of this page. Continued use of the app after changes are posted constitutes your acceptance of the revised policy.',
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
          'Privacy Policy',
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
              // Shield icon
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
                child: Icon(Icons.privacy_tip_outlined, size: 28, color: primary),
              ),
              const SizedBox(width: 16),
              // Description + last-updated badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your privacy matters to us. This policy explains how Mandal Variety Store collects, uses, and protects your personal information.',
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
        'By using the Mandal Variety Store app, you consent to the collection and use of your information as described in this Privacy Policy.',
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
