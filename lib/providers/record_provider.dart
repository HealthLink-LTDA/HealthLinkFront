import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:medical_app/models/record.dart';
import 'auth_provider.dart';
import 'package:http/http.dart' as http;

class RecordProvider with ChangeNotifier {
  final AuthProvider authProvider;

  RecordProvider(this.authProvider);

  final List<Record> _records = [];

  List<Record> get records => List.unmodifiable(_records);

  Future<List<Record>?> fetchRecords() async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3001/triagem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Record> records =
            data.map((recordJson) => Record.fromJson(recordJson)).toList();

        _records.clear();
        _records.addAll(records);

        notifyListeners();
        return records;
      } else {
        debugPrint('Erro ao buscar triagens: ${response.statusCode}');
        debugPrint(response.body);
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return null;
    }
  }

  Future<Record?> fetchRecordById(String id) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3001/triagem/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return Record.fromJson(data);
      } else {
        debugPrint('Erro ao buscar triagem: ${response.statusCode}');
        debugPrint(response.body);
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return null;
    }
  }

  Future<bool> addRecord(Record record) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/triagem'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(record.toJson()), // Usando toJson()
      );

      if (response.statusCode == 201) {
        debugPrint('Triagem criada com sucesso!');
        await fetchRecords(); // Atualiza a lista
        return true;
      } else {
        debugPrint('Erro ao criar a triagem: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }

  Future<bool> updateRecord(String id, Record updatedRecord) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3001/triagem/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updatedRecord.toJson()), // Usando toJson()
      );

      if (response.statusCode == 200) {
        debugPrint('Triagem atualizada com sucesso!');
        await fetchRecords(); // Atualiza a lista
        return true;
      } else {
        debugPrint('Erro ao atualizar a triagem: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }

  Future<bool> deleteRecord(String id) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3001/triagem/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Triagem removida com sucesso!');
        _records.removeWhere((record) => record.id == id);
        notifyListeners();
        return true;
      } else {
        debugPrint('Erro ao remover a triagem: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }
}
