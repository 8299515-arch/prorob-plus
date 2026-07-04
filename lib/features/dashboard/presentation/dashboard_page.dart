import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Прораб+ Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Добро пожаловать в Прораб+',style: TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
            const SizedBox(height:16),
            Card(child: ListTile(leading: const Icon(Icons.construction),title: const Text('Проекты'),subtitle: const Text('Активные стройки и ремонты'))),
            Card(child: ListTile(leading: const Icon(Icons.attach_money),title: const Text('Финансы'),subtitle: const Text('Сметы и расходы'))),
            Card(child: ListTile(leading: const Icon(Icons.people),title: const Text('Команда'),subtitle: const Text('Бригады и роли'))),
          ],
        ),
      ),
    );
  }
}