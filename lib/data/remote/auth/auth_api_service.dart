import '../../models/login_email_response_model.dart';
import '../../models/register_response_model.dart';
import '../../models/verify_login_otp_response_model.dart';
import '../network/api_client.dart';
import 'auth_endpoints.dart';

class AuthApiService {
  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<RegisterResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      AuthEndpoints.register,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    return RegisterResponseModel.fromJson(response);
  }

  Future<Map<String, dynamic>> verifyRegister({
    required String email,
    required String otp,
  }) async {
    return _apiClient.post(
      AuthEndpoints.verifyRegister,
      body: {
        'email': email,
        'otp': otp,
      },
    );
  }

  Future<VerifyLoginOtpResponseModel> verifyLoginOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      AuthEndpoints.verifyLoginOtp,
      body: {
        'email': email,
        'otp': otp,
      },
    );

    return VerifyLoginOtpResponseModel.fromJson(response);
  }

  Future<LoginEmailResponseModel> login({
    required String email,
  }) async {
    final response = await _apiClient.post(
      AuthEndpoints.login,
      body: {
        'email': email,
      },
    );

    return LoginEmailResponseModel.fromJson(response);
  }

  Future<Map<String, dynamic>> logout({
    required String token,
  }) {
    return _apiClient.post(
      AuthEndpoints.logout,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Map<String, dynamic>> getProfile({
    required String token,
  }) {
    return _apiClient.get(
      AuthEndpoints.profile,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
