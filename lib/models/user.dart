class User {
  final String id;
  final String email;
  final String role;
  final String name;
  final String? crm;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.crm,
  });
}