import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
    UserRole role = UserRole.maid,
    String? fullName,
  });

  Future<void> registerFcmToken({
    required int userId,
    required String fcmToken,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient networkClient;

  AuthRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
    UserRole role = UserRole.maid,
    String? fullName,
  }) async {
    try {
      final response = await networkClient.dio.post(
        ApiConstants.verifyOtp,
        data: {
          'phoneNumber': phoneNumber,
          'otp': otp,
          'role': role.name.toUpperCase(),
          'fullName': fullName,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final userModel = UserModel.fromJson(data);
        if (userModel.token != null) {
          networkClient.setAuthToken(userModel.token!);
        }
        return userModel;
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to verify OTP');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(errorMsg.toString());
    }
  }

  @override
  Future<void> registerFcmToken({
    required int userId,
    required String fcmToken,
  }) async {
    try {
      await networkClient.dio.post(
        ApiConstants.registerFcmToken,
        data: {
          'userId': userId,
          'fcmToken': fcmToken,
          'deviceType': 'ANDROID',
        },
      );
    } catch (_) {
      // Non-blocking for offline resilience
    }
  }
}
