import 'package:flutter/foundation.dart';

import '../storage/token_storage.dart';

class AuthSession extends ChangeNotifier {
  AuthSession({TokenStorage? tokenStorage}) : _tokenStorage = tokenStorage ?? TokenStorage();

  final TokenStorage _tokenStorage;
  bool _initialized = false;
  bool _authenticated = false;

  bool get initialized => _initialized;
  bool get authenticated => _authenticated;

  Future<void> initialize() async {
    final token = await _tokenStorage.getToken();
    _authenticated = token != null && token.isNotEmpty;
    _initialized = true;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    if (_authenticated == value) return;
    _authenticated = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    setAuthenticated(false);
  }
}
