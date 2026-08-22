import 'package:flutter/material.dart';

import '../../../core/logging/app_logger.dart';
import '../data/project_repository.dart';
import '../domain/project.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final ProjectRepository _repository = ApiProjectRepository();
  List<Project> _projects = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _projects = await _repository.getProjects();
    } catch (error, stackTrace) {
      AppLogger.instance.e('Projects loading failed', error: error, stackTrace: stackTrace);
      _error = 'Не удалось загрузить объекты.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final result = await showDialog<_ProjectDraft>(context: context, builder: (_) => const _ProjectDialog());
    if (result == null) return;
    try {
      final project = await _repository.createProject(name: result.name, address: result.address, description: result.description);
      if (mounted) setState(() => _projects = [..._projects, project]);
    } catch (error, stackTrace) {
      AppLogger.instance.e('Project creation failed', error: error, stackTrace: stackTrace);
      if (mounted) _showError('Не удалось создать объект.');
    }
  }

  Future<void> _delete(Project project) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('Удалить объект?'),
      content: Text('«${project.name}» будет удалён.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
      ],
    ));
    if (confirmed != true) return;
    try {
      await _repository.deleteProject(project.id);
      if (mounted) setState(() => _projects = _projects.where((item) => item.id != project.id).toList());
    } catch (error, stackTrace) {
      AppLogger.instance.e('Project deletion failed', error: error, stackTrace: stackTrace);
      if (mounted) _showError('Не удалось удалить объект.');
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Объекты')),
        floatingActionButton: FloatingActionButton.extended(onPressed: _create, icon: const Icon(Icons.add), label: const Text('Добавить')),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(children: [const SizedBox(height: 180), Center(child: Text('$_error')), const SizedBox(height: 12), Center(child: FilledButton(onPressed: _load, child: const Text('Повторить')))])
                  : _projects.isEmpty
                      ? ListView(children: [const SizedBox(height: 180), Center(child: Text('Пока нет строительных объектов.'))])
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _projects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, index) {
                            final project = _projects[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(child: Icon(project.status == ProjectStatus.active ? Icons.construction : Icons.business)),
                                title: Text(project.name),
                                subtitle: Text('${project.address}\nПрогресс: ${(project.progress * 100).round()}%'),
                                isThreeLine: true,
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) { if (value == 'delete') _delete(project); },
                                  itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Удалить'))],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      );
}

class _ProjectDraft {
  const _ProjectDraft(this.name, this.address, this.description);
  final String name;
  final String address;
  final String? description;
}

class _ProjectDialog extends StatefulWidget {
  const _ProjectDialog();
  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() { _name.dispose(); _address.dispose(); _description.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Новый объект'),
        content: Form(
          key: _key,
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Название'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Введите название' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Адрес'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Введите адрес' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'Описание'), maxLines: 3),
          ]),),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(onPressed: () { if (_key.currentState!.validate()) Navigator.pop(context, _ProjectDraft(_name.text.trim(), _address.text.trim(), _description.text.trim())); }, child: const Text('Создать')),
        ],
      );
}
