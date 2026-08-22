import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthRepository {
  AuthRepository({DioClient? client, TokenStorage? tokenStorage})
      : _client = (client ?? DioClient()).dio,
        _tokenStorage = tokenStorage ?? TokenStorage();

  final Dio _client;
  final TokenStorage _tokenStorage;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, String>{
        'email': email.trim(),
        'password': password,
      },
    );

    final token = _extractToken(response.data);
    if (token == null || token.isEmpty) {
      throw const FormatException('Сервер не вернул токен авторизации.');
    }
    await _tokenStorage.saveToken(token);
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/register',
      data: <String, String>{
        'email': email.trim(),
        'password': password,
      },
    );

    final token = _extractToken(response.data);
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.saveToken(token);
    }
  }

  Future<void> logout() => _tokenStorage.clear();

  Future<bool> isAuthenticated() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  String? _extractToken(Map<String, dynamic>? data) {
    if (data == null) return null;
    final token = data['access_token'] ?? data['token'];
    return token is String ? token : null;
  }
}
