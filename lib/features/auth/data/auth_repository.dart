import '../../../core/network/dio_client.dart';

class AuthRepository {
  final _client = DioClient().dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
      },
    );

    return response.data;
  }
}