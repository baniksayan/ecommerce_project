import 'package:flutter/material.dart';

import '../../core/utils/platform_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/responsive/media_query_helper.dart';
import '../../common/buttons/app_button.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/auth/email_login_view.dart';
import '../../views/auth/otp_verification_view.dart';
import '../../views/main/main_view.dart';

// ============================================================================
// REGISTER VIEW
// User registers with Name, Email, and Password.
// Validates all fields before calling ViewModel's register mock/API.
// ============================================================================

class RegisterView extends StatefulWidget {
  /// [fromDrawer] — true when opened from the guest header in AppDrawer.
  /// Changes back-button visibility and bottom action label/behaviour.
  final bool fromDrawer;

  const RegisterView({super.key, this.fromDrawer = false});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vm = AuthViewModel();

  bool _isRegistering = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
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
          'You are continuing as a guest. You can browse products, but you must register/log in before placing orders, adding items to cart, or accessing other account features.',
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
                  'Register Instead',
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
          'You are already browsing as a guest. Register or log in to place orders, save your address, and access your account features.',
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
                  'Register Instead',
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

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isRegistering = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    
    final result = await _vm.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isRegistering = false);

    if (result.shouldRedirectToLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? 'This email is already registered. Please log in.',
          ),
          backgroundColor: AppColors.lightError,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EmailLoginView(fromDrawer: widget.fromDrawer),
        ),
      );
      return;
    }

    if (result.shouldOpenOtpVerification) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? _vm.lastAuthMessage ?? 'OTP sent successfully.',
          ),
          backgroundColor: AppColors.lightSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationView(email: email, isRegister: true),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.message ?? _vm.lastAuthMessage ?? 'Registration failed. Please try again.',
          ),
          backgroundColor: AppColors.lightError,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToLogin() {
    // If we have an existing login view below us, just pop. Otherwise push.
    final modalRoute = ModalRoute.of(context);
    final isFirstRoute = modalRoute?.isFirst ?? false;
    
    if (isFirstRoute) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EmailLoginView(fromDrawer: widget.fromDrawer),
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryHelper.init(context);

    final outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.lightDivider,
        width: 1.5,
      ),
    );

    final focusedInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.lightPrimary,
        width: 2,
      ),
    );

    final errorInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.lightError,
        width: 1.5,
      ),
    );

    final focusedErrorInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: AppColors.lightError,
        width: 2,
      ),
    );

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
                  PlatformHelper.isIOS
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_back_rounded,
                ),
                color: AppColors.black,
                onPressed: () => Navigator.of(context).pop(),
              )
            : IconButton(
                icon: Icon(
                  PlatformHelper.isIOS
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_back_rounded,
                ),
                color: AppColors.black,
                onPressed: () => Navigator.of(context).pop(),
              ),
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
                    'Create Account',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.lightPrimary,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(10)),

                  // ── Subtitle ─────────────────────────────────────────────
                  Text(
                    'Join Mandal Variety for faster deliveries,\neasy tracking, and tailored options.',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(32)),

                  // ── Name label & field ────────────────────────────────────
                  Text(
                    'Full Name',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(8)),

                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    autofocus: false,
                    validator: _vm.validateName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.lightDivider,
                      ),
                      filled: true,
                      fillColor: AppColors.lightSurface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: MediaQueryHelper.scaleWidth(16),
                        vertical: MediaQueryHelper.scaleHeight(14),
                      ),
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: focusedInputBorder,
                      errorBorder: errorInputBorder,
                      focusedErrorBorder: focusedErrorInputBorder,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(20)),

                  // ── Email label & field ───────────────────────────────────
                  Text(
                    'Email address',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(8)),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
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
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: focusedInputBorder,
                      errorBorder: errorInputBorder,
                      focusedErrorBorder: focusedErrorInputBorder,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(20)),

                  // ── Phone label & field ───────────────────────────────────
                  Text(
                    'Phone number',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(8)),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    validator: _vm.validatePhone,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.lightDivider,
                      ),
                      filled: true,
                      fillColor: AppColors.lightSurface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: MediaQueryHelper.scaleWidth(16),
                        vertical: MediaQueryHelper.scaleHeight(14),
                      ),
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: focusedInputBorder,
                      errorBorder: errorInputBorder,
                      focusedErrorBorder: focusedErrorInputBorder,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(20)),

                  // ── Password label & field ────────────────────────────────
                  Text(
                    'Password',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(8)),

                  TextFormField(
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    obscureText: _obscurePassword,
                    autocorrect: false,
                    onFieldSubmitted: (_) => _register(),
                    validator: _vm.validatePassword,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Create a password (min. 6 chars)',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.lightDivider,
                      ),
                      filled: true,
                      fillColor: AppColors.lightSurface,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: MediaQueryHelper.scaleWidth(16),
                        vertical: MediaQueryHelper.scaleHeight(14),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.lightTextSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: focusedInputBorder,
                      errorBorder: errorInputBorder,
                      focusedErrorBorder: focusedErrorInputBorder,
                    ),
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(36)),

                  // ── Register button ───────────────────────────────────────
                  AppButton.primary(
                    text: 'Register',
                    onPressed: _isRegistering ? null : _register,
                    isLoading: _isRegistering,
                    isFullWidth: true,
                  ),

                  SizedBox(height: MediaQueryHelper.scaleHeight(24)),

                  // ── Already have an account? Login ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: Text(
                          'Login',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.lightPrimary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.lightPrimary,
                          ),
                        ),
                      ),
                    ],
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
