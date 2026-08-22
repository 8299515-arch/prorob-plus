import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../domain/task.dart';

abstract interface class TaskRepository {
  Future<List<Task>> getTasks({String? projectId});
  Future<Task> createTask({required String projectId, required String title, String? description, TaskPriority priority = TaskPriority.normal, DateTime? dueDate});
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
}

class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository({DioClient? client}) : _dio = (client ?? DioClient()).dio;
  final Dio _dio;

  @override
  Future<List<Task>> getTasks({String? projectId}) async {
    final response = await _dio.get<List<dynamic>>('/tasks', queryParameters: {if (projectId != null) 'project_id': projectId});
    return (response.data ?? const <dynamic>[]).whereType<Map<String, dynamic>>().map(_fromJson).toList(growable: false);
  }

  @override
  Future<Task> createTask({required String projectId, required String title, String? description, TaskPriority priority = TaskPriority.normal, DateTime? dueDate}) async {
    final response = await _dio.post<Map<String, dynamic>>('/tasks', data: {
      'project_id': projectId,
      'title': title.trim(),
      if (description?.trim().isNotEmpty == true) 'description': description!.trim(),
      'priority': priority.name,
      if (dueDate != null) 'due_date': dueDate.toUtc().toIso8601String(),
    });
    return _fromJson(response.data ?? const {});
  }

  @override
  Future<Task> updateTask(Task task) async {
    final response = await _dio.put<Map<String, dynamic>>('/tasks/${task.id}', data: {
      'title': task.title,
      'description': task.description,
      'status': task.status.name,
      'priority': task.priority.name,
      if (task.dueDate != null) 'due_date': task.dueDate!.toUtc().toIso8601String(),
    });
    return _fromJson(response.data ?? const {});
  }

  @override
  Future<void> deleteTask(String id) async => _dio.delete<void>('/tasks/$id');

  Task _fromJson(Map<String, dynamic> json) {
    final status = TaskStatus.values.firstWhere((item) => item.name == json['status'], orElse: () => TaskStatus.todo);
    final priority = TaskPriority.values.firstWhere((item) => item.name == json['priority'], orElse: () => TaskPriority.normal);
    final dueDate = DateTime.tryParse(json['due_date']?.toString() ?? '');
    return Task(
      id: '${json['id'] ?? ''}',
      projectId: '${json['project_id'] ?? ''}',
      title: '${json['title'] ?? ''}',
      status: status,
      priority: priority,
      description: json['description'] as String?,
      dueDate: dueDate,
    );
  }
}
