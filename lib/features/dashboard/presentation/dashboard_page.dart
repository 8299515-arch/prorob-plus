import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  Widget build(BuildContext context) {
    final modules = [
      const _M(
        Icons.construction,
        'Проекты',
        'Объекты, этапы и прогресс',
        '/projects',
      ),
      const _M(
        Icons.task_alt,
        'Задачи',
        'Дедлайны, чек-листы и контроль',
        '/tasks',
      ),
      const _M(
        Icons.account_balance_wallet,
        'Финансы',
        'Сметы, расходы и прибыль',
        '/finance',
      ),
      const _M(
        Icons.people_outline,
        'CRM и команда',
        'Клиенты, бригады и роли',
        '/crm',
      ),
      const _M(
        Icons.description_outlined,
        'Документы',
        'Документы и файлы объектов',
        '/documents',
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Прораб+'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: authSession.logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final columns = c.maxWidth >= 900
              ? 3
              : c.maxWidth >= 600
                  ? 2
                  : 1;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Панель управления',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Управление строительными объектами в одном месте.',
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: modules.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: columns == 1 ? 3.4 : 1.45,
                ),
                itemBuilder: (context, i) {
                  final m = modules[i];
                  return Card(
                    child: InkWell(
                      onTap: () => context.push(m.route),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Icon(m.icon, size: 34),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(m.subtitle),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _M {
  const _M(this.icon, this.title, this.subtitle, this.route);

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}
