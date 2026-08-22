import 'package:dio/dio.dart';

sealed class ApiFailure implements Exception {
  const ApiFailure(this.message);
  final String message;
}

final class NetworkFailure extends ApiFailure {
  const NetworkFailure([super.message = 'Проверьте подключение к интернету.']);
}

final class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure([super.message = 'Сессия истекла. Войдите снова.']);
}

final class ServerFailure extends ApiFailure {
  const ServerFailure([super.message = 'Сервер временно недоступен. Попробуйте позже.']);
}

final class RequestFailure extends ApiFailure {
  const RequestFailure([super.message = 'Не удалось выполнить запрос.']);
}

ApiFailure mapDioFailure(Object error) {
  if (error is ApiFailure) return error;
  if (error is! DioException) return const RequestFailure();
  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) return const UnauthorizedFailure();
      if (status != null && status >= 500) return const ServerFailure();
      return const RequestFailure();
    case DioExceptionType.badCertificate:
    case DioExceptionType.cancel:
    case DioExceptionType.unknown:
      return const RequestFailure();
  }
}
