import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/network/network_info.dart';
import 'features/attendance/data/datasources/attendance_local_datasource.dart';
import 'features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'features/attendance/data/repositories/attendance_repository_impl.dart';
import 'features/attendance/domain/usecases/check_in_usecase.dart';
import 'features/attendance/domain/usecases/get_monthly_report_usecase.dart';
import 'features/attendance/domain/usecases/manual_override_usecase.dart';
import 'features/attendance/domain/usecases/sync_offline_logs_usecase.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/verify_otp_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline event queueing (PRD US-M02)
  await Hive.initFlutter();

  // Core Network
  final networkClient = NetworkClient();

  // Auth Dependencies
  final authRemoteDataSource = AuthRemoteDataSourceImpl(networkClient: networkClient);
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  final verifyOtpUseCase = VerifyOtpUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final authBloc = AuthBloc(
    verifyOtpUseCase: verifyOtpUseCase,
    logoutUseCase: logoutUseCase,
  );

  // Attendance Dependencies
  final attendanceLocalDataSource = AttendanceLocalDataSourceImpl();
  final attendanceRemoteDataSource = AttendanceRemoteDataSourceImpl(networkClient: networkClient);
  final attendanceRepository = AttendanceRepositoryImpl(
    remoteDataSource: attendanceRemoteDataSource,
    localDataSource: attendanceLocalDataSource,
  );

  final checkInUseCase = CheckInUseCase(attendanceRepository);
  final syncOfflineLogsUseCase = SyncOfflineLogsUseCase(attendanceRepository);
  final getMonthlyReportUseCase = GetMonthlyReportUseCase(attendanceRepository);
  final manualOverrideUseCase = ManualOverrideUseCase(attendanceRepository);

  final attendanceBloc = AttendanceBloc(
    checkInUseCase: checkInUseCase,
    syncOfflineLogsUseCase: syncOfflineLogsUseCase,
    getMonthlyReportUseCase: getMonthlyReportUseCase,
    manualOverrideUseCase: manualOverrideUseCase,
    repository: attendanceRepository,
  );

  runApp(
    MaidAttendanceApp(
      authBloc: authBloc,
      attendanceBloc: attendanceBloc,
    ),
  );
}
