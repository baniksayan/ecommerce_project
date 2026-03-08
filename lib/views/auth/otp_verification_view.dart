import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/responsive/media_query_helper.dart';
import '../../common/buttons/app_button.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../views/main/main_view.dart';

// ============================================================================
// OTP VERIFICATION VIEW
// Displays 6 digit OTP boxes backed by a single hidden TextField.
// Includes a 30-second resend cooldown timer.
// ============================================================================

class OtpVerificationView extends StatefulWidget {
  final String email;

  const OtpVerificationView({super.key, required this.email});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  final _vm = AuthViewModel();

  bool _isVerifying = false;
  String? _errorMessage;

  // ── Resend cooldown ───────────────────────────────────────────────────────
  bool _canResend = false;
  int _resendCooldown = 30;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _otpFocusNode.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onOtpChanged() {
    if (_errorMessage != null) setState(() => _errorMessage = null);
    if (_otpController.text.length == 6) _verify();
  }

  void _startResendCooldown() {
    _canResend = false;
    _resendCooldown = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;
    await _vm.sendOtp(widget.email);
    if (!mounted) return;
    _otpController.clear();
    setState(() => _errorMessage = null);
    _startResendCooldown();
  }

  Future<void> _verify() async {
    final code = _otpController.text;
    if (code.length < 6) {
      setState(() => _errorMessage = 'Enter all 6 digits to continue.');
      return;
    }
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final ok = await _vm.verifyOtp(email: widget.email, code: code);

    if (!mounted) return;

    if (ok) {
      // Clear the entire navigation stack so back-press cannot return
      // to the auth flow after successful login.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainView()),
        (route) => false,
      );
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Invalid code. Please try again.';
        _otpController.clear();
      });
      _otpFocusNode.requestFocus();
    }
  }

  // ── Mask email for display: a**@domain.com ────────────────────────────────
  String _maskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) return email;
    return '${local[0]}${'*' * (local.length - 2)}${local[local.length - 1]}@$domain';
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
        leading: IconButton(
          icon: Icon(
            Platform.isIOS
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
          onTap: () => _otpFocusNode.requestFocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQueryHelper.scaleWidth(24),
              vertical: MediaQueryHelper.scaleHeight(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQueryHelper.scaleHeight(8)),

                // ── Title ──────────────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Verify your email',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.lightPrimary,
                    ),
                  ),
                ),

                SizedBox(height: MediaQueryHelper.scaleHeight(10)),

                // ── Subtitle ───────────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Enter the 6-digit code sent to\n${_maskedEmail(widget.email)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: MediaQueryHelper.scaleHeight(48)),

                // ── OTP input area ─────────────────────────────────────────
                _buildOtpInput(),

                // ── Error message ──────────────────────────────────────────
                if (_errorMessage != null) ...[
                  SizedBox(height: MediaQueryHelper.scaleHeight(12)),
                  Text(
                    _errorMessage!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.lightError,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                SizedBox(height: MediaQueryHelper.scaleHeight(48)),

                // ── Verify button ──────────────────────────────────────────
                AppButton.primary(
                  text: 'Verify OTP',
                  onPressed: _isVerifying ? null : _verify,
                  isLoading: _isVerifying,
                  isFullWidth: true,
                ),

                SizedBox(height: MediaQueryHelper.scaleHeight(24)),

                // ── Resend ─────────────────────────────────────────────────
                _buildResendRow(),

                SizedBox(height: MediaQueryHelper.scaleHeight(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── OTP INPUT ─────────────────────────────────────────────────────────────
  // Single hidden TextField drives all 6 visual boxes.

  Widget _buildOtpInput() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Hidden real input — zero-size but accepts keyboard events
        SizedBox(
          width: 1,
          height: 1,
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _otpController,
              focusNode: _otpFocusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        // Visual boxes
        GestureDetector(
          onTap: () => _otpFocusNode.requestFocus(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(6, _buildOtpBox),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    final text = _otpController.text;
    final hasChar = index < text.length;
    final isActive = index == text.length && _otpFocusNode.hasFocus;
    final hasError = _errorMessage != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQueryHelper.scaleWidth(5),
      ),
      width: MediaQueryHelper.scaleWidth(42),
      height: MediaQueryHelper.scaleWidth(50),
      decoration: BoxDecoration(
        color: hasChar ? AppColors.lightSurface : AppColors.lightBackground,
        border: Border.all(
          color: hasError
              ? AppColors.lightError
              : isActive
                  ? AppColors.lightPrimary
                  : AppColors.lightDivider,
          width: isActive || hasError ? 2.0 : 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        hasChar ? text[index] : '',
        style: AppTextStyles.heading2.copyWith(
          color: AppColors.lightTextPrimary,
        ),
      ),
    );
  }

  // ── RESEND ROW ────────────────────────────────────────────────────────────

  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive it? ",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.lightTextSecondary,
          ),
        ),
        _canResend
            ? GestureDetector(
                onTap: _resendOtp,
                child: Text(
                  'Resend OTP',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.lightPrimary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.lightPrimary,
                  ),
                ),
              )
            : Text(
                'Resend in ${_resendCooldown}s',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.lightDivider,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ],
    );
  }
}
