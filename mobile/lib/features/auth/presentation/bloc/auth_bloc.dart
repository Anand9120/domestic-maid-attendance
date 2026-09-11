import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;

  AuthBloc({
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
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
