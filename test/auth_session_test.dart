import 'package:flutter_test/flutter_test.dart';
import 'package:prorab_plus/core/auth/auth_session.dart';

void main() {
  test('auth session starts unauthenticated', () {
    final session = AuthSession();
    expect(session.initialized, isFalse);
    expect(session.authenticated, isFalse);
    session.dispose();
  });
}
