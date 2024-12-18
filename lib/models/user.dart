class User {
  final String id;
  final String email;
  final String role;
  final String name;
  final String password;
  final String? crm;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    required this.password,
    this.crm,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
      password: json['password'] as String,
      crm: json['crm'] as String?,
    );
  }
}