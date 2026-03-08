import 'package:flutter/material.dart';
import 'dart:io';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/responsive/media_query_helper.dart';
import '../../common/buttons/app_button.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/auth/otp_verification_view.dart';
import '../../views/main/main_view.dart';

// ============================================================================
// EMAIL LOGIN VIEW
// User enters their email to receive an OTP.
// Validates format before calling ViewModel's sendOtp mock.
// ============================================================================

class EmailLoginView extends StatefulWidget {
  /// [fromDrawer] — true when opened from the guest header in AppDrawer.
  /// Changes back-button visibility and bottom action label/behaviour.
  final bool fromDrawer;

  const EmailLoginView({super.key, this.fromDrawer = false});

  @override
  State<EmailLoginView> createState() => _EmailLoginViewState();
}

class _EmailLoginViewState extends State<EmailLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _vm = AuthViewModel();

  bool _isSending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _showGuestDialog() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Continue as Guest',
          style: AppTextStyles.heading3.copyWith(color: AppColors.lightPrimary),
        ),
        content: Text(
          'You are continuing as a guest. You can browse products, but you must log in before placing orders, adding items to cart, or accessing other account features.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.lightTextSecondary,
            height: 1.55,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    'Continue as Guest',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Login Instead',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (proceed == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainView()),
        (route) => false,
      );
    }
  }

  Future<void> _showBackToHomeDialog() async {
    final goHome = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Continue as Guest',
          style: AppTextStyles.heading3.copyWith(color: AppColors.lightPrimary),
        ),
        content: Text(
          'You are already browsing as a guest. Log in to place orders, save your address, and access your account features.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.lightTextSecondary,
            height: 1.55,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    'Go to Home',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Login Instead',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (goHome == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _sendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSending = true);

    final email = _emailController.text.trim();
    final ok = await _vm.sendOtp(email);

    if (!mounted) return;
    setState(() => _isSending = false);

    if (ok) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationView(email: email),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryHelper.init(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.fromDrawer
            ? IconButton(
                icon: Icon(
                  Platform.isIOS
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_back_rounded,
                ),
                color: AppColors.black,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQueryHelper.scaleWidth(24),
              vertical: MediaQueryHelper.scaleHeight(8),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQueryHelper.scaleHeight(8)),

                  // ── Title ────────────────────────────────────────────────
                  Text(
                    'Login with Email',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.lightPrimary,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(10)),

                  // ── Subtitle ─────────────────────────────────────────────
                  Text(
                    'Enter your email address to receive\na verification code.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(40)),

                  // ── Email label ───────────────────────────────────────────
                  Text(
                    'Email address',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(8)),

                  // ── Email field ───────────────────────────────────────────
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    onFieldSubmitted: (_) => _sendOtp(),
                    validator: _vm.validateEmail,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.lightDivider,
                      ),
                      filled: true,
                      fillColor: AppColors.lightSurface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: MediaQueryHelper.scaleWidth(16),
                        vertical: MediaQueryHelper.scaleHeight(14),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.lightDivider,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.lightDivider,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.lightPrimary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.lightError,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.lightError,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(36)),

                  // ── Send OTP button ───────────────────────────────────────
                  AppButton.primary(
                    text: 'Send OTP',
                    onPressed: _isSending ? null : _sendOtp,
                    isLoading: _isSending,
                    isFullWidth: true,
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(16)),

                  // ── Skip / Guest ──────────────────────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: widget.fromDrawer
                          ? _showBackToHomeDialog
                          : _showGuestDialog,
                      child: Text(
                        widget.fromDrawer ? 'Back to Home' : 'Continue as Guest',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
