import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/cart_add_model.dart';
import '../models/cart_clear_model.dart';
import '../models/cart_detail_model.dart';
import '../models/cart_list_model.dart';
import '../models/cart_remove_model.dart';
import '../models/categories_model.dart';
import '../models/product_details_model.dart';
import '../models/product_list_model.dart';
import '../models/wishlist_add_model.dart';
import '../models/wishlist_list_model.dart';
import '../models/wishlist_remove_model.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://api.mandal-variety.com';
  static const Duration _timeout = Duration(seconds: 20);

  Future<Categories> getCategories() async {
    final jsonMap = await _get('categories/list.php');
    return Categories.fromJson(jsonMap);
  }

  Future<Productlist> getProducts() async {
    final jsonMap = await _get('products/list.php');
    return Productlist.fromJson(jsonMap);
  }

  Future<Productdetails> getProductDetails(int productId) async {
    final jsonMap = await _get(
      'products/detail.php',
      queryParameters: <String, String>{
        'id': productId.toString(),
        'product_id': productId.toString(),
      },
    );
    return Productdetails.fromJson(jsonMap);
  }

  Future<Cartlist> getCartList({required int userId}) async {
    final jsonMap = await _get(
      'cart/list.php',
      queryParameters: <String, String>{'user_id': userId.toString()},
    );
    return Cartlist.fromJson(jsonMap);
  }

  Future<Cartdetail> getCartDetail({required int userId}) async {
    final jsonMap = await _get(
      'cart/detail.php',
      queryParameters: <String, String>{'user_id': userId.toString()},
    );
    return Cartdetail.fromJson(jsonMap);
  }

  Future<Cartadd> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    final jsonMap = await _post(
      'cart/add.php',
      body: <String, dynamic>{
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      },
    );
    return Cartadd.fromJson(jsonMap);
  }

  Future<Cartremove> removeFromCart({
    required int userId,
    int? productId,
    String? cartItemId,
  }) async {
    final body = <String, dynamic>{'user_id': userId};
    if (productId != null) {
      body['product_id'] = productId;
    }
    if (cartItemId?.trim().isNotEmpty ?? false) {
      body['cart_item_id'] = cartItemId;
    }

    final jsonMap = await _post('cart/remove.php', body: body);
    return Cartremove.fromJson(jsonMap);
  }

  Future<Cartclear> clearCart({required int userId}) async {
    final jsonMap = await _post(
      'cart/clear.php',
      body: <String, dynamic>{'user_id': userId},
    );
    return Cartclear.fromJson(jsonMap);
  }

  Future<Wishlistlist> getWishlist({required int userId}) async {
    final jsonMap = await _get(
      'wishlist/list.php',
      queryParameters: <String, String>{'user_id': userId.toString()},
    );
    return Wishlistlist.fromJson(jsonMap);
  }

  Future<Wishlistadd> addToWishlist({
    required int userId,
    required int productId,
  }) async {
    final jsonMap = await _post(
      'wishlist/add.php',
      body: <String, dynamic>{'user_id': userId, 'product_id': productId},
    );
    return Wishlistadd.fromJson(jsonMap);
  }

  Future<WishlistRemove> removeFromWishlist({
    required int userId,
    required int productId,
  }) async {
    final jsonMap = await _post(
      'wishlist/remove.php',
      body: <String, dynamic>{'user_id': userId, 'product_id': productId},
    );
    return WishlistRemove.fromJson(jsonMap);
  }

  String resolveImageUrl(String? imagePath) {
    final raw = (imagePath ?? '').trim();
    if (raw.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme) {
      return raw;
    }

    if (raw.startsWith('/')) {
      return '$_baseUrl$raw';
    }

    return '$_baseUrl/$raw';
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$path',
    ).replace(queryParameters: queryParameters);

    try {
      final response = await _client
          .get(
            uri,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiServiceException(
          'Server error (${response.statusCode}). Please try again.',
        );
      }

      if (response.body.trim().isEmpty) {
        throw const ApiServiceException('Server returned empty response.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiServiceException('Invalid response format from server.');
      }

      return decoded;
    } on TimeoutException {
      throw const ApiServiceException('Request timed out. Please retry.');
    } on SocketException {
      throw const ApiServiceException(
        'No internet connection. Please check network and retry.',
      );
    } on FormatException {
      throw const ApiServiceException('Invalid JSON received from server.');
    } on ApiServiceException {
      rethrow;
    } catch (_) {
      throw const ApiServiceException('Unexpected error. Please try again.');
    }
  }

  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$path',
    ).replace(queryParameters: queryParameters);

    try {
      final response = await _client
          .post(
            uri,
            headers: const <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiServiceException(
          'Server error (${response.statusCode}). Please try again.',
        );
      }

      if (response.body.trim().isEmpty) {
        throw const ApiServiceException('Server returned empty response.');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const ApiServiceException('Invalid response format from server.');
      }

      return decoded;
    } on TimeoutException {
      throw const ApiServiceException('Request timed out. Please retry.');
    } on SocketException {
      throw const ApiServiceException(
        'No internet connection. Please check network and retry.',
      );
    } on FormatException {
      throw const ApiServiceException('Invalid JSON received from server.');
    } on ApiServiceException {
      rethrow;
    } catch (_) {
      throw const ApiServiceException('Unexpected error. Please try again.');
    }
  }
}

class ApiServiceException implements Exception {
  const ApiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
