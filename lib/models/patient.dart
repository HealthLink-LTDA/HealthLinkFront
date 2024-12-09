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
}