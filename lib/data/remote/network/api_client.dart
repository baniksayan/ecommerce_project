import 'dart:convert';
import 'dart:io';

import '../config/rest_api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _send(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = RestApiConfig.buildUri(
      path,
      queryParameters: queryParameters,
    );

    try {
      final request = await _httpClient
          .openUrl(method, uri)
          .timeout(RestApiConfig.requestTimeout);

      final mergedHeaders = <String, String>{
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
        ...?headers,
      };

      mergedHeaders.forEach(request.headers.set);

      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(RestApiConfig.requestTimeout);
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          message: 'Request failed for $method $path',
          statusCode: response.statusCode,
          responseBody: responseBody,
        );
      }

      if (responseBody.isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw ApiException(
        message: 'Expected object JSON response but got ${decoded.runtimeType}',
        statusCode: response.statusCode,
        responseBody: responseBody,
      );
    } on SocketException catch (error) {
      throw ApiException(message: 'No internet connection: $error');
    } on HandshakeException catch (error) {
      throw ApiException(message: 'SSL error: $error');
    } on FormatException catch (error) {
      throw ApiException(message: 'Invalid JSON response: $error');
    } on ApiException {
      rethrow;
    } catch (error) {
      throw ApiException(message: 'Unexpected API error: $error');
    }
  }
}
