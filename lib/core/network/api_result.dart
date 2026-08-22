import 'api_failure.dart';

sealed class ApiResult<T> {
  const ApiResult();

  R fold<R>({
    required R Function(T value) success,
    required R Function(ApiFailure failure) failure,
  }) {
    return switch (this) {
      ApiSuccess<T>(value: final value) => success(value),
      ApiError<T>(failure: final error) => failure(error),
    };
  }
}

final class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.value);

  final T value;
}

final class ApiError<T> extends ApiResult<T> {
  const ApiError(this.failure);

  final ApiFailure failure;
}
