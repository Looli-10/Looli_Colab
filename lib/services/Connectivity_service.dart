import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _connectionController.add(_isConnected(results));
    });
  }

  Stream<bool> get connectivityStream => _connectionController.stream;

  Future<bool> checkConnection() async {
    List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
           results.contains(ConnectivityResult.wifi);
  }

  void dispose() {
    _connectionController.close();
  }
}
