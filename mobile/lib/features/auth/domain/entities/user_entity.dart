import 'package:equatable/equatable.dart';

enum UserRole {
  employer,
  maid,
  admin,
}

extension UserRoleExtension on UserRole {
  String get name => toString().split('.').last;
}

class UserEntity extends Equatable {
  final int id;
  final String fullName;
  final String phoneNumber;
  final UserRole role;
  final String? token;
  final String? upiId;
  final String? emergencyContact;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.token,
    this.upiId,
    this.emergencyContact,
  });

  @override
  List<Object?> get props => [id, fullName, phoneNumber, role, token, upiId, emergencyContact];
}
