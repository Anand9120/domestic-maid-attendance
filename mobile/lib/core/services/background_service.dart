import 'dart:async';

class BackgroundSyncService {
  Timer? _syncTimer;
  final Future<void> Function()? onSyncRequired;

  BackgroundSyncService({this.onSyncRequired});

  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) async {
      await triggerImmediateSync();
    });
  }

  Future<void> triggerImmediateSync() async {
    if (onSyncRequired != null) {
      await onSyncRequired!();
    }
  }

  void stop() {
    _syncTimer?.cancel();
  }
}
