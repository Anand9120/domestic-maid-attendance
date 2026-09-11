import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Event saved to offline queue.']);
}

class GeofenceFailure extends Failure {
  const GeofenceFailure(super.message);
}

class DwellTimeFailure extends Failure {
  const DwellTimeFailure([super.message = 'Pass-by detected: Maid must stay inside boundary for at least 3 minutes.']);
}

class MockLocationFailure extends Failure {
  const MockLocationFailure([super.message = 'Fake GPS / Mock location detected. Event flagged.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Offline storage error occurred.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}
