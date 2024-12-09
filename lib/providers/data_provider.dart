import 'package:flutter/foundation.dart';
import 'package:medical_app/models/user.dart';
import 'package:medical_app/models/patient.dart';

class DataProvider with ChangeNotifier {
  final List<User> _team = [];
  final List<Patient> _patients = [];

  List<User> get team => List.unmodifiable(_team);
  List<Patient> get patients => List.unmodifiable(_patients);

  void addTeamMember(User user) {
    _team.add(user);
    notifyListeners();
  }

  void updateTeamMember(String id, User updatedUser) {
    final index = _team.indexWhere((member) => member.id == id);
    if (index != -1) {
      _team[index] = updatedUser;
      notifyListeners();
    }
  }

  void deleteTeamMember(String id) {
    _team.removeWhere((member) => member.id == id);
    notifyListeners();
  }

  void addPatient(Patient patient) {
    _patients.add(patient);
    notifyListeners();
  }

  void updatePatient(String id, Patient updatedPatient) {
    final index = _patients.indexWhere((patient) => patient.id == id);
    if (index != -1) {
      _patients[index] = updatedPatient;
      notifyListeners();
    }
  }

  void deletePatient(String id) {
    _patients.removeWhere((patient) => patient.id == id);
    notifyListeners();
  }
}