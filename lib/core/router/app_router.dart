import 'package:go_router/go_router.dart';

import '../auth/auth_session.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';

class AppRouter {
  AppRouter(this._authSession) {
    _authSession.addListener(_refresh);
    router = GoRouter(
      initialLocation: '/',
      refreshListenable: _authSession,
      redirect: (context, state) {
        if (!_authSession.initialized) return null;

        final isLogin = state.matchedLocation == '/login';
        if (!_authSession.authenticated) return isLogin ? null : '/login';
        return isLogin ? '/' : null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginPage(authSession: _authSession),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => DashboardPage(authSession: _authSession),
        ),
      ],
    );
  }

  final AuthSession _authSession;
  late final GoRouter router;

  void _refresh() => router.refresh();

  void dispose() {
    _authSession.removeListener(_refresh);
    router.dispose();
  }
}
