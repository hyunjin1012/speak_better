import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

/// Service to check network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  List<ConnectivityResult> _currentStatus = [ConnectivityResult.none];

  ConnectivityService() {
    _init();
  }

  Future<void> _init() async {
    _currentStatus = await _connectivity.checkConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _currentStatus = results;
    });
  }

  /// Check if device is currently online
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// Get current connectivity status
  List<ConnectivityResult> get currentStatus => _currentStatus;

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  void dispose() {
    _subscription?.cancel();
  }
}
