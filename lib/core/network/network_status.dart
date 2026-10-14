import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkStatus {
  NetworkStatus({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<bool> get changes => _controller.stream;

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<void> start() async {
    if (_subscription != null) return;
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(!results.contains(ConnectivityResult.none));
    });
    _controller.add(await isOnline);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
