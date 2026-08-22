import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/logging/app_logger.dart';
import '../data/document_repository.dart';
import '../domain/document.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({this.projectId, super.key});
  final String? projectId;
  @override State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final DocumentRepository _repository = ApiDocumentRepository();
  List<ProjectDocument> _documents = const [];
  bool _loading = true;
  bool _uploading = false;
  String? _error;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try { _documents = await _repository.getDocuments(projectId: widget.projectId); }
    catch (error, stackTrace) { AppLogger.instance.e('Documents loading failed', error: error, stackTrace: stackTrace); _error = 'Не удалось загрузить документы.'; }
    finally { if (mounted) setState(() => _loading = false); }
  }
  Future<void> _upload() async {
    if (widget.projectId == null || _uploading) return;
    final result = await FilePicker.platform.pickFiles(withData: false);
    final file = result?.files.single;
    if (file == null || file.path == null) return;
    setState(() => _uploading = true);
    try {
      final document = await _repository.uploadDocument(projectId: widget.projectId!, path: file.path!, fileName: file.name);
      if (mounted) setState(() => _documents = [..._documents, document]);
    } catch (error, stackTrace) {
      AppLogger.instance.e('Document upload failed', error: error, stackTrace: stackTrace);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось загрузить документ.')));
    } finally { if (mounted) setState(() => _uploading = false); }
  }
  Future<void> _open(ProjectDocument document) async {
    final uri = Uri.tryParse(document.url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось открыть документ.')));
    }
  }
  Future<void> _delete(ProjectDocument document) async {
    try { await _repository.deleteDocument(document.id); if (mounted) setState(() => _documents = _documents.where((item) => item.id != document.id).toList()); }
    catch (error, stackTrace) { AppLogger.instance.e('Document deletion failed', error: error, stackTrace: stackTrace); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось удалить документ.'))); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Документы'), actions: [if (_uploading) const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))]),
    floatingActionButton: widget.projectId == null ? null : FloatingActionButton.extended(onPressed: _upload, icon: const Icon(Icons.upload_file), label: const Text('Загрузить')),
    body: RefreshIndicator(onRefresh: _load, child: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? ListView(children: [const SizedBox(height: 180), Center(child: Text('$_error')), Center(child: FilledButton(onPressed: _load, child: const Text('Повторить')))]) : _documents.isEmpty ? ListView(children: [const SizedBox(height: 180), Center(child: Text('Документов пока нет.'))]) : ListView.separated(padding: const EdgeInsets.all(16), itemCount: _documents.length, separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (_, index) { final d = _documents[index]; return Card(child: ListTile(onTap: () => _open(d), leading: const Icon(Icons.description_outlined), title: Text(d.name), subtitle: Text(_subtitle(d)), trailing: IconButton(onPressed: () => _delete(d), icon: const Icon(Icons.delete_outline)))); })),
  );
  String _subtitle(ProjectDocument d) { final size = d.sizeBytes == null ? '' : ' • ${_formatSize(d.sizeBytes!)}'; return '${d.mimeType ?? 'Документ'}$size'; }
  String _formatSize(int bytes) { if (bytes < 1024) return '$bytes Б'; if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ'; return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ'; }
}
