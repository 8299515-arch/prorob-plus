enum TaskStatus { todo, inProgress, done }

enum TaskPriority { low, normal, high }

class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.status,
    required this.priority,
    this.description,
    this.dueDate,
  });

  final String id;
  final String projectId;
  final String title;
  final TaskStatus status;
  final TaskPriority priority;
  final String? description;
  final DateTime? dueDate;

  Task copyWith({
    String? title,
    TaskStatus? status,
    TaskPriority? priority,
    String? description,
    DateTime? dueDate,
  }) => Task(
        id: id,
        projectId: projectId,
        title: title ?? this.title,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
      );
}
