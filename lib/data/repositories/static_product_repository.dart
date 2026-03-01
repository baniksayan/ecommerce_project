import '../models/product_model.dart';
import 'product_repository.dart';

class StaticProductRepository implements ProductRepository {
  const StaticProductRepository();

  @override
  Future<List<ProductModel>> getProducts(ProductCategory category) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final items = _byCategory[category] ?? const <ProductModel>[];
    // Keep static seed data lightweight; enrich missing fields here.
    return items
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final p = entry.value;

          final rating = p.rating ?? (4.1 + ((index % 6) * 0.1));
          final reviewCount = p.reviewCount ?? (85 + (index * 17));

          return p.copyWith(rating: rating, reviewCount: reviewCount);
        })
        .toList(growable: false);
  }

  static const Map<ProductCategory, List<ProductModel>> _byCategory = {
    ProductCategory.grocery: [
      ProductModel(
        id: 'groc-001',
        category: ProductCategory.grocery,
        name: 'Basmati Rice 5kg',
        imageUrl:
            'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?auto=format&fit=crop&w=800&q=60',
        price: 649,
        originalPrice: 699,
        discountTag: '7% OFF',
      ),
      ProductModel(
        id: 'groc-002',
        category: ProductCategory.grocery,
        name: 'Whole Wheat Atta 10kg',
        imageUrl:
            'https://images.unsplash.com/photo-1582515073490-39981397c445?auto=format&fit=crop&w=800&q=60',
        price: 479,
      ),
      ProductModel(
        id: 'groc-003',
        category: ProductCategory.grocery,
        name: 'Toor Dal 1kg',
        imageUrl:
            'https://images.unsplash.com/photo-1615485737651-4163579b5d1f?auto=format&fit=crop&w=800&q=60',
        price: 169,
        originalPrice: 199,
        discountTag: '15% OFF',
      ),
      ProductModel(
        id: 'groc-004',
        category: ProductCategory.grocery,
        name: 'Sunflower Oil 1L',
        imageUrl:
            'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?auto=format&fit=crop&w=800&q=60',
        price: 139,
      ),
      ProductModel(
        id: 'groc-005',
        category: ProductCategory.grocery,
        name: 'Masala Tea 250g',
        imageUrl:
            'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=60',
        price: 119,
        originalPrice: 149,
        discountTag: '20% OFF',
      ),
      ProductModel(
        id: 'groc-006',
        category: ProductCategory.grocery,
        name: 'Sugar 1kg',
        imageUrl:
            'https://images.unsplash.com/photo-1596110895123-4f3c2b2d8d9b?auto=format&fit=crop&w=800&q=60',
        price: 54,
      ),
      ProductModel(
        id: 'groc-007',
        category: ProductCategory.grocery,
        name: 'Iodized Salt 1kg',
        imageUrl:
            'https://images.unsplash.com/photo-1593113630400-ea4288922497?auto=format&fit=crop&w=800&q=60',
        price: 22,
      ),
      ProductModel(
        id: 'groc-008',
        category: ProductCategory.grocery,
        name: 'Turmeric Powder 200g',
        imageUrl:
            'https://images.unsplash.com/photo-1615485290382-441f9d2b8e2b?auto=format&fit=crop&w=800&q=60',
        price: 79,
        originalPrice: 99,
        discountTag: '20% OFF',
      ),
    ],
    ProductCategory.beauty: [
      ProductModel(
        id: 'beaut-001',
        category: ProductCategory.beauty,
        name: 'Vitamin C Face Serum 30ml',
        imageUrl:
            'https://images.unsplash.com/photo-1611930022073-b7a4ba5fcccd?auto=format&fit=crop&w=800&q=60',
        price: 399,
        originalPrice: 499,
        discountTag: '20% OFF',
      ),
      ProductModel(
        id: 'beaut-002',
        category: ProductCategory.beauty,
        name: 'Aloe Vera Gel 200ml',
        imageUrl:
            'https://images.unsplash.com/photo-1620916566393-64c0c3325f7e?auto=format&fit=crop&w=800&q=60',
        price: 169,
      ),
      ProductModel(
        id: 'beaut-003',
        category: ProductCategory.beauty,
        name: 'Moisturizing Body Lotion 400ml',
        imageUrl:
            'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?auto=format&fit=crop&w=800&q=60',
        price: 299,
      ),
      ProductModel(
        id: 'beaut-004',
        category: ProductCategory.beauty,
        name: 'Sunscreen SPF 50 50g',
        imageUrl:
            'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=800&q=60',
        price: 349,
        originalPrice: 399,
        discountTag: '12% OFF',
      ),
      ProductModel(
        id: 'beaut-005',
        category: ProductCategory.beauty,
        name: 'Lip Balm (Pack of 2)',
        imageUrl:
            'https://images.unsplash.com/photo-1619451427882-6aaaded0cc07?auto=format&fit=crop&w=800&q=60',
        price: 129,
      ),
      ProductModel(
        id: 'beaut-006',
        category: ProductCategory.beauty,
        name: 'Hair Shampoo 650ml',
        imageUrl:
            'https://images.unsplash.com/photo-1608248543803-ba20c8d0f2db?auto=format&fit=crop&w=800&q=60',
        price: 279,
        originalPrice: 329,
        discountTag: '15% OFF',
      ),
      ProductModel(
        id: 'beaut-007',
        category: ProductCategory.beauty,
        name: 'Conditioner 300ml',
        imageUrl:
            'https://images.unsplash.com/photo-1631214540561-918a1962fa2d?auto=format&fit=crop&w=800&q=60',
        price: 199,
      ),
      ProductModel(
        id: 'beaut-008',
        category: ProductCategory.beauty,
        name: 'Face Wash 100ml',
        imageUrl:
            'https://images.unsplash.com/photo-1585232351009-aa87416fca90?auto=format&fit=crop&w=800&q=60',
        price: 159,
      ),
    ],
    ProductCategory.shoes: [
      ProductModel(
        id: 'shoe-001',
        category: ProductCategory.shoes,
        name: 'Running Shoes',
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=60',
        price: 1799,
        originalPrice: 2299,
        discountTag: '22% OFF',
      ),
      ProductModel(
        id: 'shoe-002',
        category: ProductCategory.shoes,
        name: 'Casual Sneakers',
        imageUrl:
            'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?auto=format&fit=crop&w=800&q=60',
        price: 1599,
      ),
      ProductModel(
        id: 'shoe-003',
        category: ProductCategory.shoes,
        name: 'Comfort Sandals',
        imageUrl:
            'https://images.unsplash.com/photo-1560769629-975ec94e6a86?auto=format&fit=crop&w=800&q=60',
        price: 899,
      ),
      ProductModel(
        id: 'shoe-004',
        category: ProductCategory.shoes,
        name: 'Sports Trainers',
        imageUrl:
            'https://images.unsplash.com/photo-1539185441755-769473a23570?auto=format&fit=crop&w=800&q=60',
        price: 1999,
        originalPrice: 2499,
        discountTag: '20% OFF',
      ),
      ProductModel(
        id: 'shoe-005',
        category: ProductCategory.shoes,
        name: 'Slip-On Loafers',
        imageUrl:
            'https://images.unsplash.com/photo-1584735175315-9d5df23860e6?auto=format&fit=crop&w=800&q=60',
        price: 1299,
      ),
      ProductModel(
        id: 'shoe-006',
        category: ProductCategory.shoes,
        name: 'Formal Shoes',
        imageUrl:
            'https://images.unsplash.com/photo-1528701800489-20be3c89297d?auto=format&fit=crop&w=800&q=60',
        price: 2199,
      ),
      ProductModel(
        id: 'shoe-007',
        category: ProductCategory.shoes,
        name: 'Walking Shoes',
        imageUrl:
            'https://images.unsplash.com/photo-1606107557195-0e29a4b5b4aa?auto=format&fit=crop&w=800&q=60',
        price: 1499,
      ),
      ProductModel(
        id: 'shoe-008',
        category: ProductCategory.shoes,
        name: 'Gym Shoes',
        imageUrl:
            'https://images.unsplash.com/photo-1562183241-b937e95585b6?auto=format&fit=crop&w=800&q=60',
        price: 1899,
        originalPrice: 2099,
        discountTag: '10% OFF',
      ),
    ],
    ProductCategory.fresh: [
      ProductModel(
        id: 'fresh-001',
        category: ProductCategory.fresh,
        name: 'Bananas (1 dozen)',
        imageUrl:
            'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=800&q=60',
        price: 59,
      ),
      ProductModel(
        id: 'fresh-002',
        category: ProductCategory.fresh,
        name: 'Tomatoes 1kg',
        imageUrl:
            'https://images.unsplash.com/photo-1546470427-e9a6f144d6f9?auto=format&fit=crop&w=800&q=60',
        price: 39,
        originalPrice: 49,
        discountTag: '20% OFF',
      ),
      ProductModel(
        id: 'fresh-003',
        category: ProductCategory.fresh,
        name: 'Potatoes 2kg',
        imageUrl:
            'https://images.unsplash.com/photo-1582515073490-39981397c445?auto=format&fit=crop&w=800&q=60',
        price: 69,
      ),
      ProductModel(
        id: 'fresh-004',
        category: ProductCategory.fresh,
        name: 'Onions 1kg',
        imageUrl:
            'https://images.unsplash.com/photo-1618512496248-a7b2122ab0e8?auto=format&fit=crop&w=800&q=60',
        price: 44,
      ),
      ProductModel(
        id: 'fresh-005',
        category: ProductCategory.fresh,
        name: 'Coriander (1 bunch)',
        imageUrl:
            'https://images.unsplash.com/photo-1626203050465-1f2f14318e3b?auto=format&fit=crop&w=800&q=60',
        price: 19,
      ),
      ProductModel(
        id: 'fresh-006',
        category: ProductCategory.fresh,
        name: 'Apples 1kg',
        imageUrl:
            'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=800&q=60',
        price: 169,
        originalPrice: 199,
        discountTag: '15% OFF',
      ),
      ProductModel(
        id: 'fresh-007',
        category: ProductCategory.fresh,
        name: 'Carrots 1kg',
        imageUrl:
            'https://images.unsplash.com/photo-1582515073490-39981397c445?auto=format&fit=crop&w=800&q=60',
        price: 49,
      ),
      ProductModel(
        id: 'fresh-008',
        category: ProductCategory.fresh,
        name: 'Cucumbers 1kg',
        imageUrl:
            'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=800&q=60',
        price: 39,
      ),
    ],
    ProductCategory.snacks: [
      ProductModel(
        id: 'snack-001',
        category: ProductCategory.snacks,
        name: 'Potato Chips 90g',
        imageUrl:
            'https://images.unsplash.com/photo-1585238342028-4a5b9045b1d7?auto=format&fit=crop&w=800&q=60',
        price: 30,
      ),
      ProductModel(
        id: 'snack-002',
        category: ProductCategory.snacks,
        name: 'Roasted Peanuts 200g',
        imageUrl:
            'https://images.unsplash.com/photo-1615485290382-441f9d2b8e2b?auto=format&fit=crop&w=800&q=60',
        price: 79,
      ),
      ProductModel(
        id: 'snack-003',
        category: ProductCategory.snacks,
        name: 'Chocolate Cookies 250g',
        imageUrl:
            'https://images.unsplash.com/photo-1612198791362-45c1c0db1f2e?auto=format&fit=crop&w=800&q=60',
        price: 99,
        originalPrice: 129,
        discountTag: '23% OFF',
      ),
      ProductModel(
        id: 'snack-004',
        category: ProductCategory.snacks,
        name: 'Popcorn (Butter) 80g',
        imageUrl:
            'https://images.unsplash.com/photo-1604908554259-3fdb59bd4cb4?auto=format&fit=crop&w=800&q=60',
        price: 45,
      ),
      ProductModel(
        id: 'snack-005',
        category: ProductCategory.snacks,
        name: 'Nachos 150g',
        imageUrl:
            'https://images.unsplash.com/photo-1618213837799-25d1d8f7db6d?auto=format&fit=crop&w=800&q=60',
        price: 89,
      ),
      ProductModel(
        id: 'snack-006',
        category: ProductCategory.snacks,
        name: 'Energy Bar (Pack of 6)',
        imageUrl:
            'https://images.unsplash.com/photo-1603398938378-e54a78e2e0f8?auto=format&fit=crop&w=800&q=60',
        price: 199,
        originalPrice: 249,
        discountTag: '20% OFF',
      ),
      ProductModel(
        id: 'snack-007',
        category: ProductCategory.snacks,
        name: 'Namkeen Mix 400g',
        imageUrl:
            'https://images.unsplash.com/photo-1625944525255-68bd42b4b1f2?auto=format&fit=crop&w=800&q=60',
        price: 119,
      ),
      ProductModel(
        id: 'snack-008',
        category: ProductCategory.snacks,
        name: 'Trail Mix 300g',
        imageUrl:
            'https://images.unsplash.com/photo-1615485290382-441f9d2b8e2b?auto=format&fit=crop&w=800&q=60',
        price: 169,
      ),
    ],
    ProductCategory.drinks: [
      ProductModel(
        id: 'drink-001',
        category: ProductCategory.drinks,
        name: 'Orange Juice 1L',
        imageUrl:
            'https://images.unsplash.com/photo-1613399421095-41f5c4216b78?auto=format&fit=crop&w=800&q=60',
        price: 129,
      ),
      ProductModel(
        id: 'drink-002',
        category: ProductCategory.drinks,
        name: 'Cold Coffee 250ml',
        imageUrl:
            'https://images.unsplash.com/photo-1521305916504-4a1121188589?auto=format&fit=crop&w=800&q=60',
        price: 59,
      ),
      ProductModel(
        id: 'drink-003',
        category: ProductCategory.drinks,
        name: 'Green Tea (25 bags)',
        imageUrl:
            'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=800&q=60',
        price: 149,
        originalPrice: 199,
        discountTag: '25% OFF',
      ),
      ProductModel(
        id: 'drink-004',
        category: ProductCategory.drinks,
        name: 'Sparkling Water 750ml',
        imageUrl:
            'https://images.unsplash.com/photo-1589365278144-c9e705f843ba?auto=format&fit=crop&w=800&q=60',
        price: 79,
      ),
      ProductModel(
        id: 'drink-005',
        category: ProductCategory.drinks,
        name: 'Lemon Soda 300ml',
        imageUrl:
            'https://images.unsplash.com/photo-1528756514091-dee5ecaa3278?auto=format&fit=crop&w=800&q=60',
        price: 35,
      ),
      ProductModel(
        id: 'drink-006',
        category: ProductCategory.drinks,
        name: 'Protein Shake 330ml',
        imageUrl:
            'https://images.unsplash.com/photo-1572441710534-6805c9b3e1a5?auto=format&fit=crop&w=800&q=60',
        price: 179,
        originalPrice: 199,
        discountTag: '10% OFF',
      ),
      ProductModel(
        id: 'drink-007',
        category: ProductCategory.drinks,
        name: 'Coconut Water 200ml',
        imageUrl:
            'https://images.unsplash.com/photo-1546549039-49f9a9b9814b?auto=format&fit=crop&w=800&q=60',
        price: 45,
      ),
      ProductModel(
        id: 'drink-008',
        category: ProductCategory.drinks,
        name: 'Masala Chai 500ml',
        imageUrl:
            'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=60',
        price: 79,
      ),
    ],
    ProductCategory.dairy: [
      ProductModel(
        id: 'dairy-001',
        category: ProductCategory.dairy,
        name: 'Milk 1L',
        imageUrl:
            'https://images.unsplash.com/photo-1585238342028-4a5b9045b1d7?auto=format&fit=crop&w=800&q=60',
        price: 62,
      ),
      ProductModel(
        id: 'dairy-002',
        category: ProductCategory.dairy,
        name: 'Curd 500g',
        imageUrl:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=800&q=60',
        price: 49,
      ),
      ProductModel(
        id: 'dairy-003',
        category: ProductCategory.dairy,
        name: 'Paneer 200g',
        imageUrl:
            'https://images.unsplash.com/photo-1625944525255-68bd42b4b1f2?auto=format&fit=crop&w=800&q=60',
        price: 89,
      ),
      ProductModel(
        id: 'dairy-004',
        category: ProductCategory.dairy,
        name: 'Butter 100g',
        imageUrl:
            'https://images.unsplash.com/photo-1612198791362-45c1c0db1f2e?auto=format&fit=crop&w=800&q=60',
        price: 59,
      ),
      ProductModel(
        id: 'dairy-005',
        category: ProductCategory.dairy,
        name: 'Cheese Slices (10)',
        imageUrl:
            'https://images.unsplash.com/photo-1612538505081-2d6e49bd51a2?auto=format&fit=crop&w=800&q=60',
        price: 139,
        originalPrice: 159,
        discountTag: '12% OFF',
      ),
      ProductModel(
        id: 'dairy-006',
        category: ProductCategory.dairy,
        name: 'Greek Yogurt 400g',
        imageUrl:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?auto=format&fit=crop&w=800&q=60',
        price: 119,
      ),
      ProductModel(
        id: 'dairy-007',
        category: ProductCategory.dairy,
        name: 'Ghee 500ml',
        imageUrl:
            'https://images.unsplash.com/photo-1604909053197-1b846afc1e4e?auto=format&fit=crop&w=800&q=60',
        price: 329,
        originalPrice: 379,
        discountTag: '13% OFF',
      ),
      ProductModel(
        id: 'dairy-008',
        category: ProductCategory.dairy,
        name: 'Flavored Lassi 200ml',
        imageUrl:
            'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce?auto=format&fit=crop&w=800&q=60',
        price: 35,
      ),
    ],
  };
}
