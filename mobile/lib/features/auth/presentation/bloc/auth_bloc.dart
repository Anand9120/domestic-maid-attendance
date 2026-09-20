import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/fcm_service.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_fcm_token_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;
  final RegisterFcmTokenUseCase? registerFcmTokenUseCase;
  final FcmClientService? fcmClientService;

  AuthBloc({
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
    this.registerFcmTokenUseCase,
    this.fcmClientService,
  }) : super(AuthInitial()) {
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  void _onSendOtpRequested(SendOtpRequested event, Emitter<AuthState> emit) {
    emit(AuthLoading());
    // In local dev/testing mode, simulates immediate OTP dispatch
    emit(OtpSentState(event.phoneNumber));
  }

  Future<void> _onVerifyOtpSubmitted(VerifyOtpSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await verifyOtpUseCase.execute(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
        role: event.role,
        fullName: event.fullName,
      );
      emit(AuthAuthenticated(user));

      // Auto-bind device FCM token to authenticated user
      final token = fcmClientService?.fcmToken;
      if (token != null && registerFcmTokenUseCase != null) {
        try {
          await registerFcmTokenUseCase!.execute(userId: user.id, fcmToken: token);
        } catch (_) {
          // Graceful fallback if backend token registration fails
        }
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logoutUseCase.execute();
    emit(AuthUnauthenticated());
  }
}
