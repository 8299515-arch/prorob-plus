import 'package:flutter/material.dart';

import '../../../core/logging/app_logger.dart';
import '../data/project_repository.dart';
import '../domain/project.dart';

class ProjectDetailsPage extends StatefulWidget {
  const ProjectDetailsPage({required this.project, super.key});

  final Project project;

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Project _project;
  final ProjectRepository _repository = ApiProjectRepository();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
  }

  Future<void> _edit() async {
    final draft = await showDialog<_ProjectEditDraft>(
      context: context,
      builder: (_) => _ProjectEditDialog(project: _project),
    );
    if (draft == null) return;

    setState(() => _saving = true);
    try {
      final updated = await _repository.updateProject(
        _project.copyWith(
          name: draft.name,
          address: draft.address,
          description: draft.description,
          progress: draft.progress,
          status: draft.status,
        ),
      );
      if (mounted) setState(() => _project = updated);
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Project update failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить изменения.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_project.progress * 100).round();
    return Scaffold(
      appBar: AppBar(
        title: Text(_project.name),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            onPressed: _saving ? null : _edit,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _project.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _project.address,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined),
                      const SizedBox(width: 8),
                      Text(_statusTitle(_project.status)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _project.progress,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$percent%'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_project.description?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Описание',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_project.description!),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusTitle(ProjectStatus status) => switch (status) {
        ProjectStatus.planned => 'Запланирован',
        ProjectStatus.active => 'В работе',
        ProjectStatus.completed => 'Завершён',
        ProjectStatus.archived => 'Архив',
      };
}

class _ProjectEditDraft {
  const _ProjectEditDraft(
    this.name,
    this.address,
    this.description,
    this.progress,
    this.status,
  );

  final String name;
  final String address;
  final String? description;
  final double progress;
  final ProjectStatus status;
}

class _ProjectEditDialog extends StatefulWidget {
  const _ProjectEditDialog({required this.project});

  final Project project;

  @override
  State<_ProjectEditDialog> createState() => _ProjectEditDialogState();
}

class _ProjectEditDialogState extends State<_ProjectEditDialog> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _description;
  late double _progress;
  late ProjectStatus _status;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.project.name);
    _address = TextEditingController(text: widget.project.address);
    _description =
        TextEditingController(text: widget.project.description ?? '');
    _progress = widget.project.progress;
    _status = widget.project.status;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Редактировать объект'),
        content: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Название'),
                  validator: (v) => v?.trim().isEmpty == true
                      ? 'Введите название'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Адрес'),
                  validator: (v) => v?.trim().isEmpty == true
                      ? 'Введите адрес'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProjectStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Статус'),
                  items: ProjectStatus.values
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(_statusTitle(status)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _status = value ?? _status),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Прогресс: ${(_progress * 100).round()}%',
                  ),
                ),
                Slider(
                  value: _progress,
                  onChanged: (value) => setState(() => _progress = value),
                ),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  maxLines: 3,
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
                  _ProjectEditDraft(
                    _name.text.trim(),
                    _address.text.trim(),
                    _description.text.trim(),
                    _progress,
                    _status,
                  ),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      );

  String _statusTitle(ProjectStatus status) => switch (status) {
        ProjectStatus.planned => 'Запланирован',
        ProjectStatus.active => 'В работе',
        ProjectStatus.completed => 'Завершён',
        ProjectStatus.archived => 'Архив',
      };
}
