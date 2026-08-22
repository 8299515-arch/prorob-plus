enum ContactType { client, contractor, employee }

class Contact {
  const Contact({required this.id, required this.name, required this.type, this.phone, this.email, this.company, this.notes});
  final String id;
  final String name;
  final ContactType type;
  final String? phone;
  final String? email;
  final String? company;
  final String? notes;
}
