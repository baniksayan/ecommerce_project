import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../image_viewer/zoomable_image_viewer.dart';

class AppDrawer extends StatelessWidget {
  final String? profilePicUrl;
  final String? userName; // If null, assume 'Guest User'

  const AppDrawer({Key? key, this.profilePicUrl, this.userName})
    : super(key: key);

  void _handleTap(BuildContext context, String actionMessage) {
    HapticFeedback.selectionClick();
  }

  bool get _isGuest => false;

  Widget _buildProfileAvatar(BuildContext context, {double radius = 30}) {
    // If testing logged in state and no URL is provided, fallback to a mock handsome man image.
    final String? effectivePicUrl = _isGuest
        ? null
        : (profilePicUrl != null && profilePicUrl!.isNotEmpty
              ? profilePicUrl!
              : 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=387&auto=format&fit=crop');

    final hasImage = effectivePicUrl != null;
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.teaGreenSoft,
      backgroundImage: hasImage ? NetworkImage(effectivePicUrl) : null,
      child: hasImage
          ? null
          : Icon(Icons.person, size: radius * 1.2, color: AppColors.dustyOlive),
    );

    if (hasImage) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ZoomableImageViewer.show(
            context,
            imageProvider: NetworkImage(effectivePicUrl),
            heroTag: 'profile_pic_zoom',
          );
        },
        child: Hero(tag: 'profile_pic_zoom', child: avatar),
      );
    }

    return avatar;
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final theme = Theme.of(context);

    // Test data for previewing the UI
    final String displayUserName = userName ?? 'Alex';

    final String titleText = _isGuest ? 'Guest User' : 'Hi, $displayUserName!';
    final String subtitleText = _isGuest
        ? 'Login or Sign up'
        : 'View or edit your profile';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileAvatar(context),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleText,
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _handleTap(
                    context,
                    _isGuest ? 'Login/Signup Clicked' : 'View Profile Clicked',
                  ),
                  child: Text(
                    subtitleText,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: theme.disabledColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? (theme.brightness == Brightness.dark
              ? AppColors.darkError
              : AppColors.lightError)
        : theme.iconTheme.color;

    return InkWell(
      onTap: () => _handleTap(context, '$title Clicked'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isDestructive
                      ? color
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGuest = userName == null;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          _buildDrawerHeader(context),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              physics: const ClampingScrollPhysics(),
              children: [
                _buildSectionTitle(context, 'Categories'),
                _buildDrawerItem(
                  context,
                  title: 'Groceries',
                  icon: Icons.local_grocery_store_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Beauty',
                  icon: Icons.face_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Shoes',
                  icon: Icons.snowshoeing_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Fresh Items',
                  icon: Icons.eco_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Snacks',
                  icon: Icons.fastfood_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Drinks',
                  icon: Icons.local_drink_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Dairy',
                  icon: Icons.egg_alt_outlined,
                ),

                _buildSectionTitle(context, 'Utilities'),
                _buildDrawerItem(
                  context,
                  title: 'My Addresses',
                  icon: Icons.location_on_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Help & Support',
                  icon: Icons.help_outline,
                ),
                _buildDrawerItem(
                  context,
                  title: 'FAQs',
                  icon: Icons.question_answer_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Contact Us',
                  icon: Icons.contact_support_outlined,
                ),

                _buildSectionTitle(context, 'Legal & Trust'),
                _buildDrawerItem(
                  context,
                  title: 'Terms & Conditions',
                  icon: Icons.description_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: 'Cancellation Policy',
                  icon: Icons.cancel_outlined,
                ),
                _buildDrawerItem(
                  context,
                  title: '18+ Age Restriction Policy',
                  icon: Icons.warning_amber_outlined,
                ),

                const SizedBox(height: 32),
                if (!isGuest) ...[
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 8),
                  _buildDrawerItem(
                    context,
                    title: 'Logout',
                    icon: Icons.logout,
                    isDestructive: true,
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
              child: Center(
                child: Text(
                  'App Version 1.0.0',
                  style: AppTextStyles.caption.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
