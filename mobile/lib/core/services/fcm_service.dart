import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler required by Firebase Messaging.
/// Executed in an isolated Dart background VM when message is received while app is terminated or in background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Graceful fallback if background initialization isn't needed
  }
  debugPrint('[FCM BACKGROUND] Message received: ${message.messageId} | Data: ${message.data}');
}

/// Enterprise Firebase Cloud Messaging (FCM) Client Service
/// Handles token generation, foreground heads-up notifications, background handlers, and tap navigation.
class FcmClientService {
  static final FcmClientService _instance = FcmClientService._internal();
  factory FcmClientService() => _instance;
  FcmClientService._internal();

  String? _cachedFcmToken;
  bool _isFirebaseInitialized = false;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
    'maid_attendance_channel',
    'Maid Attendance Notifications',
    description: 'Real-time alerts for attendance check-ins, auto-geofence switches, and UPI salary settlements.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _notificationOpenedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _tokenRefreshController =
      StreamController<String>.broadcast();

  String? get fcmToken => _cachedFcmToken;
  bool get isFirebaseInitialized => _isFirebaseInitialized;
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get notificationOpenedStream => _notificationOpenedController.stream;
  Stream<String> get tokenRefreshStream => _tokenRefreshController.stream;

  /// Initializes Firebase Core, Firebase Messaging, and Flutter Local Notifications.
  /// Seamlessly falls back to simulation mode in headless test/desktop environments.
  Future<void> initialize() async {
    try {
      // 1. Initialize Firebase Core
      await Firebase.initializeApp();
      _isFirebaseInitialized = true;
      debugPrint('[FCM CLIENT] Firebase initialized successfully.');

      // 2. Set Background Message Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Setup Android Heads-Up Notification Channel & Local Notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings =
          InitializationSettings(android: androidSettings);

      await _localNotificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[FCM LOCAL] Notification tapped: ${response.payload}');
          if (response.payload != null && response.payload!.isNotEmpty) {
            _notificationOpenedController.add({'payload': response.payload});
          }
        },
      );

      final androidPlugin = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_defaultChannel);
      }

      // 4. Request Notifications Permission (Android 13+ / iOS)
      final messaging = FirebaseMessaging.instance;
      final NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('[FCM CLIENT] Notification permission status: ${settings.authorizationStatus}');

      // 5. Fetch Initial FCM Token
      try {
        _cachedFcmToken = await messaging.getToken();
        debugPrint('[FCM CLIENT] Device FCM Token: $_cachedFcmToken');
      } catch (tokenErr) {
        debugPrint('[FCM CLIENT] Token fetch warning: $tokenErr');
        _cachedFcmToken ??= 'fcm_token_dev_${DateTime.now().millisecondsSinceEpoch}';
      }

      // 6. Listen for Token Refresh
      messaging.onTokenRefresh.listen((String newToken) {
        debugPrint('[FCM CLIENT] FCM Token refreshed: $newToken');
        _cachedFcmToken = newToken;
        _tokenRefreshController.add(newToken);
      });

      // 7. Foreground Message Handler (Displays heads-up popup banner)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('[FCM FOREGROUND] Push received: ${message.notification?.title} - ${message.notification?.body}');
        
        final notification = message.notification;
        final android = message.notification?.android;

        if (notification != null && android != null && !kIsWeb) {
          _localNotificationsPlugin.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _defaultChannel.id,
                _defaultChannel.name,
                channelDescription: _defaultChannel.description,
                icon: android.smallIcon ?? '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
              ),
            ),
            payload: message.data.toString(),
          );
        }

        final msgMap = <String, dynamic>{
          'title': notification?.title ?? '',
          'body': notification?.body ?? '',
          'data': message.data,
        };
        _messageController.add(msgMap);
      });

      // 8. Notification Tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('[FCM TAP] App opened from notification: ${message.data}');
        _notificationOpenedController.add(message.data);
      });

      // 9. Notification Tap when app was killed/terminated
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('[FCM LAUNCH] App launched from killed state via notification: ${initialMessage.data}');
        _notificationOpenedController.add(initialMessage.data);
      }

    } catch (e) {
      // Fallback for Unit Test / Desktop / No Play Services environment
      _isFirebaseInitialized = false;
      _cachedFcmToken ??= 'simulated_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[FCM CLIENT] Firebase running in SIMULATION fallback mode ($e). Token: $_cachedFcmToken');
    }
  }

  /// Register custom listener callback for incoming notifications
  void onMessageReceived(Function(Map<String, dynamic> message) callback) {
    messageStream.listen(callback);
  }

  /// Register custom callback for notification tap actions (deep-links)
  void onNotificationOpened(Function(Map<String, dynamic> data) callback) {
    notificationOpenedStream.listen(callback);
  }

  /// Manually trigger simulated notification (useful for testing & offline sync)
  void simulatePushNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    final msg = {
      'title': title,
      'body': body,
      'data': data ?? {},
    };
    _messageController.add(msg);
  }

  void dispose() {
    _messageController.close();
    _notificationOpenedController.close();
    _tokenRefreshController.close();
  }
}
