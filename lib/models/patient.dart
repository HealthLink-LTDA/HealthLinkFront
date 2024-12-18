class Patient {
  final String id;
  final String name;
  final String cpf;
  final String dateOfBirth;
  final String guardianName;
  final String? notes;

  Patient({
    required this.id,
    required this.name,
    required this.cpf,
    required this.dateOfBirth,
    required this.guardianName,
    this.notes,
  });

   factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      cpf: json['cpf'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      guardianName: json['guardianName'] as String,
      notes: json['notes'] as String?,
    );
  }
}