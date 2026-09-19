import '../repositories/household_repository.dart';

class JoinHouseholdByCodeUseCase {
  final HouseholdRepository repository;

  JoinHouseholdByCodeUseCase(this.repository);

  Future<bool> execute({
    required int maidId,
    required String inviteCode,
  }) {
    return repository.joinHouseholdByCode(
      maidId: maidId,
      inviteCode: inviteCode,
    );
  }
}
