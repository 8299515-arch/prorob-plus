import 'package:flutter/material.dart';

import '../../../core/logging/app_logger.dart';
import '../data/contact_repository.dart';
import '../domain/contact.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final ContactRepository _repository = ApiContactRepository();
  List<Contact> _contacts = const [];
  bool _loading = true;
  String? _error;
  ContactType? _filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _contacts = await _repository.getContacts(type: _filter);
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Contacts loading failed',
        error: error,
        stackTrace: stackTrace,
      );
      _error = 'Не удалось загрузить контакты.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final draft = await showDialog<_ContactDraft>(
      context: context,
      builder: (_) => const _ContactDialog(),
    );
    if (draft == null) return;
    try {
      final contact = await _repository.createContact(
        name: draft.name,
        type: draft.type,
        phone: draft.phone,
        email: draft.email,
        company: draft.company,
        notes: draft.notes,
      );
      if (mounted) setState(() => _contacts = [..._contacts, contact]);
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Contact creation failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) _message('Не удалось создать контакт.');
    }
  }

  Future<void> _delete(Contact contact) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить контакт?'),
        content: Text(contact.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repository.deleteContact(contact.id);
      if (mounted) {
        setState(
          () => _contacts =
              _contacts.where((item) => item.id != contact.id).toList(),
        );
      }
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Contact deletion failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) _message('Не удалось удалить контакт.');
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('CRM и команда'),
          actions: [
            PopupMenuButton<ContactType?>(
              initialValue: _filter,
              onSelected: (value) {
                setState(() => _filter = value);
                _load();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: null, child: Text('Все')),
                PopupMenuItem(
                  value: ContactType.client,
                  child: Text('Клиенты'),
                ),
                PopupMenuItem(
                  value: ContactType.contractor,
                  child: Text('Подрядчики'),
                ),
                PopupMenuItem(
                  value: ContactType.employee,
                  child: Text('Сотрудники'),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _create,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Добавить'),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? ListView(
                      children: [
                        const SizedBox(height: 180),
                        Center(child: Text('$_error')),
                        Center(
                          child: FilledButton(
                            onPressed: _load,
                            child: const Text('Повторить'),
                          ),
                        ),
                      ],
                    )
                  : _contacts.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 180),
                            Center(child: Text('Контактов пока нет.')),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _contacts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            final c = _contacts[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Icon(_icon(c.type)),
                                ),
                                title: Text(c.name),
                                subtitle: Text(
                                  [
                                    if (c.company?.isNotEmpty == true)
                                      c.company!,
                                    if (c.phone?.isNotEmpty == true) c.phone!,
                                    if (c.email?.isNotEmpty == true) c.email!,
                                  ].join(' • '),
                                ),
                                trailing: IconButton(
                                  onPressed: () => _delete(c),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      );

  IconData _icon(ContactType type) => switch (type) {
        ContactType.client => Icons.person_outline,
        ContactType.contractor => Icons.handyman_outlined,
        ContactType.employee => Icons.badge_outlined,
      };
}

class _ContactDraft {
  const _ContactDraft(
    this.name,
    this.type,
    this.phone,
    this.email,
    this.company,
    this.notes,
  );

  final String name;
  final ContactType type;
  final String? phone;
  final String? email;
  final String? company;
  final String? notes;
}

class _ContactDialog extends StatefulWidget {
  const _ContactDialog();

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  final _notes = TextEditingController();
  ContactType _type = ContactType.client;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _company.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Новый контакт'),
        content: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Имя'),
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Введите имя' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ContactType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Тип'),
                  items: ContactType.values
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(_title(v)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
                TextFormField(
                  controller: _company,
                  decoration: const InputDecoration(labelText: 'Компания'),
                ),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Телефон'),
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: 'Заметки'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (_key.currentState!.validate()) {
                Navigator.pop(
                  context,
                  _ContactDraft(
                    _name.text.trim(),
                    _type,
                    _phone.text.trim(),
                    _email.text.trim(),
                    _company.text.trim(),
                    _notes.text.trim(),
                  ),
                );
              }
            },
            child: const Text('Создать'),
          ),
        ],
      );

  String _title(ContactType type) => switch (type) {
        ContactType.client => 'Клиент',
        ContactType.contractor => 'Подрядчик',
        ContactType.employee => 'Сотрудник',
      };
}
