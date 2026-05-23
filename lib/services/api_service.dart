import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/auth/auth_coordinator.dart';

import '../models/cart_add_model.dart';
import '../models/cart_clear_model.dart';
import '../models/cart_detail_model.dart';
import '../models/cart_list_model.dart';
import '../models/cart_remove_model.dart';
import '../models/categories_model.dart';
import '../models/manage_policies_model.dart';
import '../models/policy_detail_model.dart';
import '../models/policy_list_model.dart';
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
  static const bool _useBearerAuth = true;

  Future<void> saveAuthToken(String token) async {
    await AuthCoordinator.instance.setUserSession(userId: null, token: token);
  }

  Future<String?> getStoredToken() async {
    return AuthCoordinator.instance.currentUserToken;
  }

  Future<void> clearAuthToken() async {
    await AuthCoordinator.instance.clearToken();
  }

  Future<Map<String, String>> getAuthHeaders() async {
    return _getHeaders(withAuth: true);
  }

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

  Future<ListPolicies> getPolicies() async {
    final jsonMap = await _get('policies/list.php');
    return ListPolicies.fromJson(jsonMap);
  }

  Future<PolicyDetail> getPolicyDetail({required String slug}) async {
    final jsonMap = await _get(
      'policies/detail.php',
      queryParameters: <String, String>{'slug': slug},
    );
    return PolicyDetail.fromJson(jsonMap);
  }

  Future<ManagePolicies> managePolicies({
    required Map<String, dynamic> payload,
    bool withAuth = false,
  }) async {
    final jsonMap = await _post(
      'policies/manage.php',
      body: payload,
      withAuth: withAuth,
    );
    return ManagePolicies.fromJson(jsonMap);
  }

  Future<Cartlist> getCartList({int? userId}) async {
    final resolvedUserId = _resolveUserId(userId);
    final jsonMap = await _get(
      'cart/list.php',
      queryParameters: resolvedUserId == null
          ? null
          : <String, String>{'user_id': resolvedUserId.toString()},
      withAuth: true,
    );
    return Cartlist.fromJson(jsonMap);
  }

  Future<Cartdetail> getCartDetail({int? userId}) async {
    final resolvedUserId = _resolveUserId(userId);
    final jsonMap = await _get(
      'cart/detail.php',
      queryParameters: resolvedUserId == null
          ? null
          : <String, String>{'user_id': resolvedUserId.toString()},
      withAuth: true,
    );
    return Cartdetail.fromJson(jsonMap);
  }

  Future<Cartadd> addToCart({
    int? userId,
    required int productId,
    int quantity = 1,
    String? productName,
  }) async {
    final canonicalProductId = await _resolveCanonicalProductId(
      productId,
      productName: productName,
    );
    final safeQuantity = quantity.clamp(1, 999);
    final resolvedUserId = _resolveUserId(userId);
    _debugLogAddToCart(
      stage: 'request.init',
      payload: <String, dynamic>{
        'attempted_product_id': canonicalProductId,
        'attempted_quantity': safeQuantity,
        'user_id': resolvedUserId,
      },
    );
    final payloads = _buildAddToCartPayloads(
      productId: canonicalProductId,
      quantity: safeQuantity,
      resolvedUserId: resolvedUserId,
    );

    Cartadd primaryResponse;
    try {
      primaryResponse = await _attemptAddToCartWithPayloads(
        jsonBody: payloads.jsonBody,
        formBody: payloads.formBody,
        query: payloads.query,
      );
    } on ApiServiceException catch (e) {
      _debugLogAddToCartFailure(
        stage: 'request.primary.exception',
        message: e.message,
        statusCode: e.statusCode,
        rawBody: e.rawResponseBody,
        debugData: e.debugData,
      );
      rethrow;
    }

    if (!_shouldRetryAddAsForm(
      primaryResponse.message,
      primaryResponse.success,
    )) {
      return primaryResponse;
    }

    final resolvedProductId = await _resolveProductIdByName(productName);
    if (resolvedProductId == null || resolvedProductId == canonicalProductId) {
      return primaryResponse;
    }

    final canonicalPayloads = _buildAddToCartPayloads(
      productId: resolvedProductId,
      quantity: safeQuantity,
      resolvedUserId: resolvedUserId,
    );

    try {
      return await _attemptAddToCartWithPayloads(
        jsonBody: canonicalPayloads.jsonBody,
        formBody: canonicalPayloads.formBody,
        query: canonicalPayloads.query,
      );
    } on ApiServiceException catch (e) {
      _debugLogAddToCartFailure(
        stage: 'request.canonical.exception',
        message: e.message,
        statusCode: e.statusCode,
        rawBody: e.rawResponseBody,
        debugData: e.debugData,
      );
      rethrow;
    }
  }

  Future<int> _resolveCanonicalProductId(
    int productId, {
    String? productName,
  }) async {
    try {
      final details = await getProductDetails(productId);
      final idFromDetails = details.data?.id;
      if (details.success == true && idFromDetails != null) {
        return idFromDetails;
      }
    } catch (_) {
      // Continue with fallback resolution.
    }

    final byName = await _resolveProductIdByName(productName);
    return byName ?? productId;
  }

  Future<Cartadd> _attemptAddToCartWithPayloads({
    required Map<String, dynamic> jsonBody,
    required Map<String, String> formBody,
    required Map<String, String> query,
  }) async {
    try {
      final jsonMap = await _post(
        'cart/add.php',
        body: jsonBody,
        withAuth: true,
      );
      _debugLogAddToCartResponse(
        stage: 'response.json',
        statusCode: 200,
        rawBody: jsonEncode(jsonMap),
        parsedBody: jsonMap,
      );
      final response = Cartadd.fromJson(jsonMap);
      if (!_shouldRetryAddAsForm(response.message, response.success)) {
        return response;
      }

      return _retryAddToCartWithFallbacks(formBody: formBody, query: query);
    } on ApiServiceException catch (e) {
      // Some PHP backends reject JSON body (400) and only accept form data.
      if (e.statusCode != 400) {
        rethrow;
      }

      return _retryAddToCartWithFallbacks(formBody: formBody, query: query);
    }
  }

  ({
    Map<String, dynamic> jsonBody,
    Map<String, String> formBody,
    Map<String, String> query,
  })
  _buildAddToCartPayloads({
    required int productId,
    required int quantity,
    required int? resolvedUserId,
  }) {
    final jsonBody = <String, dynamic>{
      'product_id': productId,
      'id': productId,
      'quantity': quantity,
    };
    final formBody = <String, String>{
      'product_id': productId.toString(),
      'id': productId.toString(),
      'quantity': quantity.toString(),
      'productId': productId.toString(),
      'qty': quantity.toString(),
    };
    final query = <String, String>{
      'product_id': productId.toString(),
      'id': productId.toString(),
      'quantity': quantity.toString(),
      'qty': quantity.toString(),
    };

    if (resolvedUserId != null) {
      jsonBody['user_id'] = resolvedUserId;
      jsonBody['userId'] = resolvedUserId;
      formBody['user_id'] = resolvedUserId.toString();
      formBody['userId'] = resolvedUserId.toString();
      query['user_id'] = resolvedUserId.toString();
      query['userId'] = resolvedUserId.toString();
    }

    return (jsonBody: jsonBody, formBody: formBody, query: query);
  }

  Future<int?> _resolveProductIdByName(String? productName) async {
    final normalized = _normalizeProductName(productName);
    if (normalized.isEmpty) return null;

    try {
      final list = await getProducts();
      final products = list.data ?? const <ProductItemModel>[];

      final exact = products.firstWhere(
        (p) => _normalizeProductName(p.name) == normalized && p.id != null,
        orElse: () => ProductItemModel(),
      );
      if (exact.id != null) {
        return exact.id;
      }

      final partial = products.firstWhere(
        (p) =>
            (_normalizeProductName(p.name).contains(normalized) ||
                normalized.contains(_normalizeProductName(p.name))) &&
            p.id != null,
        orElse: () => ProductItemModel(),
      );
      return partial.id;
    } catch (_) {
      return null;
    }
  }

  Future<Cartadd> _retryAddToCartWithFallbacks({
    required Map<String, String> formBody,
    required Map<String, String> query,
  }) async {
    // Retry-1: Form body with common aliases.
    final formJson = await _postForm(
      'cart/add.php',
      body: formBody,
      withAuth: true,
    );
    _debugLogAddToCartResponse(
      stage: 'response.form',
      statusCode: 200,
      rawBody: jsonEncode(formJson),
      parsedBody: formJson,
    );
    final formResponse = Cartadd.fromJson(formJson);
    if (!_shouldRetryAddAsForm(formResponse.message, formResponse.success)) {
      return formResponse;
    }

    // Retry-2: Query-string payload for backends reading request params only.
    final queryJson = await _post(
      'cart/add.php',
      queryParameters: query,
      body: const <String, dynamic>{},
      withAuth: true,
    );
    _debugLogAddToCartResponse(
      stage: 'response.query_post',
      statusCode: 200,
      rawBody: jsonEncode(queryJson),
      parsedBody: queryJson,
    );
    final queryResponse = Cartadd.fromJson(queryJson);
    if (!_shouldRetryAddAsForm(queryResponse.message, queryResponse.success)) {
      return queryResponse;
    }

    // Retry-3: A few backends accept add endpoint over query GET only.
    final getJson = await _get(
      'cart/add.php',
      queryParameters: query,
      withAuth: true,
    );
    _debugLogAddToCartResponse(
      stage: 'response.query_get',
      statusCode: 200,
      rawBody: jsonEncode(getJson),
      parsedBody: getJson,
    );
    return Cartadd.fromJson(getJson);
  }

  void _debugLogAddToCart({
    required String stage,
    required Map<String, dynamic> payload,
  }) {
    if (!kDebugMode) return;
    debugPrint('[CartDebug][$stage] ${jsonEncode(payload)}');
  }

  void _debugLogAddToCartResponse({
    required String stage,
    required int statusCode,
    required String rawBody,
    required Map<String, dynamic> parsedBody,
  }) {
    if (!kDebugMode) return;
    final debugSection = parsedBody['debug'];
    debugPrint('[CartDebug][$stage] status=$statusCode raw=$rawBody');
    if (debugSection is Map<String, dynamic>) {
      debugPrint('[CartDebug][$stage][debug] ${jsonEncode(debugSection)}');
    }
  }

  void _debugLogAddToCartFailure({
    required String stage,
    required String message,
    int? statusCode,
    String? rawBody,
    Map<String, dynamic>? debugData,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      '[CartDebug][$stage] status=${statusCode ?? 'unknown'} message=$message',
    );
    if ((rawBody ?? '').trim().isNotEmpty) {
      debugPrint('[CartDebug][$stage] raw=${rawBody!.trim()}');
    }
    if (debugData != null && debugData.isNotEmpty) {
      debugPrint('[CartDebug][$stage][debug] ${jsonEncode(debugData)}');
    }
  }

  String _normalizeProductName(String? value) {
    final raw = (value ?? '').toLowerCase().trim();
    if (raw.isEmpty) return '';
    final cleaned = raw.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _shouldRetryAddAsForm(String? message, bool? success) {
    if (success == true) return false;
    final text = (message ?? '').toLowerCase();
    return text.contains('invalid product id') ||
        text.contains('invalid quantity') ||
        text.contains('product id and quantity') ||
        text.contains('invaild product id') ||
        text.contains('invaild quantity');
  }

  Future<Cartremove> removeFromCart({
    int? userId,
    int? productId,
    String? cartItemId,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final body = <String, dynamic>{};
    if (resolvedUserId != null) {
      body['user_id'] = resolvedUserId;
    }
    if (productId != null) {
      body['product_id'] = productId;
    }
    if (cartItemId?.trim().isNotEmpty ?? false) {
      body['cart_item_id'] = cartItemId;
    }

    final jsonMap = await _post('cart/remove.php', body: body, withAuth: true);
    return Cartremove.fromJson(jsonMap);
  }

  Future<Cartclear> clearCart({int? userId}) async {
    final resolvedUserId = _resolveUserId(userId);
    final body = <String, dynamic>{};
    if (resolvedUserId != null) {
      body['user_id'] = resolvedUserId;
    }

    final jsonMap = await _post('cart/clear.php', body: body, withAuth: true);
    return Cartclear.fromJson(jsonMap);
  }

  Future<Wishlistlist> getWishlist({int? userId}) async {
    final resolvedUserId = _resolveUserId(userId);
    final jsonMap = await _get(
      'wishlist/list.php',
      queryParameters: resolvedUserId == null
          ? null
          : <String, String>{'user_id': resolvedUserId.toString()},
      withAuth: true,
    );
    return Wishlistlist.fromJson(jsonMap);
  }

  Future<Wishlistadd> addToWishlist({
    int? userId,
    required int productId,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final body = <String, dynamic>{'product_id': productId};
    if (resolvedUserId != null) {
      body['user_id'] = resolvedUserId;
    }

    final jsonMap = await _post('wishlist/add.php', body: body, withAuth: true);
    return Wishlistadd.fromJson(jsonMap);
  }

  Future<WishlistRemove> removeFromWishlist({
    int? userId,
    required int productId,
  }) async {
    final resolvedUserId = _resolveUserId(userId);
    final body = <String, dynamic>{'product_id': productId};
    if (resolvedUserId != null) {
      body['user_id'] = resolvedUserId;
    }

    final jsonMap = await _post(
      'wishlist/remove.php',
      body: body,
      withAuth: true,
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
    bool withAuth = false,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$path',
    ).replace(queryParameters: queryParameters);

    try {
      final response = await _client
          .get(uri, headers: await _getHeaders(withAuth: withAuth))
          .timeout(_timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleUnauthorized();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final serverDebug = _extractServerDebug(response.body);
        throw ApiServiceException(
          'Server error (${response.statusCode}). Please try again.',
          statusCode: response.statusCode,
          rawResponseBody: response.body,
          debugData: serverDebug,
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
    } on http.ClientException catch (e) {
      final details = e.message.toLowerCase();
      if (details.contains('failed host lookup')) {
        throw const ApiServiceException(
          'DNS lookup failed for api.mandal-variety.com. Check internet, DNS, and base URL host.',
        );
      }
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
    bool withAuth = false,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$path',
    ).replace(queryParameters: queryParameters);

    try {
      final response = await _client
          .post(
            uri,
            headers: await _getHeaders(withAuth: withAuth),
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(_timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleUnauthorized();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final serverMessage = _extractServerErrorMessage(response.body);
        final serverDebug = _extractServerDebug(response.body);
        throw ApiServiceException(
          serverMessage ??
              'Server error (${response.statusCode}). Please try again.',
          statusCode: response.statusCode,
          rawResponseBody: response.body,
          debugData: serverDebug,
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
    } on http.ClientException catch (e) {
      final details = e.message.toLowerCase();
      if (details.contains('failed host lookup')) {
        throw const ApiServiceException(
          'DNS lookup failed for api.mandal-variety.com. Check internet, DNS, and base URL host.',
        );
      }
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

  Future<Map<String, dynamic>> _postForm(
    String path, {
    Map<String, String>? body,
    Map<String, String>? queryParameters,
    bool withAuth = false,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/$path',
    ).replace(queryParameters: queryParameters);

    try {
      final headers = await _getHeaders(withAuth: withAuth);
      headers.remove('Content-Type');

      final response = await _client
          .post(uri, headers: headers, body: body ?? <String, String>{})
          .timeout(_timeout);

      if (response.statusCode == 401 || response.statusCode == 403) {
        await _handleUnauthorized();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final serverMessage = _extractServerErrorMessage(response.body);
        final serverDebug = _extractServerDebug(response.body);
        throw ApiServiceException(
          serverMessage ??
              'Server error (${response.statusCode}). Please try again.',
          statusCode: response.statusCode,
          rawResponseBody: response.body,
          debugData: serverDebug,
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
    } on http.ClientException catch (e) {
      final details = e.message.toLowerCase();
      if (details.contains('failed host lookup')) {
        throw const ApiServiceException(
          'DNS lookup failed for api.mandal-variety.com. Check internet, DNS, and base URL host.',
        );
      }
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

  String? _extractServerErrorMessage(String rawBody) {
    final body = rawBody.trim();
    if (body.isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = (decoded['message'] ?? decoded['error'] ?? '')
            .toString()
            .trim();
        if (message.isNotEmpty) return message;
      }
    } catch (_) {
      // If response is plain text/HTML, do not surface noisy body content.
    }

    return null;
  }

  Map<String, dynamic>? _extractServerDebug(String rawBody) {
    final body = rawBody.trim();
    if (body.isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final debugSection = decoded['debug'];
        if (debugSection is Map<String, dynamic>) {
          return debugSection;
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  int? _resolveUserId(int? userId) {
    return userId ?? AuthCoordinator.instance.currentUserId;
  }

  Future<Map<String, String>> _getHeaders({bool withAuth = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (!withAuth) {
      return headers;
    }

    final token = (await getStoredToken())?.trim();
    if (token == null || token.isEmpty) {
      final hasUserIdSession = AuthCoordinator.instance.currentUserId != null;
      if (!hasUserIdSession) {
        throw const ApiUnauthorizedException('Please login first.');
      }
      return headers;
    }

    headers['Authorization'] = _useBearerAuth ? 'Bearer $token' : token;
    return headers;
  }

  Future<void> _handleUnauthorized() async {
    await clearAuthToken();
    await AuthCoordinator.instance.logout();
    throw const ApiUnauthorizedException(
      'Session expired. Please login again.',
    );
  }
}

class ApiServiceException implements Exception {
  const ApiServiceException(
    this.message, {
    this.statusCode,
    this.rawResponseBody,
    this.debugData,
  });

  final String message;
  final int? statusCode;
  final String? rawResponseBody;
  final Map<String, dynamic>? debugData;

  @override
  String toString() => message;
}

class ApiUnauthorizedException extends ApiServiceException {
  const ApiUnauthorizedException(super.message);
}
