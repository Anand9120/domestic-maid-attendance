import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/features/attendance/presentation/widgets/system_status_sheet.dart';

// Test Adapter to simulate backend health responses without real network
class MockHttpClientAdapter implements HttpClientAdapter {
  final Map<String, dynamic> responseData;
  final int statusCode;

  MockHttpClientAdapter({
    required this.responseData,
    this.statusCode = 200,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    const jsonStr = '{"status":"UP","service":"Domestic Maid Attendance Backend"}';
    return ResponseBody.fromString(
      jsonStr,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets('renders SystemStatusSheet with GIGW 3.0 security standards and credits', (tester) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final dio = Dio();
    dio.httpClientAdapter = MockHttpClientAdapter(responseData: {
      'status': 'UP',
      'service': 'Domestic Maid Attendance Backend',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SystemStatusSheet(dio: dio),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('System Diagnostics & Security'), findsOneWidget);
    expect(find.textContaining('GIGW 3.0 & UX4G Compliant'), findsOneWidget);

    // Verify Security Items
    expect(find.textContaining('Geofence Perimeter'), findsOneWidget);
    expect(find.textContaining('Mock GPS Detection'), findsOneWidget);
    expect(find.textContaining('Dwell-Time Validation'), findsOneWidget);
    expect(find.textContaining('Offline-First Resilience'), findsOneWidget);

    // Verify Helplines
    expect(find.text('112'), findsOneWidget);
    expect(find.text('181'), findsOneWidget);
    expect(find.text('1091'), findsOneWidget);

    // Verify Developer & Location Credits
    expect(find.textContaining('Anand Prakash Jaiswal'), findsOneWidget);
    expect(find.textContaining('Indore, Madhya Pradesh, India'), findsOneWidget);
    expect(find.textContaining('github.com/Anand9120/domestic-maid-attendance'), findsOneWidget);

    // Verify Close button
    expect(find.text('Done (Close)'), findsOneWidget);
  });
}
