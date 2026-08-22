import 'package:dio/dio.dart';

import '../../../core/network/api_failure.dart';
import '../../../core/network/dio_client.dart';
import '../domain/project.dart';

abstract interface class ProjectRepository {
  Future<List<Project>> getProjects();
  Future<Project> createProject({required String name, required String address, String? description});
  Future<Project> updateProject(Project project);
  Future<void> deleteProject(String id);
}

class ApiProjectRepository implements ProjectRepository {
  ApiProjectRepository({DioClient? client}) : _dio = (client ?? DioClient()).dio;

  final Dio _dio;

  @override
  Future<List<Project>> getProjects() async {
    try {
      final response = await _dio.get<List<dynamic>>('/projects');
      return (response.data ?? const <dynamic>[]).whereType<Map<String, dynamic>>().map(_fromJson).toList(growable: false);
    } catch (error) {
      throw mapDioFailure(error);
    }
  }

  @override
  Future<Project> createProject({required String name, required String address, String? description}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/projects', data: {
        'name': name.trim(),
        'address': address.trim(),
        if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
      });
      return _fromJson(response.data ?? const {});
    } catch (error) {
      throw mapDioFailure(error);
    }
  }

  @override
  Future<Project> updateProject(Project project) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>('/projects/${project.id}', data: _toJson(project));
      return _fromJson(response.data ?? const {});
    } catch (error) {
      throw mapDioFailure(error);
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      await _dio.delete<void>('/projects/$id');
    } catch (error) {
      throw mapDioFailure(error);
    }
  }

  Project _fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'planned';
    final status = ProjectStatus.values.firstWhere((item) => item.name == rawStatus, orElse: () => ProjectStatus.planned);
    final rawProgress = json['progress'];
    final progress = rawProgress is num ? rawProgress.toDouble().clamp(0, 1).toDouble() : 0.0;
    return Project(id: '${json['id'] ?? ''}', name: '${json['name'] ?? ''}', address: '${json['address'] ?? ''}', status: status, progress: progress, description: json['description'] as String?);
  }

  Map<String, dynamic> _toJson(Project project) => {
        'name': project.name,
        'address': project.address,
        'status': project.status.name,
        'progress': project.progress,
        if (project.description != null) 'description': project.description,
      };
}
