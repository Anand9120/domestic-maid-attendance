class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Error']);
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache Error']);
  @override
  String toString() => message;
}

class GeofenceException implements Exception {
  final String message;
  GeofenceException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No network connection']);
  @override
  String toString() => message;
}
