import 'dart:convert';

/// Wishlist item model persisted locally (Hive) via repository.
///
/// Stored as JSON to keep persistence simple and easily replaceable with an API
/// without changing UI logic.
class WishlistItemModel {
  final String productId;
  final String name;
  final String? imageUrl;
  final double unitPrice;

  const WishlistItemModel({
    required this.productId,
    required this.name,
    required this.unitPrice,
    this.imageUrl,
  });

  WishlistItemModel copyWith({
    String? productId,
    String? name,
    String? imageUrl,
    double? unitPrice,
  }) {
    return WishlistItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'unitPrice': unitPrice,
    };
  }

  static WishlistItemModel fromJson(Map<String, dynamic> json) {
    final rawPrice = json['unitPrice'];

    return WishlistItemModel(
      productId: (json['productId'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      unitPrice: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0,
    );
  }

  static List<WishlistItemModel> decodeList(String raw) {
    if (raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => WishlistItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static String encodeList(List<WishlistItemModel> items) {
    return jsonEncode(items.map((e) => e.toJson()).toList(growable: false));
  }
}
