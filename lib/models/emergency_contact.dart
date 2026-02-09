class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relation': relation,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory EmergencyContact.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return EmergencyContact(
      id: id,
      name: map['name'],
      phone: map['phone'],
      relation: map['relation'],
    );
  }
}
