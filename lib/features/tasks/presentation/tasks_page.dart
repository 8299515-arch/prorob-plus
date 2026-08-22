import 'package:flutter/material.dart';

import '../../../core/logging/app_logger.dart';
import '../data/task_repository.dart';
import '../domain/task.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({this.projectId, super.key});

  final String? projectId;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TaskRepository _repository = ApiTaskRepository();
  List<Task> _tasks = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _tasks = await _repository.getTasks(projectId: widget.projectId);
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Tasks loading failed',
        error: error,
        stackTrace: stackTrace,
      );
      _error = 'Не удалось загрузить задачи.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final draft = await showDialog<_TaskDraft>(
      context: context,
      builder: (_) => const _TaskDialog(),
    );
    if (draft == null || widget.projectId == null) return;
    try {
      final task = await _repository.createTask(
        projectId: widget.projectId!,
        title: draft.title,
        description: draft.description,
        priority: draft.priority,
        dueDate: draft.dueDate,
      );
      if (mounted) setState(() => _tasks = [..._tasks, task]);
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Task creation failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) _showError('Не удалось создать задачу.');
    }
  }

  Future<void> _changeStatus(Task task, TaskStatus status) async {
    if (status == task.status) return;
    try {
      final updated = await _repository.updateTask(
        task.copyWith(status: status),
      );
      if (mounted) {
        setState(
          () => _tasks = _tasks
              .map((item) => item.id == updated.id ? updated : item)
              .toList(),
        );
      }
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Task status update failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) _showError('Не удалось изменить статус задачи.');
    }
  }

  void _showError(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Задачи')),
        floatingActionButton: widget.projectId == null
            ? null
            : FloatingActionButton.extended(
                onPressed: _create,
                icon: const Icon(Icons.add),
                label: const Text('Добавить'),
              ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 180),
                        Center(child: Text('$_error')),
                        const SizedBox(height: 12),
                        Center(
                          child: FilledButton(
                            onPressed: _load,
                            child: const Text('Повторить'),
                          ),
                        ),
                      ],
                    )
                  : _tasks.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 180),
                            Center(
                              child: Text(
                                widget.projectId == null
                                    ? 'Задач пока нет.'
                                    : 'Для этого объекта задач пока нет.',
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _tasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final task = _tasks[index];
                            return Card(
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.status == TaskStatus.done,
                                  onChanged: (value) => _changeStatus(
                                    task,
                                    value == true
                                        ? TaskStatus.done
                                        : TaskStatus.todo,
                                  ),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.status == TaskStatus.done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text(
                                  '${_priorityTitle(task.priority)}'
                                  '${task.dueDate == null ? '' : ' • до ${_date(task.dueDate!)}'}',
                                ),
                                trailing: DropdownButton<TaskStatus>(
                                  value: task.status,
                                  underline: const SizedBox.shrink(),
                                  items: TaskStatus.values
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(_statusTitle(status)),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (status) {
                                    if (status != null) {
                                      _changeStatus(task, status);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
        ),
      );

  String _statusTitle(TaskStatus status) => switch (status) {
        TaskStatus.todo => 'Новая',
        TaskStatus.inProgress => 'В работе',
        TaskStatus.done => 'Готова',
      };

  String _priorityTitle(TaskPriority priority) => switch (priority) {
        TaskPriority.low => 'Низкий приоритет',
        TaskPriority.normal => 'Обычный приоритет',
        TaskPriority.high => 'Высокий приоритет',
      };

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
}

class _TaskDraft {
  const _TaskDraft(this.title, this.description, this.priority, this.dueDate);

  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? dueDate;
}

class _TaskDialog extends StatefulWidget {
  const _TaskDialog();

  @override
  State<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<_TaskDialog> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  TaskPriority _priority = TaskPriority.normal;
  DateTime? _dueDate;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _dueDate ?? DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Новая задача'),
        content: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Название'),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Введите название' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskPriority>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Приоритет'),
                  items: TaskPriority.values
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(_priorityTitle(priority)),
                        ),
                      )
                      .toList(),
                  onChanged: (priority) =>
                      setState(() => _priority = priority ?? _priority),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(
                    _dueDate == null
                        ? 'Без срока'
                        : 'Срок: ${_date(_dueDate!)}',
                  ),
                  trailing: IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (_key.currentState!.validate()) {
                Navigator.pop(
                  context,
                  _TaskDraft(
                    _title.text.trim(),
                    _description.text.trim(),
                    _priority,
                    _dueDate,
                  ),
                );
              }
            },
            child: const Text('Создать'),
          ),
        ],
      );

  String _priorityTitle(TaskPriority priority) => switch (priority) {
        TaskPriority.low => 'Низкий',
        TaskPriority.normal => 'Обычный',
        TaskPriority.high => 'Высокий',
      };

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';
}
