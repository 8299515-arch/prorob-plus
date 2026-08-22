import 'package:flutter/material.dart';

import '../../../core/auth/auth_session.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  Widget build(BuildContext context) {
    final modules = [
      const _DashboardModule(Icons.construction, 'Проекты', 'Объекты, этапы и прогресс'),
      const _DashboardModule(Icons.task_alt, 'Задачи', 'Дедлайны, чек-листы и контроль'),
      const _DashboardModule(Icons.account_balance_wallet, 'Финансы', 'Сметы, расходы и прибыль'),
      const _DashboardModule(Icons.people_outline, 'CRM и команда', 'Клиенты, бригады и роли'),
      const _DashboardModule(Icons.description_outlined, 'Документы', 'Документы и файлы объектов'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Прораб+'),
        actions: [
          IconButton(
            tooltip: 'Выйти',
            onPressed: () async => authSession.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900 ? 3 : constraints.maxWidth >= 600 ? 2 : 1;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Панель управления', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Всё необходимое для контроля строительных объектов в одном месте.', style: Theme.of(context).textTheme.bodyLarge),
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
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Icon(module.icon, size: 34),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(module.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(module.subtitle),
                                ],
                              ),
                            ),
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

class _DashboardModule {
  const _DashboardModule(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}
