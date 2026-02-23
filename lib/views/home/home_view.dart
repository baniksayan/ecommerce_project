import 'package:flutter/material.dart';
import '../../common/appbar/common_app_bar.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../../common/buttons/app_button.dart';
import '../../common/cards/app_card.dart';
import '../../common/dialogs/app_dialog.dart';
import '../../common/dropdowns/app_dropdown.dart';
import '../../common/image_viewer/zoomable_image_viewer.dart';
import '../../common/searchbar/app_search_bar.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../../common/tabbar/common_tab_bar.dart';
import '../../common/toasts/app_toast.dart';
import '../../core/responsive/media_query_helper.dart';
import '../../core/theme/app_text_styles.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _navIndex = 0;
  int _tabIndex = 0;
  String _selectedValue = 'Option 1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildShowcaseContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search & Inputs', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          AppSearchBar(
            hintText: 'Search components...',
            onChanged: (val) => debugPrint('Searching: $val'),
          ),
          const SizedBox(height: 16),
          AppDropdown<String>(
            label: 'Select Variant',
            value: _selectedValue,
            items: [
              'Option 1',
              'Option 2',
              'Option 3',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedValue = val!),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          Text('Interactive Cards', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          AppCard.action(
            onTap: () => AppToast.success(context, 'Card Tapped!'),
            child: Row(
              children: [
                const Icon(Icons.touch_app, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Action Card', style: AppTextStyles.heading3),
                      const Text('Tap me to see a Toast'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          Text('Notifications & Overlays', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppButton.primary(
                text: 'Toast: Info',
                icon: Icons.info,
                onPressed: () =>
                    AppToast.info(context, 'This is an info toast!'),
              ),
              AppButton.secondary(
                text: 'Snackbar: Error',
                icon: Icons.error,
                onPressed: () =>
                    AppSnackbar.error(context, 'Uh oh, something broke.'),
              ),
              AppButton.outline(
                text: 'Toast: Loading',
                isLoading: true,
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          Text('Dialogs', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          AppButton.primary(
            isFullWidth: true,
            text: 'Destructive Dialog',
            onPressed: () async {
              final confirmed = await AppDialog.showConfirm(
                context: context,
                title: 'Delete Forest?',
                message: 'This will burn down all trees permanently.',
                isDestructive: true,
                confirmText: 'Burn it',
              );
              if (confirmed == true && context.mounted) {
                AppSnackbar.success(context, 'Forest burned successfully.');
              }
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          Text('Media Viewer', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              ZoomableImageViewer.show(
                context,
                imageProvider: const NetworkImage(
                  'https://images.unsplash.com/photo-1542204165-65bf26472b9b?auto=format&fit=crop&q=80',
                ),
                heroTag: 'forest_img',
              );
            },
            child: Hero(
              tag: 'forest_img',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://images.unsplash.com/photo-1542204165-65bf26472b9b?auto=format&fit=crop&w=500&q=80',
                  height: MediaQueryHelper.scaleHeight(200),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Component Gallery',
        showBackButton: false,
        trailing: Icon(Icons.palette),
      ),
      body: Column(
        children: [
          CommonTabBar(
            tabController: _tabController,
            tabs: const ['Components', 'Layouts', 'Settings'],
            currentIndex: _tabIndex,
            onTabChanged: (val) => setState(() => _tabIndex = val),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics:
                  const NeverScrollableScrollPhysics(), // Disabling swipe sync for simplicity with Cupertino picker
              children: [
                _buildShowcaseContent(context),
                const Center(child: Text('Layouts Tab Placeholder')),
                const Center(child: Text('Settings Tab Placeholder')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CommonBottomBar(
        currentIndex: _navIndex,
        onTap: (val) => setState(() => _navIndex = val),
        items: [
          CommonBottomBarItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Gallery',
          ),
          CommonBottomBarItem(
            icon: Icons.eco_outlined,
            activeIcon: Icons.eco,
            label: 'Forest',
          ),
          CommonBottomBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
