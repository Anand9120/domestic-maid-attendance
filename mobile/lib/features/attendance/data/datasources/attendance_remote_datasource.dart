import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/attendance_log_model.dart';
import '../models/monthly_report_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceLogModel> checkIn(Map<String, dynamic> checkInPayload);
  Future<AttendanceLogModel> manualOverride(Map<String, dynamic> overridePayload);
  Future<MonthlyReportModel> getMonthlyReport(int maidId, int year, int month);
  Future<List<AttendanceLogModel>> getDailyLogs(int maidId, String dateIso);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final NetworkClient networkClient;

  AttendanceRemoteDataSourceImpl({required this.networkClient});

  @override
  Future<AttendanceLogModel> checkIn(Map<String, dynamic> checkInPayload) async {
    try {
      final response = await networkClient.dio.post(
        ApiConstants.checkIn,
        data: checkInPayload,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AttendanceLogModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response.data['message'] ?? 'Check-in failed');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(msg.toString());
    }
  }

  @override
  Future<AttendanceLogModel> manualOverride(Map<String, dynamic> overridePayload) async {
    try {
      final response = await networkClient.dio.post(
        ApiConstants.manualOverride,
        data: overridePayload,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AttendanceLogModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response.data['message'] ?? 'Manual override failed');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(msg.toString());
    }
  }

  @override
  Future<MonthlyReportModel> getMonthlyReport(int maidId, int year, int month) async {
    try {
      final response = await networkClient.dio.get(
        ApiConstants.monthlyReport,
        queryParameters: {
          'maidId': maidId,
          'year': year,
          'month': month,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return MonthlyReportModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(response.data['message'] ?? 'Failed to load report');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(msg.toString());
    }
  }

  @override
  Future<List<AttendanceLogModel>> getDailyLogs(int maidId, String dateIso) async {
    try {
      final response = await networkClient.dio.get(
        '${ApiConstants.maidAttendance}/$maidId',
        queryParameters: {'date': dateIso},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = (response.data['data'] as List<dynamic>?) ?? [];
        return list
            .map((e) => AttendanceLogModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Network error';
      throw ServerException(msg.toString());
    }
  }
}
