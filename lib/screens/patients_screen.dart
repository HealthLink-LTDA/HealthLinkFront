import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medical_app/models/patient.dart';
import 'package:medical_app/providers/patient_provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dateController = TextEditingController();
  final _guardianController = TextEditingController();
  final _notesController = TextEditingController();

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  Patient? _editingPatient;

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _dateController.dispose();
    _guardianController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddEditDialog(BuildContext context, [Patient? patient]) {
    _editingPatient = patient;
    if (patient != null) {
      _nameController.text = patient.name;
      _cpfController.text = patient.cpf;
      _dateController.text = patient.dateOfBirth;
      _guardianController.text = patient.guardianName;
      _notesController.text = patient.notes ?? '';
    } else {
      _nameController.clear();
      _cpfController.clear();
      _dateController.clear();
      _guardianController.clear();
      _notesController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient == null ? 'Add Patient' : 'Edit Patient'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [_cpfFormatter],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter CPF';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _guardianController,
                  decoration: const InputDecoration(
                    labelText: 'Guardian Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter guardian name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_editingPatient == null) {
                if (_formKey.currentState!.validate()) {
                  final patient = Patient(
                    id: DateTime.now().toString(),
                    name: _nameController.text,
                    cpf: _cpfController.text,
                    dateOfBirth: _dateController.text,
                    guardianName: _guardianController.text,
                    notes: _notesController.text,
                  );
                  context.read<PatientProvider>().addPatient(patient);
                  Navigator.pop(context);
                }
              } else {
                _showUpdateConfirmation(context, _editingPatient!);
              }
            },
            child: Text(_editingPatient == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to remove ${patient.name} from patients?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PatientProvider>().deletePatient(patient.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showUpdateConfirmation(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Update'),
        content: Text(
            'Are you sure you want to update ${patient.name}\'s information?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final updatedPatient = Patient(
                  id: _editingPatient!.id,
                  name: _nameController.text,
                  cpf: _cpfController.text,
                  dateOfBirth: _dateController.text,
                  guardianName: _guardianController.text,
                  notes: _notesController.text,
                );

                context.read<PatientProvider>().updatePatient(
                      _editingPatient!.id,
                      updatedPatient,
                    );

                Navigator.pop(context); // Fecha o diálogo de confirmação
                Navigator.pop(context); // Fecha o diálogo de edição
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.patients.length,
            itemBuilder: (context, index) {
              final patient = provider.patients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('CPF: ${patient.cpf}'),
                      Text('Guardian: ${patient.guardianName}'),
                      Text(
                        'Born: ${DateFormat('MM/dd/yyyy').format(DateTime.parse(patient.dateOfBirth))}',
                      ),
                      if (patient.notes != null &&
                          patient.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(patient.notes!),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                _showAddEditDialog(context, patient),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                _showDeleteConfirmation(context, patient),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
