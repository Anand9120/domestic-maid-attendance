import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationsEvent extends NotificationEvent {
  final int userId;

  const FetchNotificationsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class MarkNotificationReadEvent extends NotificationEvent {
  final int notificationId;

  const MarkNotificationReadEvent({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsReadEvent extends NotificationEvent {
  final int userId;

  const MarkAllNotificationsReadEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AddLocalTimelineEvent extends NotificationEvent {
  final NotificationEntity notification;

  const AddLocalTimelineEvent({required this.notification});

  @override
  List<Object?> get props => [notification];
}

class NotificationsUpdatedEvent extends NotificationEvent {
  final List<NotificationEntity> notifications;

  const NotificationsUpdatedEvent({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}
