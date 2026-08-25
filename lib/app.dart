import 'package:flutter/material.dart';

import 'core/auth/auth_session.dart';
import 'core/network/network_banner.dart';
import 'core/network/network_status.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class ProrabApp extends StatefulWidget {
  const ProrabApp({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<ProrabApp> createState() => _ProrabAppState();
}

class _ProrabAppState extends State<ProrabApp> {
  late final AppRouter _router;
  late final NetworkStatus _networkStatus;

  @override
  void initState() {
    super.initState();
    _router = AppRouter(widget.authSession);
    _networkStatus = NetworkStatus();
  }

  @override
  void dispose() {
    _router.dispose();
    _networkStatus.dispose();
    widget.authSession.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Прораб+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router.router,
      builder: (context, child) => NetworkBanner(
        networkStatus: _networkStatus,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
