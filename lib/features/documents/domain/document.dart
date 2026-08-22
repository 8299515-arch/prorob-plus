class ProjectDocument {
  const ProjectDocument({required this.id, required this.projectId, required this.name, required this.url, this.mimeType, this.sizeBytes, this.createdAt});
  final String id;
  final String projectId;
  final String name;
  final String url;
  final String? mimeType;
  final int? sizeBytes;
  final DateTime? createdAt;
}
