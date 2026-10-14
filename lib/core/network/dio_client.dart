import 'package:dio/dio.dart';

import '../logging/app_logger.dart';
import '../storage/token_storage.dart';

class DioClient {
  DioClient({TokenStorage? tokenStorage, String? baseUrl})
      : _tokenStorage = tokenStorage ?? TokenStorage() {
    final configuredBaseUrl = baseUrl ??
        const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.prorab.plus',
        );
    dio = Dio(
      BaseOptions(
        baseUrl: configuredBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: const <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          AppLogger.instance.e(
            'HTTP ${error.response?.statusCode ?? 'network'} '
            '${error.requestOptions.method} ${error.requestOptions.path}',
            error: error.error,
          );
          return handler.next(error);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  late final Dio dio;
}
