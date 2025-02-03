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
  void initState() {
    super.initState();
    _fetchPatients(); // Busca os pacientes ao entrar na tela
  }

  void _fetchPatients() {
    final provider = Provider.of<PatientProvider>(context, listen: false);
    provider.fetchPatients();
  }

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
        title: Text(patient == null ? 'Adicionar Paciente' : 'Editar Paciente'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Paciente',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor insira o nome do paciente';
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
                      return 'Por favor insira o CPF';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Data de nascimento',
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
                      return 'Por favor insira a data de nascimento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _guardianController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do responsável',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor insira o nome do responsável';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (_editingPatient == null) {
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
                } else {
                  // Atualização
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

                  Navigator.pop(context);
                }
              }
            },
            child: Text(_editingPatient == null ? 'Adicionar' : 'Atualizar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
      ),
      body: Consumer<PatientProvider>(
        builder: (context, provider, _) {
          if (provider.patients.isEmpty) {
            return const Center(child: Text('Sem pacientes no momento...'));
          }
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
                      Text('Responsável: ${patient.guardianName}'),
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
                            onPressed: () => context
                                .read<PatientProvider>()
                                .deletePatient(patient.id),
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
