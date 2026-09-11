import 'package:equatable/equatable.dart';

class HouseholdEntity extends Equatable {
  final int id;
  final int employerId;
  final String houseName;
  final String? address;
  final double latitude;
  final double longitude;
  final int geofenceRadiusMeters;
  final int dwellTimeMinutes;

  const HouseholdEntity({
    required this.id,
    required this.employerId,
    required this.houseName,
    this.address,
    required this.latitude,
    required this.longitude,
    this.geofenceRadiusMeters = 50,
    this.dwellTimeMinutes = 3,
  });

  @override
  List<Object?> get props => [
        id,
        employerId,
        houseName,
        latitude,
        longitude,
        geofenceRadiusMeters,
        dwellTimeMinutes,
      ];
}
