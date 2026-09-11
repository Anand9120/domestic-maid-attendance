import '../../domain/entities/household_entity.dart';

class HouseholdModel extends HouseholdEntity {
  const HouseholdModel({
    required super.id,
    required super.employerId,
    required super.houseName,
    super.address,
    required super.latitude,
    required super.longitude,
    super.geofenceRadiusMeters,
    super.dwellTimeMinutes,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) {
    return HouseholdModel(
      id: (json['id'] ?? 0) as int,
      employerId: (json['employerId'] ?? 0) as int,
      houseName: (json['houseName'] ?? 'Home') as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : 0.0,
      geofenceRadiusMeters: (json['geofenceRadiusMeters'] ?? 50) as int,
      dwellTimeMinutes: (json['dwellTimeMinutes'] ?? 3) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employerId': employerId,
      'houseName': houseName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'geofenceRadiusMeters': geofenceRadiusMeters,
      'dwellTimeMinutes': dwellTimeMinutes,
    };
  }
}
