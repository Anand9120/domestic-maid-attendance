import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SendOtpRequested extends AuthEvent {
  final String phoneNumber;
  const SendOtpRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpSubmitted extends AuthEvent {
  final String phoneNumber;
  final String otp;
  final UserRole role;
  final String? fullName;

  const VerifyOtpSubmitted({
    required this.phoneNumber,
    required this.otp,
    this.role = UserRole.maid,
    this.fullName,
  });

  @override
  List<Object?> get props => [phoneNumber, otp, role, fullName];
}

class LogoutRequested extends AuthEvent {}
