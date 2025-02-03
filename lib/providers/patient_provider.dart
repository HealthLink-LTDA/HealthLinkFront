import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:medical_app/models/patient.dart';
import 'auth_provider.dart';
import 'package:http/http.dart' as http;

class PatientProvider with ChangeNotifier {
  final AuthProvider authProvider;

  PatientProvider(this.authProvider);

  final List<Patient> _patients = [];

  List<Patient> get patients => List.unmodifiable(_patients);

  Future<List<Patient>?> fetchPatients() async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return null;
    }

    try {
      final response =
          await http.get(Uri.parse('http://localhost:3001/paciente'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Patient> patients =
            data.map((patientJson) => Patient.fromJson(patientJson)).toList();

        _patients.clear();
        _patients.addAll(patients);

        notifyListeners();
        return patients;
      } else {
        debugPrint('Erro ao encontrar os pacientes: ${response.statusCode}');
        debugPrint(response.body);
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return null;
    }
  }

  Future<Patient?> fetchPatientById(String id) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3001/paciente/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Patient.fromJson(data);
      } else {
        debugPrint('Erro ao encontrar o paciente: ${response.statusCode}');
        debugPrint(response.body);
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return null;
    }
  }

  Future<bool> addPatient(Patient patient) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3001/paciente'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nome': patient.name,
          'cpf': patient.cpf,
          'nomeResponsavel': patient.guardianName,
          'dataNascimento': patient.dateOfBirth,
          'notas': patient.notes,
        }),
      );

      if (response.statusCode == 201) {
        debugPrint('Paciente criado com sucesso!');
        notifyListeners();
        fetchPatients();
        return true;
      } else {
        debugPrint('Erro ao criar paciente: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }

  Future<bool> updatePatient(String id, Patient updatedPatient) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3001/paciente/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nome': updatedPatient.name,
          'cpf': updatedPatient.cpf,
          'nomeResponsavel': updatedPatient.guardianName,
          'dataNascimento': updatedPatient.dateOfBirth,
          'notas': updatedPatient.notes,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Paciente atualizado com sucesso!');
        notifyListeners();
        fetchPatients();
        return true;
      } else {
        debugPrint('Erro ao atualizar paciente: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }

  Future<bool> deletePatient(String id) async {
    final token = authProvider.authToken;

    if (token == null) {
      debugPrint('Erro: Usuário não autenticado.');
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3001/paciente/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Paciente deletado com sucesso!');
        notifyListeners();
        fetchPatients();
        return true;
      } else {
        debugPrint('Erro ao deletar paciente: ${response.statusCode}');
        debugPrint(response.body);
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao fazer o request: $e');
      return false;
    }
  }
}
