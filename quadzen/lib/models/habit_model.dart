class HabitModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String frequency;
  final int targetCount;
  final String colorHex;
  final String iconName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.frequency,
    required this.targetCount,
    required this.colorHex,
    required this.iconName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      frequency: json['frequency'] as String,
      targetCount: json['target_count'] as int,
      colorHex: json['color_hex'] as String,
      iconName: json['icon_name'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'frequency': frequency,
      'target_count': targetCount,
      'color_hex': colorHex,
      'icon_name': iconName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  HabitModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? frequency,
    int? targetCount,
    String? colorHex,
    String? iconName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      targetCount: targetCount ?? this.targetCount,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
