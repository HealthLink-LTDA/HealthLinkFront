import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:medical_app/models/record.dart';
import 'auth_provider.dart';
import 'package:http/http.dart' as http;

class RecordProvider with ChangeNotifier {
  final AuthProvider authProvider;

  RecordProvider(this.authProvider);

  final List<Record> _records = [];

  List<Record> get record => List.unmodifiable(_records);

  Future<List<Record>?> fetchRecords() async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return null;
    }

    try {
      final response = await http.get(Uri.parse('http://localhost:3001/triagem'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 201) {
        List<dynamic> data = jsonDecode(response.body);
        List<Record> records = data.map((recordJson) => Record.fromJson(recordJson)).toList();

        _records.clear();
        _records.addAll(records);

        notifyListeners();
        return records;
      } else {
        debugPrint('Erro ao encontrar as triagens: ${response.statusCode}');
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
        body: jsonEncode({
          'pacienteId': record.pacienteId,
          'enfermeiraId': record.enfermeiraId,
          'neurologico': record.neurologico,
          'cardioVascular': record.cardioVascular,
          'respiratorio': record.respiratorio,
          'nebulizacaoResgate': record.nebulizacaoResgate,
          'vomitoPersistente': record.vomitoPersistente,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('Triagem criada com sucesso!');
        notifyListeners();
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

  Future<bool> updateTriagem(String id, Record updatedRecord) async{
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3001/triagem'),
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pacienteId': updatedRecord.pacienteId,
          'enfermeiraId': updatedRecord.enfermeiraId,
          'neurologico': updatedRecord.neurologico,
          'cardioVascular': updatedRecord.cardioVascular,
          'respiratorio': updatedRecord.respiratorio,
          'nebulizacaoResgate': updatedRecord.nebulizacaoResgate,
          'vomitoPersistente': updatedRecord.vomitoPersistente,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('Triagem atualizada com sucesso!');
        notifyListeners();
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

  Future<bool> deleteTriagem(String id) async {
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
        debugPrint('Triagem deletada com sucesso!');
        notifyListeners();
        return true;
      } else {
        debugPrint('Erro ao deletar a triagem: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }
}