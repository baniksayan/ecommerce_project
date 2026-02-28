import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_text_styles.dart';
import '../../common/buttons/cart_icon_button.dart';
import '../../core/theme/app_colors.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../main/main_view.dart';

// ─────────────────────────────────────────────
// Data model for an Age Restriction Policy section
// ─────────────────────────────────────────────
class _AgeRestrictionSection {
  final String number;
  final String title;
  final String content;
  final IconData icon;

  const _AgeRestrictionSection({
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
  final _AgeRestrictionSection section;
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
class AgeRestrictionPolicyView extends StatefulWidget {
  final int currentBottomBarIndex;

  const AgeRestrictionPolicyView({
    super.key,
    required this.currentBottomBarIndex,
  });

  @override
  State<AgeRestrictionPolicyView> createState() =>
      _AgeRestrictionPolicyViewState();
}

class _AgeRestrictionPolicyViewState extends State<AgeRestrictionPolicyView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  // ── Static policy sections ────────────────────────────────────────────────
  // Structured for straightforward future API integration:
  // replace this list with a mapped API response to populate sections dynamically.
  static const List<_AgeRestrictionSection> _sections = [
    _AgeRestrictionSection(
      number: 'SECTION 01',
      title: 'Minimum Age Requirement',
      icon: Icons.cake_outlined,
      content:
          'The purchase of tobacco and other regulated products — including but not limited to Cigarettes, Bidis, Khaini, Gutkha, and Zarda — is strictly restricted to individuals who are eighteen (18) years of age or older, in accordance with applicable laws and local regulations. By placing an order for such products through the Mandal Variety app, the user expressly represents and warrants that they meet the minimum legal age requirement.',
    ),
    _AgeRestrictionSection(
      number: 'SECTION 02',
      title: 'Age Verification at Delivery',
      icon: Icons.badge_outlined,
      content:
          'Age verification may be conducted at the time of delivery. Customers may be required to present a valid government-issued identification document as proof of age. If the recipient fails to provide valid identification or is found to be under the legal age, the delivery personnel reserve the right to refuse handover of the restricted products without prior notice.',
    ),
    _AgeRestrictionSection(
      number: 'SECTION 03',
      title: 'Product Visibility & Discoverability',
      icon: Icons.visibility_off_outlined,
      content:
          'Mandal Variety does not promote or advertise tobacco products. Such products are displayed separately within the application and are accessible only through direct search functionality. These items will not appear in promotional banners, recommendations, or suggestion modules.',
    ),
    _AgeRestrictionSection(
      number: 'SECTION 04',
      title: 'Limitation of Liability',
      icon: Icons.balance_outlined,
      content:
          'The platform shall not be held liable for any misuse, resale, or unlawful consumption of regulated products after successful delivery. Responsibility for compliance with age-related laws rests solely with the purchaser.',
    ),
    _AgeRestrictionSection(
      number: 'SECTION 05',
      title: 'Regulated Product Categories',
      icon: Icons.category_outlined,
      content:
          'Products subject to this policy include, but are not limited to: Cigarettes, Bidis, Khaini, Gutkha, Zarda, and any other tobacco-derived or nicotine-containing products listed under applicable regulatory frameworks. Additional categories may be added as regulations evolve.',
    ),
    _AgeRestrictionSection(
      number: 'SECTION 06',
      title: 'Compliance with Applicable Law',
      icon: Icons.gavel_rounded,
      content:
          'This policy is framed in compliance with the Cigarettes and Other Tobacco Products Act (COTPA) and any other applicable central or state legislation governing the sale of tobacco and restricted products in India. Mandal Variety is committed to responsible retail and will co-operate fully with any regulatory enquiry or audit.',
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
          child: BackButton(
            color: onSurface,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          '18+ Age Restriction Policy',
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          CartIconButton(
            margin: const EdgeInsets.only(right: 12),
            currentBottomBarIndex: widget.currentBottomBarIndex,
          ),
        ],
        // ── Read progress bar ──────────────────────────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: AnimatedBuilder(
            animation: _scrollController,
            builder: (_, _) => LinearProgressIndicator(
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
                child: Icon(
                  Icons.warning_amber_outlined,
                  size: 28,
                  color: primary,
                ),
              ),
              const SizedBox(width: 16),
              // Description + last-updated badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Certain products on Mandal Variety are restricted to customers aged 18 and above in compliance with applicable law. Please read this policy carefully.',
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
        'By purchasing age-restricted products on Mandal Variety Store, you confirm that you are 18 years of age or older and accept full responsibility for compliance with applicable laws.',
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
