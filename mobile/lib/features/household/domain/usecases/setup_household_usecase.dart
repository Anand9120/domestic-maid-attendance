import '../entities/household_entity.dart';
import '../repositories/household_repository.dart';

class SetupHouseholdUseCase {
  final HouseholdRepository repository;

  SetupHouseholdUseCase(this.repository);

  Future<HouseholdEntity> execute(Map<String, dynamic> payload) {
    return repository.setupHousehold(payload);
  }
}
