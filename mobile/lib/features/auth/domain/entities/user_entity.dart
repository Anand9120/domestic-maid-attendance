import 'package:equatable/equatable.dart';

enum UserRole {
  employer,
  maid,
  admin,
}

class UserEntity extends Equatable {
  final int id;
  final String fullName;
  final String phoneNumber;
  final UserRole role;
  final String? token;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    this.token,
  });

  @override
  List<Object?> get props => [id, fullName, phoneNumber, role, token];
}
