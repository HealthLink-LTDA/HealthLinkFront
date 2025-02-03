import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medical_app/models/record.dart';
import 'package:medical_app/providers/record_provider.dart';
import 'package:intl/intl.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  String? _selectedDoctorId;
  Record? _editingRecord;

  int _neurologico = 0;
  int _cardioVascular = 0;
  int _respiratorio = 0;
  bool _nebulizacaoResgate = false;
  bool _vomitoPersistente = false;

  @override
  void initState() {
    super.initState();
    _fetchRecords(); // Busca os registros ao entrar na tela
  }

  void _fetchRecords() {
    final provider = Provider.of<RecordProvider>(context, listen: false);
    provider.fetchRecords();
  }

  int get totalPontos =>
      _neurologico +
      _cardioVascular +
      _respiratorio +
      (_nebulizacaoResgate ? 3 : 0) +
      (_vomitoPersistente ? 3 : 0);

  void _showAddEditDialog(BuildContext context, [Record? record]) {
    _editingRecord = record;
    if (record != null) {
      _selectedPatientId = record.pacienteId;
      _selectedDoctorId = record.enfermeiraId;
      _neurologico = record.neurologico;
      _cardioVascular = record.cardioVascular;
      _respiratorio = record.respiratorio;
      _nebulizacaoResgate = record.nebulizacaoResgate;
      _vomitoPersistente = record.vomitoPersistente;
    } else {
      _selectedPatientId = null;
      _selectedDoctorId = null;
      _neurologico = 0;
      _cardioVascular = 0;
      _respiratorio = 0;
      _nebulizacaoResgate = false;
      _vomitoPersistente = false;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(
              record == null ? 'Add Medical Record' : 'Edit Medical Record'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Patient ID',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedPatientId,
                    onChanged: (value) =>
                        setStateDialog(() => _selectedPatientId = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid Patient ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Doctor ID',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedDoctorId,
                    onChanged: (value) =>
                        setStateDialog(() => _selectedDoctorId = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid Doctor ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Neurological Evaluation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _neurologico.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    label: '$_neurologico',
                    onChanged: (value) =>
                        setStateDialog(() => _neurologico = value.toInt()),
                  ),
                  const Text(
                    'Cardiovascular Evaluation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _cardioVascular.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    label: '$_cardioVascular',
                    onChanged: (value) =>
                        setStateDialog(() => _cardioVascular = value.toInt()),
                  ),
                  const Text(
                    'Respiratory Evaluation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _respiratorio.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    label: '$_respiratorio',
                    onChanged: (value) =>
                        setStateDialog(() => _respiratorio = value.toInt()),
                  ),
                  CheckboxListTile(
                    title: const Text('Nebulization Rescue'),
                    value: _nebulizacaoResgate,
                    onChanged: (value) =>
                        setStateDialog(() => _nebulizacaoResgate = value!),
                  ),
                  CheckboxListTile(
                    title: const Text('Persistent Vomiting'),
                    value: _vomitoPersistente,
                    onChanged: (value) =>
                        setStateDialog(() => _vomitoPersistente = value!),
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
                if (_formKey.currentState!.validate()) {
                  final provider =
                      Provider.of<RecordProvider>(context, listen: false);
                  if (_editingRecord == null) {
                    provider.addRecord(
                      Record(
                        id: DateTime.now().toString(),
                        pacienteId: _selectedPatientId!,
                        enfermeiraId: _selectedDoctorId!,
                        neurologico: _neurologico,
                        cardioVascular: _cardioVascular,
                        respiratorio: _respiratorio,
                        nebulizacaoResgate: _nebulizacaoResgate,
                        vomitoPersistente: _vomitoPersistente,
                      ),
                    );
                  } else {
                    provider.updateTriagem(
                      _editingRecord!.id,
                      Record(
                        id: _editingRecord!.id,
                        pacienteId: _selectedPatientId!,
                        enfermeiraId: _selectedDoctorId!,
                        neurologico: _neurologico,
                        cardioVascular: _cardioVascular,
                        respiratorio: _respiratorio,
                        nebulizacaoResgate: _nebulizacaoResgate,
                        vomitoPersistente: _vomitoPersistente,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(_editingRecord == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Record record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider =
                  Provider.of<RecordProvider>(context, listen: false);
              provider.deleteTriagem(record.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
      ),
      body: Consumer<RecordProvider>(
        builder: (context, provider, _) {
          if (provider.record.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.record.length,
            itemBuilder: (context, index) {
              final record = provider.record[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient ID: ${record.pacienteId}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Doctor ID: ${record.enfermeiraId}'),
                      Text('Total Points: $totalPontos'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                _showAddEditDialog(context, record),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () =>
                                _showDeleteConfirmation(context, record),
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
