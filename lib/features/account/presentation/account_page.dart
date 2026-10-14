import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../core/logging/app_logger.dart';
import '../data/account_repository.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({required this.authSession, super.key});

  final AuthSession authSession;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AccountRepository _repository = ApiAccountRepository();
  bool _deleting = false;

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить аккаунт?'),
        content: const Text(
          'Будут удалены учетная запись и связанные с ней данные. '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить аккаунт'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await _repository.deleteAccount();
      await widget.authSession.logout();
      if (mounted) context.go('/login');
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Account deletion failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось удалить аккаунт. Попробуйте ещё раз.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Аккаунт')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const ListTile(
              leading: Icon(Icons.security_outlined),
              title: Text('Безопасность'),
              subtitle: Text(
                'Сессия хранится в защищённом хранилище устройства.',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выйти'),
              onTap: widget.authSession.logout,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: const Text('Удалить аккаунт'),
              subtitle: const Text('Удаление аккаунта и связанных данных'),
              enabled: !_deleting,
              onTap: _deleting ? null : _deleteAccount,
            ),
            if (_deleting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      );
}
