import 'package:flutter/material.dart';
import 'home_widgets.dart';
import '../../common/appbar/common_app_bar.dart';
import '../../common/bottombar/common_bottom_bar.dart';
import '../../common/searchbar/app_search_bar.dart';
import '../../common/image_viewer/zoomable_image_viewer.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _navIndex = 0;

  // Simulate optional profile picture (Set to a URL string or null)
  String? _profilePicUrl;
  // e.g. 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=100';

  // Dummy Data for demonstration
  final List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=800',
  ];

  Widget _buildProfileAvatar({double radius = 20, bool isDrawer = false}) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: _profilePicUrl != null
          ? NetworkImage(_profilePicUrl!)
          : null,
      child: _profilePicUrl == null
          ? Icon(Icons.person, size: radius * 1.2, color: Colors.grey[600])
          : null,
    );

    if (isDrawer && _profilePicUrl != null) {
      return GestureDetector(
        onTap: () {
          ZoomableImageViewer.show(
            context,
            imageProvider: NetworkImage(_profilePicUrl!),
            heroTag: 'profile_pic_zoom',
          );
        },
        child: Hero(tag: 'profile_pic_zoom', child: avatar),
      );
    }

    return avatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Discover',
        showBackButton: false,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: _buildProfileAvatar(radius: 20),
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {},
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Jane Doe'),
              accountEmail: const Text('jane.doe@example.com'),
              currentAccountPicture: _buildProfileAvatar(
                radius: 40,
                isDrawer: true,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: AppSearchBar(
                hintText: 'Search for products, brands...',
                onChanged: (val) => debugPrint('Searching: $val'),
              ),
            ),

            const SizedBox(height: 16),

            // Promo Carousel
            EcommercePromoCarousel(
              imageUrls: _carouselImages,
              height: 160,
              onBannerTap: () => debugPrint('Banner Tapped'),
            ),

            const SizedBox(height: 24),

            // Categories View
            EcommerceCategoryRow(
              categories: [
                EcommerceCategoryItem(
                  label: 'Fashion',
                  icon: Icons.checkroom,
                  onTap: () {},
                ),
                EcommerceCategoryItem(
                  label: 'Electronics',
                  icon: Icons.devices,
                  onTap: () {},
                ),
                EcommerceCategoryItem(
                  label: 'Home',
                  icon: Icons.chair,
                  onTap: () {},
                ),
                EcommerceCategoryItem(
                  label: 'Beauty',
                  icon: Icons.face,
                  onTap: () {},
                ),
                EcommerceCategoryItem(
                  label: 'Sports',
                  icon: Icons.sports_basketball,
                  onTap: () {},
                ),
                EcommerceCategoryItem(
                  label: 'Toys',
                  icon: Icons.toys,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Trending Products Section
            EcommerceSectionTitle(
              title: 'Trending Products',
              actionText: 'See All',
              onActionTap: () {},
            ),

            EcommerceHorizontalProductList(
              products: [
                EcommerceProductCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
                  title: 'Sony Wireless Headphones',
                  price: 99.99,
                  originalPrice: 149.99,
                  discountTag: '33% OFF',
                  rating: 4.8,
                  reviewCount: 124,
                  onTap: () {},
                  onAddToCart: () {},
                ),
                EcommerceProductCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&q=80&w=400',
                  title: 'Smart Watch Series 6',
                  price: 199.99,
                  originalPrice: 249.99,
                  discountTag: '20% OFF',
                  rating: 4.6,
                  reviewCount: 382,
                  onTap: () {},
                  onAddToCart: () {},
                ),
                EcommerceProductCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1618366712010-f4ae9c647bcb?auto=format&fit=crop&q=80&w=400',
                  title: 'Casual Denim Jacket',
                  price: 45.00,
                  originalPrice: 60.00,
                  discountTag: '25% OFF',
                  rating: 4.3,
                  reviewCount: 89,
                  onTap: () {},
                  onAddToCart: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Offer Banner
            EcommerceOfferBanner(
              title: 'Summer Collection',
              subtitle: 'Up to 50% Off on select items',
              imageUrl:
                  'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&q=80&w=800',
              onTap: () {},
            ),

            const SizedBox(height: 16),

            // New Arrivals Section
            EcommerceSectionTitle(
              title: 'New Arrivals',
              actionText: 'Explore',
              onActionTap: () {},
            ),

            EcommerceHorizontalProductList(
              products: [
                EcommerceProductCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&q=80&w=400',
                  title: 'Classic Vans Sneakers',
                  price: 59.99,
                  rating: 4.7,
                  reviewCount: 540,
                  onTap: () {},
                  onAddToCart: () {},
                ),
                EcommerceProductCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&q=80&w=400',
                  title: 'Minimalist Clock',
                  price: 24.50,
                  rating: 4.5,
                  reviewCount: 12,
                  onTap: () {},
                  onAddToCart: () {},
                ),
                EcommerceProductCard(
                  imageUrl:
                      'https://images.unsplash.com/photo-1506152983158-b4a74a01c721?auto=format&fit=crop&q=80&w=400',
                  title: 'Leather Wallet',
                  price: 35.00,
                  rating: 4.9,
                  reviewCount: 300,
                  onTap: () {},
                  onAddToCart: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: CommonBottomBar(
        currentIndex: _navIndex,
        onTap: (val) => setState(() => _navIndex = val),
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
