import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maid_attendance/features/auth/domain/repositories/auth_repository.dart';
import 'package:maid_attendance/features/auth/domain/usecases/register_fcm_token_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late RegisterFcmTokenUseCase useCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterFcmTokenUseCase(mockRepository);
  });

  test('should invoke authRepository.registerFcmToken with correct params', () async {
    when(() => mockRepository.registerFcmToken(
          userId: any(named: 'userId'),
          fcmToken: any(named: 'fcmToken'),
        )).thenAnswer((_) async {});

    await useCase.execute(userId: 1, fcmToken: 'test_device_token_xyz');

    verify(() => mockRepository.registerFcmToken(
          userId: 1,
          fcmToken: 'test_device_token_xyz',
        )).called(1);
  });
}
