import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../home/home_view.dart';
import '../wishlist/wishlist_view.dart';
import '../orders/orders_view.dart';

class MainView extends StatefulWidget {
  final int initialIndex;

  const MainView({super.key, this.initialIndex = 0});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late int _navIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _navIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _navIndex);
  }

  void _onPageChanged(int index) {
    if (_navIndex != index) {
      HapticFeedback.selectionClick();
      setState(() => _navIndex = index);
    }
  }

  void _onTabTapped(int index) {
    if (_navIndex != index) {
      HapticFeedback.selectionClick();
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        children: [const HomeView(), const WishlistView(), const OrdersView()],
      ),
      bottomNavigationBar: CommonBottomBar(
        currentIndex: _navIndex,
        onTap: _onTabTapped,
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
    );
  }
}
