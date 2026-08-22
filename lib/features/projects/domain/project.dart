enum ProjectStatus { planned, active, completed, archived }

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.address,
    required this.status,
    required this.progress,
    this.description,
  });

  final String id;
  final String name;
  final String address;
  final ProjectStatus status;
  final double progress;
  final String? description;

  Project copyWith({
    String? name,
    String? address,
    ProjectStatus? status,
    double? progress,
    String? description,
  }) =>
      Project(
        id: id,
        name: name ?? this.name,
        address: address ?? this.address,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        description: description ?? this.description,
      );
}
