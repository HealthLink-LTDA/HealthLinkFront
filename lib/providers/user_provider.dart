import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:medical_app/models/user.dart';
import 'auth_provider.dart';
import 'package:http/http.dart' as http;

class UserProvider with ChangeNotifier {
  final AuthProvider authProvider;

  UserProvider(this.authProvider);

  final List<User> _team = [];

  List<User> get team => List.unmodifiable(_team);

  Future<List<User>?> fetchTeamMembers() async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return null;
    }

    try {
      final response = await http.get(Uri.parse('http://localhost:3001/funcionario'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<User> users = data.map((userJson) => User.fromJson(userJson)).toList();

        _team.clear();
        _team.addAll(users);

        notifyListeners();
        return users;
      } else {
        debugPrint('Erro ao encontrar os funcionários: ${response.statusCode}');
        debugPrint(response.body);
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return null;
    }
  }

  Future<User?> fetchTeamMemberById() async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return null;
    }

    try {
      final response = await http.get(Uri.parse('http://localhost:3001/funcionario'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        dynamic data = jsonDecode(response.body);
        User user = data.map((userJson) => User.fromJson(userJson)).toList();

        notifyListeners();
        return user;
      } else {
        debugPrint('Erro ao encontrar os funcionários: ${response.statusCode}');
        debugPrint(response.body);
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return null;
    }
  }

  Future<bool> addTeamMember(User user) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/funcionario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          },
        body: jsonEncode({
          'nome': user.name,
          'email': user.email,
          'senha': user.password,
          'crm': user.crm,
          'roleId': user.role,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('Funcionário criado com sucesso!');
        notifyListeners();
        fetchTeamMembers();
        return true;
      } else {
        debugPrint('Erro ao criar o funcionário: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }

  Future<bool> updateTeamMember(String id, User updatedUser) async{
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3001/funcionario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          },
        body: jsonEncode({
          'nome': updatedUser.name,
          'email': updatedUser.email,
          'senha': updatedUser.password,
          'crm': updatedUser.crm,
          'roleId': updatedUser.role,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Funcionário atualizado com sucesso!');
        notifyListeners();
        fetchTeamMembers();
        return true;
      } else {
        debugPrint('Erro ao atualizar o funcionário: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }

  Future<bool> deleteTeamMember(String id) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3001/funcionario/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          },
      );

      if (response.statusCode == 200) {
        debugPrint('Funcionário deletado com sucesso!');
        notifyListeners();
        fetchTeamMembers();
        return true;
      } else {
        debugPrint('Erro ao deletar funcionário: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }
}