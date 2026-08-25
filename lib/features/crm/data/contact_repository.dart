import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../domain/contact.dart';

abstract interface class ContactRepository {
  Future<List<Contact>> getContacts({ContactType? type});
  Future<Contact> createContact({
    required String name,
    required ContactType type,
    String? phone,
    String? email,
    String? company,
    String? notes,
  });
  Future<void> deleteContact(String id);
}

class ApiContactRepository implements ContactRepository {
  ApiContactRepository({DioClient? client})
      : _dio = (client ?? DioClient()).dio;

  final Dio _dio;

  @override
  Future<List<Contact>> getContacts({ContactType? type}) async {
    final response = await _dio.get<List<dynamic>>(
      '/contacts',
      queryParameters: {if (type != null) 'type': type.name},
    );
    return (response.data ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(_fromJson)
        .toList(growable: false);
  }

  @override
  Future<Contact> createContact({
    required String name,
    required ContactType type,
    String? phone,
    String? email,
    String? company,
    String? notes,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/contacts',
      data: {
        'name': name.trim(),
        'type': type.name,
        if (phone?.trim().isNotEmpty == true) 'phone': phone!.trim(),
        if (email?.trim().isNotEmpty == true) 'email': email!.trim(),
        if (company?.trim().isNotEmpty == true) 'company': company!.trim(),
        if (notes?.trim().isNotEmpty == true) 'notes': notes!.trim(),
      },
    );
    return _fromJson(response.data ?? const {});
  }

  @override
  Future<void> deleteContact(String id) async =>
      _dio.delete<void>('/contacts/$id');

  Contact _fromJson(Map<String, dynamic> json) => Contact(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        type: ContactType.values.firstWhere(
          (value) => value.name == json['type'],
          orElse: () => ContactType.client,
        ),
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        company: json['company'] as String?,
        notes: json['notes'] as String?,
      );
}
