import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../common/bottombar/common_bottom_bar.dart';
import '../../common/buttons/app_button.dart';
import '../../common/buttons/cart_icon_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../main/main_view.dart';

class _AgeGateSection {
  final String number;
  final String title;
  final String content;
  final IconData icon;

  const _AgeGateSection({
    required this.number,
    required this.title,
    required this.content,
    required this.icon,
  });
}

class _ExpandableSection extends StatefulWidget {
  final _AgeGateSection section;
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
              Row(
                children: [
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

class TobaccoAgeVerificationView extends StatefulWidget {
  final int currentBottomBarIndex;

  const TobaccoAgeVerificationView({
    super.key,
    required this.currentBottomBarIndex,
  });

  @override
  State<TobaccoAgeVerificationView> createState() =>
      _TobaccoAgeVerificationViewState();
}

class _TobaccoAgeVerificationViewState
    extends State<TobaccoAgeVerificationView> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  bool _confirmed18Plus = false;

  static const List<_AgeGateSection> _sections = [
    _AgeGateSection(
      number: 'SECTION 01',
      title: '18+ Only',
      icon: Icons.cake_outlined,
      content:
          'Tobacco and other regulated products are restricted to individuals who are 18 years of age or older. By proceeding, you confirm you meet the minimum legal age requirement.',
    ),
    _AgeGateSection(
      number: 'SECTION 02',
      title: 'ID Check at Delivery',
      icon: Icons.badge_outlined,
      content:
          'You may be asked to show a valid government-issued ID at delivery. If valid proof of age is not provided, delivery may be refused.',
    ),
    _AgeGateSection(
      number: 'SECTION 03',
      title: 'Health Warning',
      icon: Icons.warning_amber_outlined,
      content:
          'Tobacco consumption is harmful and can cause serious health risks. Please use responsibly and comply with all applicable laws.',
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

  void _continue() {
    // Provide explicit haptics on primary action.
    Feedback.forTap(context);
    HapticFeedback.lightImpact();
    if (!_confirmed18Plus) {
      // Keep this screen strict: user must confirm before continuing.
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final onSurface = theme.colorScheme.onSurface;

    final today = MaterialLocalizations.of(
      context,
    ).formatFullDate(DateTime.now());

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
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
          child: BackButton(color: onSurface),
        ),
        title: Text(
          '18+ Age Confirmation',
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          CartIconButton(
            margin: const EdgeInsets.only(right: 12),
            currentBottomBarIndex: widget.currentBottomBarIndex,
          ),
        ],
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
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroHeader(
              isDark: isDark,
              primary: primary,
              onSurface: onSurface,
              today: today,
            ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: onSurface.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _confirmed18Plus,
                  onChanged: (v) {
                    Feedback.forTap(context);
                    HapticFeedback.selectionClick();
                    setState(() => _confirmed18Plus = v ?? false);
                  },
                  title: Text(
                    'I confirm I am 18 years or older',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: onSurface.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Validated using your device date: $today',
                    style: AppTextStyles.caption.copyWith(
                      color: onSurface.withValues(alpha: 0.55),
                      height: 1.4,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  dense: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: AppButton.primary(
                text: 'Continue to Paan Corner',
                isFullWidth: true,
                onPressed: _confirmed18Plus ? _continue : null,
                icon: Icons.lock_open_rounded,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final bool isDark;
  final Color primary;
  final Color onSurface;
  final String today;

  const _HeroHeader({
    required this.isDark,
    required this.primary,
    required this.onSurface,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paan Corner includes age-restricted products. Please confirm your age before continuing.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onSurface.withValues(alpha: 0.62),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                            Icons.today_rounded,
                            size: 13,
                            color: primary.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Today: $today',
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
          const SizedBox(height: 18),
          Divider(color: onSurface.withValues(alpha: 0.08), height: 1),
        ],
      ),
    );
  }
}
