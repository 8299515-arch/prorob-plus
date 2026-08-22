import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../domain/document.dart';

abstract interface class DocumentRepository {
  Future<List<ProjectDocument>> getDocuments({String? projectId});
  Future<void> deleteDocument(String id);
}

class ApiDocumentRepository implements DocumentRepository {
  ApiDocumentRepository({DioClient? client}) : _dio = (client ?? DioClient()).dio;
  final Dio _dio;

  @override
  Future<List<ProjectDocument>> getDocuments({String? projectId}) async {
    final response = await _dio.get<List<dynamic>>('/documents', queryParameters: {if (projectId != null) 'project_id': projectId});
    return (response.data ?? const <dynamic>[]).whereType<Map<String, dynamic>>().map(_fromJson).toList(growable: false);
  }

  @override
  Future<void> deleteDocument(String id) async => _dio.delete<void>('/documents/$id');

  ProjectDocument _fromJson(Map<String, dynamic> json) => ProjectDocument(
    id: '${json['id'] ?? ''}', projectId: '${json['project_id'] ?? ''}', name: '${json['name'] ?? ''}', url: '${json['url'] ?? ''}',
    mimeType: json['mime_type'] as String?, sizeBytes: (json['size_bytes'] as num?)?.toInt(), createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
  );
}
