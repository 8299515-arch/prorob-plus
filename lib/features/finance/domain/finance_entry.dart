enum FinanceEntryType { income, expense }

class FinanceEntry {
  const FinanceEntry({
    required this.id,
    required this.projectId,
    required this.type,
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
    this.category,
  });

  final String id;
  final String projectId;
  final FinanceEntryType type;
  final String title;
  final double amount;
  final String currency;
  final DateTime date;
  final String? category;
}
