import 'package:flutter/material.dart';

import 'app.dart';
import 'core/auth/auth_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authSession = AuthSession();
  await authSession.initialize();

  runApp(ProrabApp(authSession: authSession));
}
