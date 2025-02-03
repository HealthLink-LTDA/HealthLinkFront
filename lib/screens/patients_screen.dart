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
                      return 'Por favor, insira o nome do paciente';
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
                      return 'Por favor, insira o CPF';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento',
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
                      return 'Por favor, selecione a data de nascimento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _guardianController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Responsável',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome do responsável';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Anotações',
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
            child: Text(_editingPatient == null ? 'Adicionar' : 'Atualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Tem certeza que deseja remover ${patient.name} dos pacientes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showUpdateConfirmation(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Atualização'),
        content: Text(
            'Tem certeza que deseja atualizar as informações de ${patient.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
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
            child: const Text('Atualizar'),
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
                      Text(
                        'Nascido em: ${DateFormat('MM/dd/yyyy').format(DateTime.parse(patient.dateOfBirth))}',
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
