import 'package:dio/dio.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/network/dio_client.dart';
import '../domain/finance_entry.dart';

abstract interface class FinanceRepository {
  Future<List<FinanceEntry>> getEntries({String? projectId});

  Future<FinanceEntry> createEntry({
    required String projectId,
    required FinanceEntryType type,
    required String title,
    required double amount,
    String currency = 'UAH',
    String? category,
    DateTime? date,
  });

  Future<void> deleteEntry(String id);
}

class ApiFinanceRepository implements FinanceRepository {
  ApiFinanceRepository({DioClient? client}) : _dio = (client ?? DioClient()).dio;

  final Dio _dio;

  @override
  Future<List<FinanceEntry>> getEntries({String? projectId}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/finance',
        queryParameters: {if (projectId != null) 'project_id': projectId},
      );
      return (response.data ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_fromJson)
          .toList(growable: false);
    } catch (error) {
      throw mapDioFailure(error);
    }
  }

  @override
  Future<FinanceEntry> createEntry({
    required String projectId,
    required FinanceEntryType type,
    required String title,
    required double amount,
    String currency = 'UAH',
    String? category,
    DateTime? date,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/finance',
        data: {
          'project_id': projectId,
          'type': type.name,
          'title': title.trim(),
          'amount': amount,
          'currency': currency,
          if (category?.trim().isNotEmpty == true) 'category': category!.trim(),
          'date': (date ?? DateTime.now()).toUtc().toIso8601String(),
        },
      );
      return _fromJson(response.data ?? const {});
    } catch (error) {
      throw mapDioFailure(error);
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    try {
      await _dio.delete<void>('/finance/$id');
    } catch (error) {
      throw mapDioFailure(error);
    }
  }

  FinanceEntry _fromJson(Map<String, dynamic> json) => FinanceEntry(
        id: '${json['id'] ?? ''}',
        projectId: '${json['project_id'] ?? ''}',
        type: json['type'] == 'income'
            ? FinanceEntryType.income
            : FinanceEntryType.expense,
        title: '${json['title'] ?? ''}',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: '${json['currency'] ?? 'UAH'}',
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        category: json['category'] as String?,
      );
}
