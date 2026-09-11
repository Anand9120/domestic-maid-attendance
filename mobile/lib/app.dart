import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/attendance/presentation/pages/attendance_dashboard_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';

class MaidAttendanceApp extends StatelessWidget {
  final AuthBloc authBloc;
  final AttendanceBloc attendanceBloc;

  const MaidAttendanceApp({
    super.key,
    required this.authBloc,
    required this.attendanceBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<AttendanceBloc>.value(value: attendanceBloc),
      ],
      child: MaterialApp(
        title: 'Maid Attendance Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
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
  }
}
