import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

abstract interface class AccountRepository {
  Future<void> deleteAccount();
}

class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository({DioClient? client}) : _dio = (client ?? DioClient()).dio;
  final Dio _dio;

  @override
  Future<void> deleteAccount() async {
    await _dio.delete<void>('/account');
  }
}
