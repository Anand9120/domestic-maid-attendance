import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/ux4g/ux4g.dart';
import 'core/accessibility/accessibility_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/attendance/presentation/pages/attendance_dashboard_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

class MaidAttendanceApp extends StatelessWidget {
  final AuthBloc authBloc;
  final AttendanceBloc attendanceBloc;
  final NotificationBloc notificationBloc;

  const MaidAttendanceApp({
    super.key,
    required this.authBloc,
    required this.attendanceBloc,
    required this.notificationBloc,
  });

  @override
  Widget build(BuildContext context) {
    final a11y = AccessibilityController.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AttendanceBloc>.value(value: attendanceBloc),
        BlocProvider<NotificationBloc>.value(value: notificationBloc),
      ],
      child: ListenableBuilder(

        listenable: a11y,
        builder: (context, _) {
          return Ux4gTheme(
            isDark: a11y.isHighContrast,
            child: MaterialApp(
              title: 'Sahayika (सहायिका) - Domestic Attendance',
              debugShowCheckedModeBanner: false,
              theme: a11y.isHighContrast ? AppTheme.highContrastTheme : AppTheme.lightTheme,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(a11y.textScaleFactor),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return AttendanceDashboardPage(user: state.user);
                  }
                  return const LoginPage();
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
