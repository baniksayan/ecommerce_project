import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/responsive/media_query_helper.dart';
import '../../common/buttons/app_button.dart';
import '../../views/auth/email_login_view.dart';
import '../../views/main/main_view.dart';

// ============================================================================
// AUTH ENTRY VIEW
// First screen after onboarding when the user is not logged in.
// Minimal, non-blocking — the Skip option is always prominent.
// ============================================================================

class AuthEntryView extends StatelessWidget {
  const AuthEntryView({super.key});

  void _continueWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmailLoginView()),
    );
  }

  void _skipToMain(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Illustration ──────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQueryHelper.scaleWidth(24),
              vertical: MediaQueryHelper.scaleHeight(20),
            ),
            child: Image.asset(
              'assets/images/onboarding/delivery_splash_3.PNG',
              fit: BoxFit.contain,
            ),
          ),
        ),

        // ── Title ─────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQueryHelper.scaleWidth(32),
          ),
          child: Text(
            'Welcome to Mandal Variety',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.lightPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: MediaQueryHelper.scaleHeight(12)),

        // ── Subtitle ──────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQueryHelper.scaleWidth(40),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQueryHelper.isTablet ? 480 : double.infinity,
            ),
            child: Text(
              'Groceries delivered quickly from your nearby store.\nLogin to track orders and save your address.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.lightTextSecondary,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        SizedBox(height: MediaQueryHelper.scaleHeight(36)),

        // ── Primary CTA ────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQueryHelper.scaleWidth(24),
          ),
          child: AppButton.primary(
            text: 'Continue with Email',
            onPressed: () => _continueWithEmail(context),
            isFullWidth: true,
          ),
        ),

        SizedBox(height: MediaQueryHelper.scaleHeight(12)),

        // ── Skip ───────────────────────────────────────────────────────────
        TextButton(
          onPressed: () => _skipToMain(context),
          child: Text(
            'Skip for now',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        SizedBox(height: MediaQueryHelper.scaleHeight(24)),
      ],
    );
  }
}
