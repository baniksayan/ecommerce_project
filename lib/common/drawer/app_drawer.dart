import 'package:mandal_variety/views/age_restriction_policy/age_restriction_policy_view.dart';
import 'package:mandal_variety/views/addresses/my_addresses_view.dart';
import 'package:mandal_variety/views/cancellation_policy/cancellation_policy_view.dart';
import 'package:mandal_variety/views/privacy_policy/privacy_policy_view.dart';
import 'package:mandal_variety/views/terms_and_conditions/terms_and_conditions_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../views/contact_us/contact_us_view.dart';
import '../image_viewer/zoomable_image_viewer.dart';

class AppDrawer extends StatefulWidget {
  final String? profilePicUrl;
  final String? userName; // If null, assume 'Guest User'
  final int? currentBottomBarIndex;

  const AppDrawer({
    super.key,
    this.profilePicUrl,
    this.userName,
    this.currentBottomBarIndex,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  bool _isFaqsExpanded = false;
  late AnimationController _faqsController;
  late Animation<double> _faqsExpandAnim;
  late Animation<double> _faqsRotateAnim;

  bool _isHelpExpanded = false;
  late AnimationController _helpController;
  late Animation<double> _helpExpandAnim;
  late Animation<double> _helpRotateAnim;

  static const String _storeName = 'Mandal Variety';

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How can I place an order?',
      'a':
          'Simply browse products, add them to your cart, and place the order. We currently accept Cash on Delivery (COD) for a smooth and simple experience.',
    },
    {
      'q': 'How will I receive my order?',
      'a':
          'Our local delivery partner will deliver your order directly to your doorstep within the service area of $_storeName.',
    },
    {
      'q': 'How long does delivery take?',
      'a':
          'Most orders are delivered on the same day or within 24 hours, depending on product availability and delivery location.',
    },
    {
      'q': 'Can I cancel my order?',
      'a':
          'Yes, you can cancel your order before it is out for delivery. Please go to the Orders section or contact us directly for quick support.',
    },
    {
      'q': 'What if I receive a damaged item?',
      'a':
          'If you receive a damaged or incorrect product, please contact us immediately. We will review the issue and provide a replacement if applicable.',
    },
    {
      'q': 'Do you accept online payments?',
      'a':
          'Currently, we are accepting Cash on Delivery (COD) only for your convenience. Online payment options may be added in the future.',
    },
    {
      'q': 'Is there a minimum order amount?',
      'a':
          'There may be a minimum order amount depending on the delivery location. Any applicable charges will be shown before placing the order.',
    },
    {
      'q': 'Do you charge for delivery?',
      'a':
          'A small delivery charge may apply based on your area and order value. The final amount will always be visible before confirming your order.',
    },
    {
      'q': 'Can I order tobacco products?',
      'a':
          'Yes, tobacco products are available separately and are strictly for customers aged 18 and above. Age verification may be required at delivery.',
    },
    {
      'q': 'How can I contact $_storeName?',
      'a':
          'You can contact us through the Help section in the app or directly call the shop during working hours for quick assistance.',
    },
  ];

