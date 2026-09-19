import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline event queueing (PRD US-M02)
  await Hive.initFlutter();

  // Initialize Enterprise Service Locator (Clean Architecture DI)
  await sl.init();

  runApp(
    MaidAttendanceApp(
      authBloc: sl.authBloc,
      attendanceBloc: sl.attendanceBloc,
      notificationBloc: sl.notificationBloc,
    ),
  );
}

