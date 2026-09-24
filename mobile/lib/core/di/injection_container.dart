import '../../features/attendance/data/datasources/attendance_local_datasource.dart';
import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/check_in_usecase.dart';
import '../../features/attendance/domain/usecases/check_out_usecase.dart';
import '../../features/attendance/domain/usecases/get_monthly_report_usecase.dart';
import '../../features/attendance/domain/usecases/get_today_attendance_usecase.dart';
import '../../features/attendance/domain/usecases/manual_override_usecase.dart';
import '../../features/attendance/domain/usecases/sync_offline_logs_usecase.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_user_profile_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_fcm_token_usecase.dart';
import '../../features/auth/domain/usecases/update_user_profile_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../services/fcm_service.dart';
import '../../features/household/data/datasources/household_remote_datasource.dart';
import '../../features/household/data/repositories/household_repository_impl.dart';
import '../../features/household/domain/repositories/household_repository.dart';
import '../../features/household/domain/usecases/calibrate_geofence_usecase.dart';
import '../../features/household/domain/usecases/get_assigned_household_usecase.dart';
import '../../features/household/domain/usecases/join_household_by_code_usecase.dart';
import '../../features/household/domain/usecases/setup_household_usecase.dart';
import '../../features/notifications/data/datasources/notification_local_datasource.dart';
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/salary/data/datasources/salary_local_datasource.dart';
import '../../features/salary/data/datasources/salary_remote_datasource.dart';
import '../../features/salary/data/repositories/salary_repository_impl.dart';
import '../../features/salary/domain/repositories/salary_repository.dart';
import '../../features/salary/domain/usecases/calculate_salary_usecase.dart';
import '../../features/salary/domain/usecases/get_salary_settlements_usecase.dart';
import '../../features/salary/domain/usecases/settle_salary_usecase.dart';
import '../../features/salary/presentation/bloc/salary_bloc.dart';
import '../network/network_info.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  static ServiceLocator get instance => _instance;
  ServiceLocator._internal();

  // Core
  late final NetworkClient networkClient;
  late final FcmClientService fcmClientService;

  // Data Sources
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AttendanceLocalDataSource attendanceLocalDataSource;
  late final AttendanceRemoteDataSource attendanceRemoteDataSource;
  late final HouseholdRemoteDataSource householdRemoteDataSource;
  late final NotificationRemoteDataSource notificationRemoteDataSource;
  late final NotificationLocalDataSource notificationLocalDataSource;

  // Repositories
  late final AuthRepository authRepository;
  late final AttendanceRepository attendanceRepository;
  late final HouseholdRepository householdRepository;
  late final NotificationRepository notificationRepository;

  // Auth Use Cases
  late final VerifyOtpUseCase verifyOtpUseCase;
  late final LogoutUseCase logoutUseCase;
  late final RegisterFcmTokenUseCase registerFcmTokenUseCase;
  late final GetUserProfileUseCase getUserProfileUseCase;
  late final UpdateUserProfileUseCase updateUserProfileUseCase;

  // Attendance Use Cases
  late final CheckInUseCase checkInUseCase;
  late final CheckOutUseCase checkOutUseCase;
  late final SyncOfflineLogsUseCase syncOfflineLogsUseCase;
  late final GetMonthlyReportUseCase getMonthlyReportUseCase;
  late final ManualOverrideUseCase manualOverrideUseCase;
  late final GetTodayAttendanceUseCase getTodayAttendanceUseCase;

  // Household Use Cases
  late final GetAssignedHouseholdUseCase getAssignedHouseholdUseCase;
  late final CalibrateGeofenceUseCase calibrateGeofenceUseCase;
  late final JoinHouseholdByCodeUseCase joinHouseholdByCodeUseCase;
  late final SetupHouseholdUseCase setupHouseholdUseCase;

  // Notification Use Cases
  late final GetNotificationsUseCase getNotificationsUseCase;
  late final MarkNotificationReadUseCase markNotificationReadUseCase;
  late final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;

  // Salary Data Sources & Repository
  late final SalaryRemoteDataSource salaryRemoteDataSource;
  late final SalaryLocalDataSource salaryLocalDataSource;
  late final SalaryRepository salaryRepository;

  // Salary Use Cases
  late final CalculateSalaryUseCase calculateSalaryUseCase;
  late final SettleSalaryUseCase settleSalaryUseCase;
  late final GetSalarySettlementsUseCase getSalarySettlementsUseCase;

  // BLoCs
  late final AuthBloc authBloc;
  late final AttendanceBloc attendanceBloc;
  late final NotificationBloc notificationBloc;
  late final SalaryBloc salaryBloc;

  bool _initialized = false;


  Future<void> init() async {
    if (_initialized) return;

    // 1. Core
    networkClient = NetworkClient();
    fcmClientService = FcmClientService();
    await fcmClientService.initialize();

    // 2. Data Sources
    authRemoteDataSource = AuthRemoteDataSourceImpl(networkClient: networkClient);
    attendanceLocalDataSource = AttendanceLocalDataSourceImpl();
    attendanceRemoteDataSource = AttendanceRemoteDataSourceImpl(networkClient: networkClient);
    householdRemoteDataSource = HouseholdRemoteDataSourceImpl(networkClient: networkClient);
    notificationRemoteDataSource = NotificationRemoteDataSourceImpl(networkClient: networkClient);
    notificationLocalDataSource = NotificationLocalDataSourceImpl();
    salaryRemoteDataSource = SalaryRemoteDataSourceImpl(networkClient: networkClient);
    salaryLocalDataSource = SalaryLocalDataSourceImpl();

    // 3. Repositories
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      networkClient: networkClient,
    );
    attendanceRepository = AttendanceRepositoryImpl(
      remoteDataSource: attendanceRemoteDataSource,
      localDataSource: attendanceLocalDataSource,
    );
    householdRepository = HouseholdRepositoryImpl(remoteDataSource: householdRemoteDataSource);
    notificationRepository = NotificationRepositoryImpl(
      remoteDataSource: notificationRemoteDataSource,
      localDataSource: notificationLocalDataSource,
    );
    salaryRepository = SalaryRepositoryImpl(
      remoteDataSource: salaryRemoteDataSource,
      localDataSource: salaryLocalDataSource,
    );

    // 4. Use Cases
    verifyOtpUseCase = VerifyOtpUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    registerFcmTokenUseCase = RegisterFcmTokenUseCase(authRepository);
    getUserProfileUseCase = GetUserProfileUseCase(authRepository);
    updateUserProfileUseCase = UpdateUserProfileUseCase(authRepository);

    checkInUseCase = CheckInUseCase(attendanceRepository);
    checkOutUseCase = CheckOutUseCase(attendanceRepository);
    syncOfflineLogsUseCase = SyncOfflineLogsUseCase(attendanceRepository);
    getMonthlyReportUseCase = GetMonthlyReportUseCase(attendanceRepository);
    manualOverrideUseCase = ManualOverrideUseCase(attendanceRepository);

    getTodayAttendanceUseCase = GetTodayAttendanceUseCase(attendanceRepository);
    getAssignedHouseholdUseCase = GetAssignedHouseholdUseCase(householdRepository);
    calibrateGeofenceUseCase = CalibrateGeofenceUseCase(householdRepository);
    joinHouseholdByCodeUseCase = JoinHouseholdByCodeUseCase(householdRepository);
    setupHouseholdUseCase = SetupHouseholdUseCase(householdRepository);

    getNotificationsUseCase = GetNotificationsUseCase(notificationRepository);
    markNotificationReadUseCase = MarkNotificationReadUseCase(notificationRepository);
    markAllNotificationsReadUseCase = MarkAllNotificationsReadUseCase(notificationRepository);

    calculateSalaryUseCase = CalculateSalaryUseCase(salaryRepository);
    settleSalaryUseCase = SettleSalaryUseCase(salaryRepository);
    getSalarySettlementsUseCase = GetSalarySettlementsUseCase(salaryRepository);

    // 5. BLoCs
    authBloc = AuthBloc(
      verifyOtpUseCase: verifyOtpUseCase,
      logoutUseCase: logoutUseCase,
      registerFcmTokenUseCase: registerFcmTokenUseCase,
      fcmClientService: fcmClientService,
    );

    attendanceBloc = AttendanceBloc(
      checkInUseCase: checkInUseCase,
      checkOutUseCase: checkOutUseCase,
      syncOfflineLogsUseCase: syncOfflineLogsUseCase,
      getMonthlyReportUseCase: getMonthlyReportUseCase,
      manualOverrideUseCase: manualOverrideUseCase,
      repository: attendanceRepository,
    );

    notificationBloc = NotificationBloc(
      getNotificationsUseCase: getNotificationsUseCase,
      markNotificationReadUseCase: markNotificationReadUseCase,
      markAllNotificationsReadUseCase: markAllNotificationsReadUseCase,
      repository: notificationRepository,
    );

    salaryBloc = SalaryBloc(
      calculateSalaryUseCase: calculateSalaryUseCase,
      settleSalaryUseCase: settleSalaryUseCase,
      getSalarySettlementsUseCase: getSalarySettlementsUseCase,
    );

    _initialized = true;

  }
}

// Global accessor
ServiceLocator get sl => ServiceLocator.instance;
