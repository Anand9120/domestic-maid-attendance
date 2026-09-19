import 'package:equatable/equatable.dart';

enum NotificationType {
  autoSwitch,
  geofenceEnter,
  geofenceExit,
  checkIn,
  checkOut,
  spoofAlert,
  payout,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get name => toString().split('.').last;

  static NotificationType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'AUTO_SWITCH':
        return NotificationType.autoSwitch;
      case 'GEOFENCE_ENTER':
        return NotificationType.geofenceEnter;
      case 'GEOFENCE_EXIT':
        return NotificationType.geofenceExit;
      case 'CHECK_IN':
        return NotificationType.checkIn;
      case 'CHECK_OUT':
        return NotificationType.checkOut;
      case 'SPOOF_ALERT':
        return NotificationType.spoofAlert;
      case 'PAYOUT':
        return NotificationType.payout;
      case 'SYSTEM':
      default:
        return NotificationType.system;
    }
  }

  String toServerString() {
    switch (this) {
      case NotificationType.autoSwitch:
        return 'AUTO_SWITCH';
      case NotificationType.geofenceEnter:
        return 'GEOFENCE_ENTER';
      case NotificationType.geofenceExit:
        return 'GEOFENCE_EXIT';
      case NotificationType.checkIn:
        return 'CHECK_IN';
      case NotificationType.checkOut:
        return 'CHECK_OUT';
      case NotificationType.spoofAlert:
        return 'SPOOF_ALERT';
      case NotificationType.payout:
        return 'PAYOUT';
      case NotificationType.system:
        return 'SYSTEM';
    }
  }
}

class NotificationEntity extends Equatable {
  final int? id;
  final int userId;
  final int? householdId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    this.id,
    required this.userId,
    this.householdId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    int? id,
    int? userId,
    int? householdId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
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

  @override
  List<Object?> get props => [
        id,
        userId,
        householdId,
        title,
        body,
        type,
        isRead,
        createdAt,
      ];
}
