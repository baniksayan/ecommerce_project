import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/responsive/media_query_helper.dart';
import '../../common/buttons/app_button.dart';
import '../../core/auth/auth_coordinator.dart';
import '../../viewmodels/onboarding_viewmodel.dart';
import '../../views/auth/email_login_view.dart';
import '../../views/main/main_view.dart';

// ============================================================================
// ONBOARDING VIEW — Full PageView-based 3-slide onboarding flow.
// Illustrations swipe horizontally via PageView.
// Title + subtitle fade in fresh on every page change.
// ============================================================================

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with SingleTickerProviderStateMixin {
  late final OnboardingViewModel _vm;
  late final PageController _pageCtrl;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _vm = OnboardingViewModel(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  // ── Navigation helpers ───────────────────────────────────────────────────

  /// Called by "Get Started" on the last slide.
  /// Marks onboarding as completed, then navigates accordingly.
  Future<void> _goToMain() async {
    await AuthCoordinator.instance.setOnboardingCompleted();
    if (!mounted) return;
    final dest = AuthCoordinator.instance.isLoggedIn
        ? const MainView()
        : const EmailLoginView();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => dest),
    );
  }

  /// Skip on slides 1 & 2 — jumps smoothly to the last slide (index 2).
  void _skipToLastSlide() {
    _pageCtrl.animateToPage(
      _vm.totalPages - 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < _vm.totalPages - 1) {
      _pageCtrl.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToMain();
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _vm.resetAndPlay();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    MediaQueryHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _vm.listenable,
          builder: (context, _) => _buildLayout(),
        ),
      ),
    );
  }

  Widget _buildLayout() {
    final slide = OnboardingViewModel.slides[_currentPage];
    final bool isLastPage = _currentPage == _vm.totalPages - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Illustration (PageView — swipeable) ──────────────────────────────
        Expanded(
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: _vm.totalPages,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQueryHelper.scaleWidth(24),
                  vertical: MediaQueryHelper.scaleHeight(16),
                ),
                child: Image.asset(
                  OnboardingViewModel.slides[index].imagePath,
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ),

        // ── Title ────────────────────────────────────────────────────────────
        FadeTransition(
          opacity: _vm.titleFade,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQueryHelper.scaleWidth(32),
            ),
            child: Text(
              slide.title,
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.lightPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: MediaQueryHelper.scaleHeight(12)),

        // ── Subtitle ─────────────────────────────────────────────────────────
        FadeTransition(
          opacity: _vm.subtitleFade,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQueryHelper.scaleWidth(40),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQueryHelper.isTablet ? 480 : double.infinity,
              ),
              child: Text(
                slide.subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightTextSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        SizedBox(height: MediaQueryHelper.scaleHeight(24)),

        // ── Page indicator dots ───────────────────────────────────────────────
        _buildPageIndicator(),

        SizedBox(height: MediaQueryHelper.scaleHeight(32)),

        // ── Bottom buttons ────────────────────────────────────────────────────
        _buildButtons(isLastPage: isLastPage),

        SizedBox(height: MediaQueryHelper.scaleHeight(24)),
      ],
    );
  }

  // ── PAGE INDICATOR ─────────────────────────────────────────────────────────

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _vm.totalPages,
        (index) => _buildDot(isActive: index == _currentPage),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQueryHelper.scaleWidth(4),
      ),
      width: isActive
          ? MediaQueryHelper.scaleWidth(20)
          : MediaQueryHelper.scaleWidth(8),
      height: MediaQueryHelper.scaleWidth(8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.lightPrimary : AppColors.lightDivider,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ── BOTTOM BUTTONS ─────────────────────────────────────────────────────────

  Widget _buildButtons({required bool isLastPage}) {
    // Skip is visible on slides 0 & 1; hidden on slide 2 (last).
    final bool showSkip = _currentPage < _vm.totalPages - 1;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQueryHelper.scaleWidth(24),
      ),
      child: Row(
        children: [
          // Skip — jumps smoothly to the last slide
          AnimatedOpacity(
            opacity: showSkip ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !showSkip,
              child: TextButton(
                onPressed: _skipToLastSlide,
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // Next → advances slide; on last slide shows "Get Started"
          AppButton.primary(
            text: isLastPage ? 'Get Started' : 'Next  →',
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }
}
