class TaskModel {
  final String id;
  final String userId;
  final String? collectionId;
  final String title;
  final String? description;
  final String taskType;
  final String status;
  final int priority;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime? migratedFromDate;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
    required this.id,
    required this.userId,
    this.collectionId,
    required this.title,
    this.description,
    required this.taskType,
    required this.status,
    required this.priority,
    this.dueDate,
    this.completedAt,
    this.migratedFromDate,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      collectionId: json['collection_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      taskType: json['task_type'] as String,
      status: json['status'] as String,
      priority: json['priority'] as int,
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      migratedFromDate: json['migrated_from_date'] != null
          ? DateTime.parse(json['migrated_from_date'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'collection_id': collectionId,
      'title': title,
      'description': description,
      'task_type': taskType,
      'status': status,
      'priority': priority,
      'due_date': dueDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'migrated_from_date': migratedFromDate?.toIso8601String(),
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? collectionId,
    String? title,
    String? description,
    String? taskType,
    String? status,
    int? priority,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? migratedFromDate,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collectionId: collectionId ?? this.collectionId,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      migratedFromDate: migratedFromDate ?? this.migratedFromDate,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get bulletSymbol {
    switch (taskType) {
      case 'task':
        return '•';
      case 'event':
        return 'O';
      case 'note':
        return '–';
      default:
        return '•';
    }
  }

  bool get isCompleted => status == 'completed';
  bool get isOverdue =>
      dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
}