  final List<Map<String, String>> _helpTopics = [
    {
      'title': 'Delivery Areas',
      'desc':
          'We currently deliver within the immediate service area of $_storeName. Check your postal code at checkout.',
    },
    {
      'title': 'Payment Issues',
      'desc':
          'If you face issues finding Cash on Delivery (COD) as an option, ensure your address is within our service area.',
    },
    {
      'title': 'Returns & Refunds',
      'desc':
          'Initiate a return within 3 days for eligible items from the Orders section. We will process it shortly.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _faqsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _faqsExpandAnim = CurvedAnimation(
      parent: _faqsController,
      curve: Curves.easeInOut,
    );
    _faqsRotateAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _faqsController, curve: Curves.easeInOut),
    );

    _helpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _helpExpandAnim = CurvedAnimation(
      parent: _helpController,
      curve: Curves.easeInOut,
    );
    _helpRotateAnim = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _helpController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _faqsController.dispose();
    _helpController.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context, String actionMessage) {
    HapticFeedback.selectionClick();
  }

  bool get _isGuest => false;

  Widget _buildProfileAvatar(BuildContext context, {double radius = 30}) {
    // If testing logged in state and no URL is provided, fallback to a mock handsome man image.
    final String? effectivePicUrl = _isGuest
        ? null
        : (widget.profilePicUrl != null && widget.profilePicUrl!.isNotEmpty
              ? widget.profilePicUrl!
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
    final String displayUserName = widget.userName ?? 'Sayan';

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
    VoidCallback? onTap,
    Widget? trailingWidget,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? (theme.brightness == Brightness.dark
              ? AppColors.darkError
              : AppColors.lightError)
        : theme.iconTheme.color;

    return InkWell(
      onTap: onTap ?? () => _handleTap(context, '$title Clicked'),
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
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGuest = widget.userName == null;

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
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyAddressesView(
                          currentBottomBarIndex:
                              widget.currentBottomBarIndex ?? 0,
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: 'Help & Support',
                  icon: Icons.help_outline,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isHelpExpanded = !_isHelpExpanded;
                      if (_isHelpExpanded) {
                        _helpController.forward();
                      } else {
                        _helpController.reverse();
                      }
                    });
                  },
                  trailingWidget: RotationTransition(
                    turns: _helpRotateAnim,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _isHelpExpanded
                          ? theme.primaryColor
                          : theme.iconTheme.color,
                      size: 20,
                    ),
                  ),
                ),
                SizeTransition(
                  sizeFactor: _helpExpandAnim,
                  axisAlignment: -1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.black.withValues(alpha: 0.02),
                    ),
                    child: Column(
                      children: [
                        ..._helpTopics.map((topic) {
                          return _buildSubItemTile(
                            context,
                            topic['title']!,
                            topic['desc']!,
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 60,
                            right: 20,
                            top: 4,
                            bottom: 16,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContactUsView(
                                      currentBottomBarIndex:
                                          widget.currentBottomBarIndex ?? 0,
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: theme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Contact Us',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  title: 'FAQs',
                  icon: Icons.question_answer_outlined,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isFaqsExpanded = !_isFaqsExpanded;
                      if (_isFaqsExpanded) {
                        _faqsController.forward();
                      } else {
                        _faqsController.reverse();
                      }
                    });
                  },
                  trailingWidget: RotationTransition(
                    turns: _faqsRotateAnim,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _isFaqsExpanded
                          ? theme.primaryColor
                          : theme.iconTheme.color,
                      size: 20,
                    ),
                  ),
                ),
                SizeTransition(
                  sizeFactor: _faqsExpandAnim,
                  axisAlignment: -1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.02)
                          : Colors.black.withValues(alpha: 0.02),
                    ),
                    child: Column(
                      children: _faqs.map((faq) {
                        return _buildSubItemTile(context, faq['q']!, faq['a']!);
                      }).toList(),
                    ),
                  ),
                ),
                _buildDrawerItem(
                  context,
                  title: 'Contact Us',
                  icon: Icons.contact_support_outlined,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactUsView(
                          currentBottomBarIndex:
                              widget.currentBottomBarIndex ?? 0,
                        ),
                      ),
                    );
                  },
                ),

                _buildSectionTitle(context, 'Legal & Trust'),
                _buildDrawerItem(
                  context,
                  title: 'Terms & Conditions',
                  icon: Icons.description_outlined,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsAndConditionsView(
                          currentBottomBarIndex:
                              widget.currentBottomBarIndex ?? 0,
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicyView(
                          currentBottomBarIndex:
                              widget.currentBottomBarIndex ?? 0,
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: 'Cancellation Policy',
                  icon: Icons.cancel_outlined,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CancellationPolicyView(
                          currentBottomBarIndex:
                              widget.currentBottomBarIndex ?? 0,
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  title: '18+ Age Restriction Policy',
                  icon: Icons.warning_amber_outlined,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgeRestrictionPolicyView(
                          currentBottomBarIndex:
                              widget.currentBottomBarIndex ?? 0,
                        ),
                      ),
                    );
                  },
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

  Widget _buildSubItemTile(
    BuildContext context,
    String title,
    String description,
  ) {
    return _DrawerSubItem(title: title, description: description);
  }
}

class _DrawerSubItem extends StatefulWidget {
  final String title;
  final String description;

  const _DrawerSubItem({required this.title, required this.description});

  @override
  State<_DrawerSubItem> createState() => _DrawerSubItemState();
}

class _DrawerSubItemState extends State<_DrawerSubItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;
  late Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _rotateAnim = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _toggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 40), // Indent to align with text above
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _expanded
                          ? theme.primaryColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: _rotateAnim,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _expanded
                        ? theme.primaryColor
                        : theme.iconTheme.color,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizeTransition(
              sizeFactor: _expandAnim,
              axisAlignment: -1.0,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 16,
                  top: 8,
                  bottom: 4,
                ),
                child: Text(
                  widget.description,
                  style: AppTextStyles.caption.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
