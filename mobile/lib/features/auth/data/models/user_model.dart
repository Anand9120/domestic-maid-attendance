import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    required super.role,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.maid;
    final roleStr = json['role']?.toString().toUpperCase();
    if (roleStr == 'EMPLOYER') {
      parsedRole = UserRole.employer;
    } else if (roleStr == 'ADMIN') {
      parsedRole = UserRole.admin;
    }

    return UserModel(
      id: (json['userId'] ?? json['id'] ?? 0) as int,
      fullName: (json['fullName'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? '') as String,
      role: parsedRole,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role.name.toUpperCase(),
      'token': token,
    };
  }
}
