import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    super.id,
    required super.userId,
    super.householdId,
    required super.title,
    required super.body,
    required super.type,
    super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      userId: (json['userId'] ?? 0) as int,
      householdId: json['householdId'] as int?,
      title: (json['title'] ?? '') as String,
      body: (json['body'] ?? '') as String,
      type: NotificationTypeExtension.fromString((json['type'] ?? 'SYSTEM') as String),
      isRead: (json['isRead'] ?? false) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'householdId': householdId,
      'title': title,
      'body': body,
      'type': type.toServerString(),
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      householdId: entity.householdId,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }

  @override
  NotificationModel copyWith({
    int? id,
    int? userId,
    int? householdId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      householdId: householdId ?? this.householdId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
