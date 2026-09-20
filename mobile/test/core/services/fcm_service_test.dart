import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/core/services/fcm_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FcmClientService fcmService;

  setUp(() {
    fcmService = FcmClientService();
  });

  group('FcmClientService Tests', () {
    test('initialize runs safely in headless simulation mode without throwing', () async {
      await expectLater(fcmService.initialize(), completes);
      expect(fcmService.fcmToken, isNotNull);
      expect(fcmService.fcmToken!.isNotEmpty, isTrue);
    });

    test('simulatePushNotification dispatches payload through messageStream', () async {
      final emittedMessages = <Map<String, dynamic>>[];
      final sub = fcmService.messageStream.listen(emittedMessages.add);

      fcmService.simulatePushNotification(
        title: 'Maid Arrived: Sunita Devi',
        body: 'Sunita Devi checked into Sharma Residence at 07:30 AM',
        data: {
          'type': 'CHECK_IN',
          'maidId': '2',
          'householdId': '1',
          'status': 'PRESENT',
        },
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(emittedMessages.length, 1);
      expect(emittedMessages.first['title'], 'Maid Arrived: Sunita Devi');
      expect(emittedMessages.first['data']['type'], 'CHECK_IN');

      await sub.cancel();
    });

    test('onMessageReceived listener receives push payloads correctly', () async {
      Map<String, dynamic>? received;
      fcmService.onMessageReceived((msg) {
        received = msg;
      });

      fcmService.simulatePushNotification(
        title: 'Salary Settled: ₹5000',
        body: '₹5000 paid via UPI',
        data: {
          'type': 'PAYOUT',
          'settlementId': '99',
          'amount': '5000.00',
        },
      );

      await Future.delayed(const Duration(milliseconds: 50));
      expect(received, isNotNull);
      expect(received!['title'], 'Salary Settled: ₹5000');
      expect(received!['data']['settlementId'], '99');
    });
  });
}
