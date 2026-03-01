import 'package:flutter/material.dart';
import 'home_widgets.dart';
import '../../common/drawer/app_drawer.dart';
import '../../common/appbar/primary_sliver_app_bar.dart';
import '../../common/snackbars/app_snackbar.dart';
import '../../core/cart/cart_coordinator.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../product_listing/product_listing_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Simulate optional profile picture (Set to a URL string or null)
  String? _profilePicUrl;
  // e.g. 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=100';

  // Dummy Data for demonstration
  final List<String> _carouselImages = [
    'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&q=80&w=800',
  ];

  final List<String> _bannerTitles = [
    'Summer Collection',
    'Winter Clearance',
    'Weekend Flash Sale',
    'New Arrivals',
  ];
  final List<String> _bannerSubtitles = [
    'Up to 50% Off on select items',
    'Save big on cold weather gear',
    'Discounts ending Sunday',
    'Latest trends and gears',
  ];
  final List<String> _bannerImages = [
    'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1441986300917-64674bd600d8?auto=format&fit=crop&q=80&w=800',
    'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&q=80&w=800',
  ];

  final List<String> _sectionTitles = [
    'Groceries You Need',
    'Fresh & Daily Picks',
    'Snack Time Favourites',
    'Beauty Must-Haves',
    'Drinks for Every Mood',
    'Dairy Essentials',
    'Everyday Essentials',
  ];

  final List<Map<String, dynamic>> _mockProducts = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=400',
      'title': 'Sony Wireless Headphones',
      'price': 99.99,
      'originalPrice': 149.99,
      'discountTag': '33% OFF',
      'rating': 4.8,
      'reviewCount': 124,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&q=80&w=400',
      'title': 'Smart Watch Series 6',
      'price': 199.99,
      'originalPrice': 249.99,
      'discountTag': '20% OFF',
      'rating': 4.6,
      'reviewCount': 382,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1618366712010-f4ae9c647bcb?auto=format&fit=crop&q=80&w=400',
      'title': 'Casual Denim Jacket',
      'price': 45.00,
      'originalPrice': 60.00,
      'discountTag': '25% OFF',
      'rating': 4.3,
      'reviewCount': 89,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&q=80&w=400',
      'title': 'Classic Vans Sneakers',
      'price': 59.99,
      'rating': 4.7,
      'reviewCount': 540,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1524805444758-089113d48a6d?auto=format&fit=crop&q=80&w=400',
      'title': 'Minimalist Clock',
      'price': 24.50,
      'rating': 4.5,
      'reviewCount': 12,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1506152983158-b4a74a01c721?auto=format&fit=crop&q=80&w=400',
      'title': 'Leather Wallet',
      'price': 35.00,
      'rating': 4.9,
      'reviewCount': 300,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1583394838336-acd977736f90?auto=format&fit=crop&q=80&w=400',
      'title': 'Premium Wireless Earbuds',
      'price': 79.99,
      'originalPrice': 129.99,
      'discountTag': 'Save 50',
      'rating': 4.6,
      'reviewCount': 412,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&q=80&w=400',
      'title': 'Classic Sunglasses',
      'price': 15.00,
      'originalPrice': 40.00,
      'discountTag': '62% OFF',
      'rating': 4.2,
      'reviewCount': 95,
    },
  ];

  List<EcommerceProductCard> _generateProducts(
    BuildContext context,
    int sectionIndex,
  ) {
    // Generate a diverse, looping sequence based on the section
    final start = (sectionIndex * 3) % _mockProducts.length;
    final List<EcommerceProductCard> list = [];
    for (int i = 0; i < 4; i++) {
      final item = _mockProducts[(start + i) % _mockProducts.length];
      list.add(
        EcommerceProductCard(
          imageUrl: item['imageUrl'] as String,
          title: item['title'] as String,
          price: item['price'] as double,
          originalPrice: item['originalPrice'] as double?,
          discountTag: item['discountTag'] as String?,
          rating: item['rating'] as double?,
          reviewCount: item['reviewCount'] as int?,
          onTap: () {},
          onAddToCart: () {
            CartCoordinator.instance.addItem(
              CartItemModel(
                productId: '${item['title']}-${item['imageUrl']}',
                name: item['title'] as String,
                imageUrl: item['imageUrl'] as String,
                unitPrice: item['price'] as double,
                quantity: 1,
              ),
            );
            AppSnackbar.success(context, '${item['title']} added to cart');
          },
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: AppDrawer(
        profilePicUrl: _profilePicUrl,
        currentBottomBarIndex: 0,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.normal,
        ),
        slivers: [
          PrimarySliverAppBar(
            searchHintText: 'Search groceries, beauty...',
            searchStaticPrefix: 'Search ',
            searchAnimatedHints: const [
              'groceries...',
              'beauty products...',
              'shoes...',
              'fresh items...',
              'snacks...',
              'drinks...',
              'dairy...',
            ],
            onSearchChanged: (val) => debugPrint('Searching: $val'),
            currentBottomBarIndex: 0,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Promo Carousel
                EcommercePromoCarousel(
                  imageUrls: _carouselImages,
                  height: 180,
                  onBannerTap: () => debugPrint('Banner Tapped'),
                ),
                const SizedBox(height: 32),
                // Categories View
                EcommerceCategoryRow(
                  categories: [
                    EcommerceCategoryItem(
                      label: 'Grocery',
                      icon: Icons.local_grocery_store,
                      onTap: () {
                        Navigator.of(context).push(
                          ProductListingView.route(
                            category: ProductCategory.grocery,
                            currentBottomBarIndex: 0,
                          ),
                        );
                      },
                    ),
                    EcommerceCategoryItem(
                      label: 'Beauty',
                      icon: Icons.face,
                      onTap: () {
                        Navigator.of(context).push(
                          ProductListingView.route(
                            category: ProductCategory.beauty,
                            currentBottomBarIndex: 0,
                          ),
                        );
                      },
                    ),
                    EcommerceCategoryItem(
                      label: 'Shoes',
                      icon: Icons.snowshoeing,
                      onTap: () {
                        Navigator.of(context).push(
                          ProductListingView.route(
                            category: ProductCategory.shoes,
                            currentBottomBarIndex: 0,
                          ),
                        );
                      },
                    ),
                    EcommerceCategoryItem(
                      label: 'Fresh',
                      icon: Icons.eco,
                      onTap: () {
                        Navigator.of(context).push(
                          ProductListingView.route(
                            category: ProductCategory.fresh,
                            currentBottomBarIndex: 0,
                          ),
                        );
                      },
                    ),
                    EcommerceCategoryItem(
                      label: 'Snacks',
                      icon: Icons.fastfood,
                      onTap: () {
                        Navigator.of(context).push(
                          ProductListingView.route(
                            category: ProductCategory.snacks,
                            currentBottomBarIndex: 0,
                          ),
                        );
                      },
                    ),
                    EcommerceCategoryItem(
                      label: 'Drinks',
                      icon: Icons.local_drink,
                      onTap: () {
                        Navigator.of(context).push(
                          ProductListingView.route(
                            category: ProductCategory.drinks,
                            currentBottomBarIndex: 0,
                          ),
                        );
                      },
                    ),
                    EcommerceCategoryItem(
                      label: 'Dairy',
                      icon: Icons.egg_alt,
                      onTap: () {
                        Navigator.of(context).push(
                          ProductListingView.route(
                            category: ProductCategory.dairy,
                            currentBottomBarIndex: 0,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Infinite Section Builder
          SliverList.builder(
            itemBuilder: (context, index) {
              if (index % 2 == 0) {
                // Return a product list section
                final sectionIndex = index ~/ 2;
                final title =
                    _sectionTitles[sectionIndex % _sectionTitles.length];
                final products = _generateProducts(context, sectionIndex);

                return Column(
                  children: [
                    EcommerceSectionTitle(title: title, onActionTap: () {}),
                    EcommerceHorizontalProductList(products: products),
                    const SizedBox(height: 24),
                  ],
                );
              } else {
                // Return an offer banner
                final bannerIndex = index ~/ 2;
                final bannerImage =
                    _bannerImages[bannerIndex % _bannerImages.length];
                final bannerTitle =
                    _bannerTitles[bannerIndex % _bannerTitles.length];
                final bannerSubtitle =
                    _bannerSubtitles[bannerIndex % _bannerSubtitles.length];

                return Column(
                  children: [
                    EcommerceOfferBanner(
                      title: bannerTitle,
                      subtitle: bannerSubtitle,
                      imageUrl: bannerImage,
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
