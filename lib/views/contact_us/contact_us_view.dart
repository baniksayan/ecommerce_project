import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../common/buttons/app_button.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../../core/theme/app_text_styles.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../main/main_view.dart';

class ContactUsView extends StatefulWidget {
  final int currentBottomBarIndex;

  const ContactUsView({super.key, required this.currentBottomBarIndex});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<ContactUsView> {
  bool _isLaunchingMaps = false;

  static const String _supportEmail = 'sayanbanikcob@gmail.com';
  static const String _supportEmailSubject =
      'Support Request - Mandal Variety';

  static const String _supportPhoneDisplay = '+91 8967136033';
  static const String _supportPhoneDial = '+918967136033';

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

  Future<void> _launchMaps() async {
    setState(() => _isLaunchingMaps = true);
    try {
      const double lat = 26.230576612735344;
      const double lng = 89.60909564188326;

      // Attempt geo: scheme first (opens default Maps app)
      final Uri geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng(Mandal+Variety)');
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to web link if geo: scheme isn't supported (e.g. some iOS devices without Maps)
      final Uri webUri = Uri.parse('https://maps.app.goo.gl/xYvGbHuYkD3FosZq6');
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch maps');
      }
    } finally {
      if (mounted) {
        setState(() => _isLaunchingMaps = false);
      }
    }
  }

  Future<void> _launchSupportEmail() async {
    // Build explicitly to ensure consistent percent-encoding across platforms.
    // Some mail clients display '+' literally instead of treating it as a space.
    final String encodedSubject = Uri.encodeComponent(_supportEmailSubject);
    final Uri mailUri = Uri.parse('mailto:$_supportEmail?subject=$encodedSubject');

    try {
      final bool launched = await launchUrl(
        mailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        AppSnackbar.error(context, 'No email app found on this device');
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, 'No email app found on this device');
      }
    }
  }

  Future<void> _launchSupportCall() async {
    final Uri telUri = Uri(scheme: 'tel', path: _supportPhoneDial);

    try {
      final bool launched = await launchUrl(
        telUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        AppSnackbar.error(
          context,
          'Could not open phone app for $_supportPhoneDisplay',
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          'Could not open phone app for $_supportPhoneDisplay',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            isIOS ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Us',
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primaryColor.withValues(alpha: 0.08),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                  },
                ),
              ),
              Positioned(
                right: 16,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildContactCard(
              context,
              icon: Icons.support_agent_rounded,
              title: 'Customer Support',
              subtitle: 'Local support team is available 9 AM - 8 PM',
              actionText: 'Call Now',
              onAction: _launchSupportCall,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: 'Email Us',
              subtitle: 'We usually respond within 24 hours',
              actionText: 'Send Email',
              onAction: _launchSupportEmail,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context,
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Live Chat',
              subtitle: 'Chat directly with our team',
              actionText: 'Start Chat',
              onAction: () {
                AppSnackbar.info(
                  context,
                  'Live chat is coming soon',
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Store Location',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: theme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mandal Variety',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Road, Sareyarpar, Balarampur, West Bengal 736134',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        thickness: 1,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        theme,
                        Icons.map_outlined,
                        'Plus Code',
                        '6JJ5+6J Balarampur, West Bengal',
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        theme,
                        Icons.gps_fixed_rounded,
                        'Coordinates',
                        '26.2305766, 89.6090956',
                      ),
                      const SizedBox(height: 20),
                      AppButton.primary(
                        text: 'Open in Maps',
                        icon: Icons.open_in_new_rounded,
                        isFullWidth: true,
                        isLoading: _isLaunchingMaps,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _launchMaps();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100), // padding for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              onAction();
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              actionText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: theme.primaryColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
