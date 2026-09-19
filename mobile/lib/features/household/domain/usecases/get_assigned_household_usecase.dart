import '../entities/household_entity.dart';
import '../repositories/household_repository.dart';

class GetAssignedHouseholdUseCase {
  final HouseholdRepository repository;

  GetAssignedHouseholdUseCase(this.repository);

  Future<HouseholdEntity?> executeForMaid(int maidId) {
    return repository.getAssignedHouseholdForMaid(maidId);
  }

  Future<List<HouseholdEntity>> executeListForMaid(int maidId) {
    return repository.getAssignedHouseholdsForMaid(maidId);
  }

  Future<HouseholdEntity?> executeForEmployer(int householdId) {
    return repository.getHouseholdById(householdId);
  }
}
