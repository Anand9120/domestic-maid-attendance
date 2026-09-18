import 'package:flutter_test/flutter_test.dart';
import 'package:maid_attendance/features/household/data/models/household_model.dart';

void main() {
  group('HouseholdModel Serialization Tests', () {
    test('should correctly parse JSON with inviteCode, monthlySalary, allowedLeaves', () {
      final json = {
        'id': 1,
        'employerId': 1,
        'houseName': 'Sharma Residence - Flat 402',
        'address': 'B-Block, Green Park Heights, New Delhi',
        'latitude': 28.6315,
        'longitude': 77.2167,
        'geofenceRadiusMeters': 50,
        'dwellTimeMinutes': 3,
        'inviteCode': 'SHARMA402',
        'monthlySalary': 5000.0,
        'allowedLeaves': 2,
      };

      final model = HouseholdModel.fromJson(json);

      expect(model.id, 1);
      expect(model.employerId, 1);
      expect(model.houseName, 'Sharma Residence - Flat 402');
      expect(model.inviteCode, 'SHARMA402');
      expect(model.monthlySalary, 5000.0);
      expect(model.allowedLeaves, 2);
      expect(model.geofenceRadiusMeters, 50);
      expect(model.dwellTimeMinutes, 3);
    });

    test('toJson should preserve inviteCode, monthlySalary, allowedLeaves', () {
      const model = HouseholdModel(
        id: 1,
        employerId: 1,
        houseName: 'Sharma Residence - Flat 402',
        latitude: 28.6315,
        longitude: 77.2167,
        geofenceRadiusMeters: 50,
        dwellTimeMinutes: 3,
        inviteCode: 'SHARMA402',
        monthlySalary: 5000.0,
        allowedLeaves: 2,
      );

      final json = model.toJson();

      expect(json['inviteCode'], 'SHARMA402');
      expect(json['monthlySalary'], 5000.0);
      expect(json['allowedLeaves'], 2);
      expect(json['houseName'], 'Sharma Residence - Flat 402');
    });
  });
}
