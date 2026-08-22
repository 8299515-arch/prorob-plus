import 'package:flutter/material.dart';

import '../../../core/logging/app_logger.dart';
import '../data/finance_repository.dart';
import '../domain/finance_entry.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({this.projectId, super.key});

  final String? projectId;

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  final FinanceRepository _repository = ApiFinanceRepository();
  List<FinanceEntry> _entries = const [];
  bool _loading = true;
  String? _error;

  double get _income => _entries
      .where((e) => e.type == FinanceEntryType.income)
      .fold(0, (s, e) => s + e.amount);

  double get _expense => _entries
      .where((e) => e.type == FinanceEntryType.expense)
      .fold(0, (s, e) => s + e.amount);

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
      _entries = await _repository.getEntries(projectId: widget.projectId);
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Finance loading failed',
        error: error,
        stackTrace: stackTrace,
      );
      _error = 'Не удалось загрузить финансы.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add(FinanceEntryType type) async {
    if (widget.projectId == null) return;
    final draft = await showDialog<_Draft>(
      context: context,
      builder: (_) => _FinanceDialog(type: type),
    );
    if (draft == null) return;
    try {
      final entry = await _repository.createEntry(
        projectId: widget.projectId!,
        type: type,
        title: draft.title,
        amount: draft.amount,
        category: draft.category,
        date: draft.date,
      );
      if (mounted) setState(() => _entries = [..._entries, entry]);
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Finance creation failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) _message('Не удалось сохранить операцию.');
    }
  }

  Future<void> _delete(FinanceEntry entry) async {
    try {
      await _repository.deleteEntry(entry.id);
      if (mounted) {
        setState(
          () => _entries = _entries.where((e) => e.id != entry.id).toList(),
        );
      }
    } catch (error, stackTrace) {
      AppLogger.instance.e(
        'Finance deletion failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) _message('Не удалось удалить операцию.');
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Финансы')),
        floatingActionButton: widget.projectId == null
            ? null
            : PopupMenuButton<FinanceEntryType>(
                onSelected: _add,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: FinanceEntryType.income,
                    child: Text('Добавить доход'),
                  ),
                  PopupMenuItem(
                    value: FinanceEntryType.expense,
                    child: Text('Добавить расход'),
                  ),
                ],
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
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Row(
                          children: [
                            Expanded(child: _Summary('Доходы', _income)),
                            const SizedBox(width: 10),
                            Expanded(child: _Summary('Расходы', _expense)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _Summary('Баланс', _income - _expense),
                        const SizedBox(height: 20),
                        if (_entries.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: Center(
                              child: Text('Финансовых операций пока нет.'),
                            ),
                          )
                        else
                          ..._entries.map(
                            (e) => Card(
                              child: ListTile(
                                title: Text(e.title),
                                subtitle: Text(
                                  '${e.category ?? 'Без категории'} • ${_date(e.date)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${e.type == FinanceEntryType.income ? '+' : '-'} '
                                      '${e.amount.toStringAsFixed(2)} ${e.currency}',
                                    ),
                                    IconButton(
                                      onPressed: () => _delete(e),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
        ),
      );

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

class _Summary extends StatelessWidget {
  const _Summary(this.title, this.value);

  final String title;
  final double value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                '${value.toStringAsFixed(2)} UAH',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
}

class _Draft {
  const _Draft(this.title, this.amount, this.category, this.date);

  final String title;
  final double amount;
  final String? category;
  final DateTime date;
}

class _FinanceDialog extends StatefulWidget {
  const _FinanceDialog({required this.type});

  final FinanceEntryType type;

  @override
  State<_FinanceDialog> createState() => _FinanceDialogState();
}

class _FinanceDialogState extends State<_FinanceDialog> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _category = TextEditingController();
  final DateTime _date = DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _category.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(
          widget.type == FinanceEntryType.income
              ? 'Новый доход'
              : 'Новый расход',
        ),
        content: Form(
          key: _key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Название'),
                validator: (v) =>
                    v?.trim().isEmpty == true ? 'Введите название' : null,
              ),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Сумма'),
                validator: (v) => double.tryParse(
                          (v ?? '').replaceAll(',', '.'),
                        ) ==
                        null
                    ? 'Введите сумму'
                    : null,
              ),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Категория'),
              ),
            ],
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
                  _Draft(
                    _title.text.trim(),
                    double.parse(_amount.text.replaceAll(',', '.')),
                    _category.text.trim().isEmpty
                        ? null
                        : _category.text.trim(),
                    _date,
                  ),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      );
}
