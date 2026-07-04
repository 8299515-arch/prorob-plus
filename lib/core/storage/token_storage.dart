import 'package:hive/hive.dart';

class TokenStorage {
  static const _boxName = 'auth_box';
  static const _key = 'token';

  Future<Box> _box() async => await Hive.openBox(_boxName);

  Future<void> saveToken(String token) async {
    final box = await _box();
    await box.put(_key, token);
  }

  Future<String?> getToken() async {
    final box = await _box();
    return box.get(_key);
  }

  Future<void> clear() async {
    final box = await _box();
    await box.delete(_key);
  }
}