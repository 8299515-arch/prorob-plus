import 'package:go_router/go_router.dart';
import '../auth/auth_session.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/projects/domain/project.dart';
import '../../features/projects/presentation/project_details_page.dart';
import '../../features/projects/presentation/projects_page.dart';
import '../../features/tasks/presentation/tasks_page.dart';
import '../../features/finance/presentation/finance_page.dart';
import '../../features/crm/presentation/contacts_page.dart';
import '../../features/documents/presentation/documents_page.dart';

class AppRouter {
  AppRouter(this._authSession) {
    _authSession.addListener(_refresh);
    router = GoRouter(initialLocation: '/', refreshListenable: _authSession, redirect: (context, state) {
      if (!_authSession.initialized) return null;
      final login = state.matchedLocation == '/login';
      if (!_authSession.authenticated) return login ? null : '/login';
      return login ? '/' : null;
    }, routes: [
      GoRoute(path: '/login', builder: (_, __) => LoginPage(authSession: _authSession)),
      GoRoute(path: '/', builder: (_, __) => DashboardPage(authSession: _authSession)),
      GoRoute(path: '/projects', builder: (_, __) => const ProjectsPage()),
      GoRoute(path: '/projects/:id', builder: (_, state) { final p = state.extra; return p is Project ? ProjectDetailsPage(project: p) : const ProjectsPage(); }),
      GoRoute(path: '/tasks', builder: (_, __) => const TasksPage()),
      GoRoute(path: '/projects/:id/tasks', builder: (_, state) => TasksPage(projectId: state.pathParameters['id']!)),
      GoRoute(path: '/finance', builder: (_, __) => const FinancePage()),
      GoRoute(path: '/projects/:id/finance', builder: (_, state) => FinancePage(projectId: state.pathParameters['id']!)),
      GoRoute(path: '/crm', builder: (_, __) => const ContactsPage()),
      GoRoute(path: '/documents', builder: (_, __) => const DocumentsPage()),
      GoRoute(path: '/projects/:id/documents', builder: (_, state) => DocumentsPage(projectId: state.pathParameters['id']!)),
    ]);
  }
  final AuthSession _authSession;
  late final GoRouter router;
  void _refresh() => router.refresh();
  void dispose() { _authSession.removeListener(_refresh); router.dispose(); }
}
