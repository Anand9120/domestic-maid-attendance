import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/features/notifications/domain/entities/notification_entity.dart';
import 'package:maid_attendance/features/notifications/domain/repositories/notification_repository.dart';
import 'package:maid_attendance/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:maid_attendance/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:maid_attendance/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:maid_attendance/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:maid_attendance/features/notifications/presentation/bloc/notification_event.dart';
import 'package:maid_attendance/features/notifications/presentation/bloc/notification_state.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}
class MockGetNotificationsUseCase extends Mock implements GetNotificationsUseCase {}
class MockMarkNotificationReadUseCase extends Mock implements MarkNotificationReadUseCase {}
class MockMarkAllNotificationsReadUseCase extends Mock implements MarkAllNotificationsReadUseCase {}
class FakeNotificationEntity extends Fake implements NotificationEntity {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeNotificationEntity());
  });

  late MockNotificationRepository mockRepository;

  late MockGetNotificationsUseCase mockGetNotificationsUseCase;
  late MockMarkNotificationReadUseCase mockMarkNotificationReadUseCase;
  late MockMarkAllNotificationsReadUseCase mockMarkAllNotificationsReadUseCase;
  late NotificationBloc notificationBloc;

  final sampleNotifications = [
    NotificationEntity(
      id: 1,
      userId: 2,
      householdId: 1,
      title: 'Auto-Switched to Sharma Residence (Flat 402)',
      body: 'Continuous GPS locked proximity to Flat 402.',
      type: NotificationType.autoSwitch,
      isRead: false,
      createdAt: DateTime(2026, 9, 20, 7, 30),
    ),
    NotificationEntity(
      id: 2,
      userId: 2,
      householdId: 1,
      title: 'Arrival Verified: Flat 402',
      body: 'Checked into Flat 402 at 07:35 AM.',
      type: NotificationType.checkIn,
      isRead: true,
      createdAt: DateTime(2026, 9, 20, 7, 35),
    ),
  ];

  setUp(() {
    mockRepository = MockNotificationRepository();
    mockGetNotificationsUseCase = MockGetNotificationsUseCase();
    mockMarkNotificationReadUseCase = MockMarkNotificationReadUseCase();
    mockMarkAllNotificationsReadUseCase = MockMarkAllNotificationsReadUseCase();

    when(() => mockGetNotificationsUseCase.watch(any()))
        .thenAnswer((_) => const Stream.empty());

    notificationBloc = NotificationBloc(
      getNotificationsUseCase: mockGetNotificationsUseCase,
      markNotificationReadUseCase: mockMarkNotificationReadUseCase,
      markAllNotificationsReadUseCase: mockMarkAllNotificationsReadUseCase,
      repository: mockRepository,
    );
  });

  tearDown(() {
    notificationBloc.close();
  });

  group('NotificationBloc Tests', () {
    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoading, NotificationLoaded] when FetchNotificationsEvent succeeds',
      build: () {
        when(() => mockGetNotificationsUseCase.execute(2))
            .thenAnswer((_) async => sampleNotifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(const FetchNotificationsEvent(userId: 2)),
      expect: () => [
        NotificationLoading(),
        NotificationLoaded(
          notifications: sampleNotifications,
          unreadCount: 1,
        ),
      ],
    );

    blocTest<NotificationBloc, NotificationState>(
      'optimistically marks notification as read when MarkNotificationReadEvent is triggered',
      build: () {
        when(() => mockMarkNotificationReadUseCase.execute(1))
            .thenAnswer((_) async => true);
        return notificationBloc;
      },
      seed: () => NotificationLoaded(
        notifications: sampleNotifications,
        unreadCount: 1,
      ),
      act: (bloc) => bloc.add(const MarkNotificationReadEvent(notificationId: 1)),
      expect: () => [
        NotificationLoaded(
          notifications: [
            sampleNotifications[0].copyWith(isRead: true),
            sampleNotifications[1],
          ],
          unreadCount: 0,
        ),
      ],
      verify: (_) {
        verify(() => mockMarkNotificationReadUseCase.execute(1)).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'marks all notifications as read when MarkAllNotificationsReadEvent is triggered',
      build: () {
        when(() => mockMarkAllNotificationsReadUseCase.execute(2))
            .thenAnswer((_) async => true);
        return notificationBloc;
      },
      seed: () => NotificationLoaded(
        notifications: sampleNotifications,
        unreadCount: 1,
      ),
      act: (bloc) => bloc.add(const MarkAllNotificationsReadEvent(userId: 2)),
      expect: () => [
        NotificationLoaded(
          notifications: [
            sampleNotifications[0].copyWith(isRead: true),
            sampleNotifications[1],
          ],
          unreadCount: 0,
        ),
      ],
      verify: (_) {
        verify(() => mockMarkAllNotificationsReadUseCase.execute(2)).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'prepends local notification when AddLocalTimelineEvent is added',
      build: () {
        when(() => mockRepository.saveLocalNotification(any()))
            .thenAnswer((_) async {});
        return notificationBloc;
      },
      seed: () => NotificationLoaded(
        notifications: sampleNotifications,
        unreadCount: 1,
      ),
      act: (bloc) {
        final newEvent = NotificationEntity(
          id: 3,
          userId: 2,
          householdId: 2,
          title: 'Auto-Switched to Verma Residence (Flat 105)',
          body: 'GPS entered geofence boundary.',
          type: NotificationType.autoSwitch,
          isRead: false,
          createdAt: DateTime(2026, 9, 20, 10, 0),
        );
        bloc.add(AddLocalTimelineEvent(notification: newEvent));
      },
      verify: (_) {
        verify(() => mockRepository.saveLocalNotification(any())).called(1);
      },
    );
  });
}
