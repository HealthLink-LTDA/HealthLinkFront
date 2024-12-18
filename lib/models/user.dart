class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? crm;
  final int role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.crm,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['nome'] as String,
      email: json['email'] as String,
      password: json['senha'] as String,
      crm: json['crm'] as String?,
      role: json['cargoId'] as int,
    );
  }
}