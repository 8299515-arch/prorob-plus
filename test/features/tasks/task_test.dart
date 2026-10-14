import 'package:flutter_test/flutter_test.dart';
import 'package:prorab_plus/features/tasks/domain/task.dart';

void main() {
  test('task copyWith changes status without losing identity', () {
    const task = Task(
      id: '1',
      projectId: 'project-1',
      title: 'Подготовить объект',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
    );

    final completed = task.copyWith(status: TaskStatus.done);

    expect(completed.id, '1');
    expect(completed.projectId, 'project-1');
    expect(completed.title, 'Подготовить объект');
    expect(completed.priority, TaskPriority.high);
    expect(completed.status, TaskStatus.done);
  });
}
