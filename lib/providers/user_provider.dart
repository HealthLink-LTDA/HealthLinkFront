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

  Future<bool> fetchTeamMembers() async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3001/funcionario'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<User> users =
            data.map((userJson) => User.fromJson(userJson)).toList();

        _team.clear();
        _team.addAll(users);

        notifyListeners();
        return true;
      } else {
        debugPrint('Erro ao encontrar os funcionários: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }

  Future<bool> addTeamMember(User user) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      debugPrint('Enviando novo membro:');
      debugPrint('Nome: ${user.name}');
      debugPrint('Email: ${user.email}');
      debugPrint('Role selecionada: ${user.role}');
      debugPrint('CRM: ${user.crm}');

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
          'cargoId': user.role,
        }),
      );

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Resposta: ${response.body}');

      if (response.statusCode == 201) {
        debugPrint('Funcionário criado com sucesso!');
        final newUser = User.fromJson(jsonDecode(response.body));
        _team.add(newUser);
        notifyListeners();
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

  Future<bool> updateTeamMember(String id, User updatedUser) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      debugPrint('Atualizando membro:');
      debugPrint('ID: $id');
      debugPrint('Nome: ${updatedUser.name}');
      debugPrint('Email: ${updatedUser.email}');
      debugPrint('Role selecionada: ${updatedUser.role}');
      debugPrint('CRM: ${updatedUser.crm}');

      final response = await http.put(
        Uri.parse('http://localhost:3001/funcionario/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nome': updatedUser.name,
          'email': updatedUser.email,
          if (updatedUser.password != null && updatedUser.password!.isNotEmpty)
            'senha': updatedUser.password,
          'crm': updatedUser.crm,
          'cargoId': updatedUser.role,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Funcionário atualizado com sucesso!');
        final index = _team.indexWhere((user) => user.id == id);
        if (index != -1) {
          _team[index] = User.fromJson(jsonDecode(response.body));
          notifyListeners();
        }
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
        _team.removeWhere((user) => user.id == id);
        notifyListeners();
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

  Future<User?> fetchUserById(String id) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3001/funcionario/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        debugPrint('Erro ao encontrar o funcionário: ${response.statusCode}');
        debugPrint(response.body);
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return null;
    }
  }
}
