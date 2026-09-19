import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;
  final NotificationRepository repository;

  StreamSubscription<List<NotificationEntity>>? _streamSubscription;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllNotificationsReadUseCase,
    required this.repository,
  }) : super(NotificationInitial()) {
    on<FetchNotificationsEvent>(_onFetchNotifications);
    on<MarkNotificationReadEvent>(_onMarkNotificationRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllNotificationsRead);
    on<AddLocalTimelineEvent>(_onAddLocalTimeline);
    on<NotificationsUpdatedEvent>(_onNotificationsUpdated);
  }

  Future<void> _onFetchNotifications(
    FetchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    try {
      final list = await getNotificationsUseCase.execute(event.userId);
      final unreadCount = list.where((n) => !n.isRead).length;

      // Subscribe to real-time local updates
      await _streamSubscription?.cancel();
      _streamSubscription = getNotificationsUseCase.watch(event.userId).listen((updatedList) {
        add(NotificationsUpdatedEvent(notifications: updatedList));
      });

      emit(NotificationLoaded(
        notifications: list,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationFailure(e.toString()));
    }
  }

  Future<void> _onNotificationsUpdated(
    NotificationsUpdatedEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final unreadCount = event.notifications.where((n) => !n.isRead).length;
    emit(NotificationLoaded(
      notifications: event.notifications,
      unreadCount: unreadCount,
    ));
  }

  Future<void> _onMarkNotificationRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      final updated = current.notifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      final unread = updated.where((n) => !n.isRead).length;
      emit(NotificationLoaded(notifications: updated, unreadCount: unread));
    }
    await markNotificationReadUseCase.execute(event.notificationId);
  }

  Future<void> _onMarkAllNotificationsRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      final updated = current.notifications.map((n) => n.copyWith(isRead: true)).toList();
      emit(NotificationLoaded(notifications: updated, unreadCount: 0));
    }
    await markAllNotificationsReadUseCase.execute(event.userId);
  }

  Future<void> _onAddLocalTimeline(
    AddLocalTimelineEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.saveLocalNotification(event.notification);
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      final list = [event.notification, ...current.notifications];
      final unread = list.where((n) => !n.isRead).length;
      emit(NotificationLoaded(notifications: list, unreadCount: unread));
    } else {
      emit(NotificationLoaded(
        notifications: [event.notification],
        unreadCount: event.notification.isRead ? 0 : 1,
      ));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
