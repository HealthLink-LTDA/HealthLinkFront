import 'package:flutter/material.dart';
import 'package:medical_app/models/record.dart';
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

  // Dados mockados para teste
  final List<Record> _records = [];
  final List<Map<String, String>> _mockPatients = [
    {'id': '1', 'name': 'João Silva'},
    {'id': '2', 'name': 'Maria Santos'},
  ];
  final List<Map<String, String>> _mockDoctors = [
    {'id': '1', 'name': 'Dr. Carlos'},
    {'id': '2', 'name': 'Dra. Ana'},
  ];

  // Valores para as avaliações
  int _neurologico = 0;
  int _cardioVascular = 0;
  int _respiratorio = 0;
  bool _nebulizacaoResgate = false;
  bool _vomitoPersistente = false;

  int get totalPontos =>
      _neurologico +
      _cardioVascular +
      _respiratorio +
      (_nebulizacaoResgate ? 3 : 0) +
      (_vomitoPersistente ? 3 : 0);

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildAvaliacaoNeurologica(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avaliação Neurológica',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        RadioListTile<int>(
          title: const Text('Ativo'),
          value: 0,
          groupValue: _neurologico,
          onChanged: (value) => setState(() => _neurologico = value!),
        ),
        RadioListTile<int>(
          title: const Text('Sonolento'),
          value: 1,
          groupValue: _neurologico,
          onChanged: (value) => setState(() => _neurologico = value!),
        ),
        RadioListTile<int>(
          title: const Text('Irritado'),
          value: 2,
          groupValue: _neurologico,
          onChanged: (value) => setState(() => _neurologico = value!),
        ),
        RadioListTile<int>(
          title:
              const Text('Letárgico / Obnubilado ou resposta reduzida à dor'),
          value: 3,
          groupValue: _neurologico,
          onChanged: (value) => setState(() => _neurologico = value!),
        ),
      ],
    );
  }

  Widget _buildAvaliacaoCardiovascular(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avaliação Cardiovascular',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        RadioListTile<int>(
          title: const Text('Corado ou TEC 1-2 seg'),
          value: 0,
          groupValue: _cardioVascular,
          onChanged: (value) => setState(() => _cardioVascular = value!),
        ),
        RadioListTile<int>(
          title: const Text(
              'Pálido ou TEC 3 seg ou FC acima do limite superior para a idade'),
          value: 1,
          groupValue: _cardioVascular,
          onChanged: (value) => setState(() => _cardioVascular = value!),
        ),
        RadioListTile<int>(
          title: const Text(
              'Moteado ou TEC 4 seg ou FC ≥ 20 bpm acima do limite superior para a idade'),
          value: 2,
          groupValue: _cardioVascular,
          onChanged: (value) => setState(() => _cardioVascular = value!),
        ),
        RadioListTile<int>(
          title: const Text(
              'Acinzentado/cianótico ou TEC ≥ 5 seg ou FC ≥ 30 bpm acima do limite ou bradicardia'),
          value: 3,
          groupValue: _cardioVascular,
          onChanged: (value) => setState(() => _cardioVascular = value!),
        ),
      ],
    );
  }

  Widget _buildAvaliacaoRespiratoria(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Avaliação Respiratória',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        RadioListTile<int>(
          title: const Text('FR normal para a idade, sem retração'),
          value: 0,
          groupValue: _respiratorio,
          onChanged: (value) => setState(() => _respiratorio = value!),
        ),
        RadioListTile<int>(
          title: const Text('FR acima do limite superior para a idade...'),
          value: 1,
          groupValue: _respiratorio,
          onChanged: (value) => setState(() => _respiratorio = value!),
        ),
        RadioListTile<int>(
          title: const Text('FR ≥ 20 rpm acima do limite superior...'),
          value: 2,
          groupValue: _respiratorio,
          onChanged: (value) => setState(() => _respiratorio = value!),
        ),
        RadioListTile<int>(
          title: const Text('FR ≥ 5 rpm abaixo do limite inferior...'),
          value: 3,
          groupValue: _respiratorio,
          onChanged: (value) => setState(() => _respiratorio = value!),
        ),
      ],
    );
  }

  Widget _buildOutrasAvaliacoes(StateSetter setState) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Nebulização de resgate em 15 minutos'),
          value: _nebulizacaoResgate,
          onChanged: (value) => setState(() => _nebulizacaoResgate = value!),
        ),
        CheckboxListTile(
          title: const Text('3 episódios ou mais de emese no pós operatório'),
          value: _vomitoPersistente,
          onChanged: (value) => setState(() => _vomitoPersistente = value!),
        ),
      ],
    );
  }

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
          title: Text(record == null
              ? 'Adicionar Registro Médico'
              : 'Editar Registro Médico'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedPatientId,
                    decoration: const InputDecoration(
                      labelText: 'Paciente',
                      border: OutlineInputBorder(),
                    ),
                    items: _mockPatients.map((patient) {
                      return DropdownMenuItem(
                        value: patient['id'],
                        child: Text(patient['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        _selectedPatientId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione um paciente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDoctorId,
                    decoration: const InputDecoration(
                      labelText: 'Enfermeira',
                      border: OutlineInputBorder(),
                    ),
                    items: _mockDoctors.map((doctor) {
                      return DropdownMenuItem(
                        value: doctor['id'],
                        child: Text(doctor['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDoctorId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor, selecione uma enfermeira';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Total de Pontos: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$totalPontos',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildAvaliacaoNeurologica(setStateDialog),
                  const SizedBox(height: 16),
                  _buildAvaliacaoCardiovascular(setStateDialog),
                  const SizedBox(height: 16),
                  _buildAvaliacaoRespiratoria(setStateDialog),
                  const SizedBox(height: 16),
                  _buildOutrasAvaliacoes(setStateDialog),
                  const SizedBox(height: 16),
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
                  if (_editingRecord == null) {
                    final record = Record(
                      id: DateTime.now().toString(),
                      pacienteId: _selectedPatientId!,
                      enfermeiraId: _selectedDoctorId!,
                      neurologico: _neurologico,
                      cardioVascular: _cardioVascular,
                      respiratorio: _respiratorio,
                      nebulizacaoResgate: _nebulizacaoResgate,
                      vomitoPersistente: _vomitoPersistente,
                    );
                    setState(() {
                      _records.add(record);
                    });
                    Navigator.pop(context);
                  } else {
                    _showUpdateConfirmation(context);
                  }
                }
              },
              child: Text(_editingRecord == null ? 'Adicionar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Atualização'),
        content: const Text(
            'Tem certeza que deseja atualizar este registro médico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedRecord = Record(
                id: _editingRecord!.id,
                pacienteId: _selectedPatientId!,
                enfermeiraId: _selectedDoctorId!,
                neurologico: _neurologico,
                cardioVascular: _cardioVascular,
                respiratorio: _respiratorio,
                nebulizacaoResgate: _nebulizacaoResgate,
                vomitoPersistente: _vomitoPersistente,
              );

              setState(() {
                final index =
                    _records.indexWhere((r) => r.id == _editingRecord!.id);
                if (index != -1) {
                  _records[index] = updatedRecord;
                }
              });

              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Record record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content:
            const Text('Tem certeza que deseja excluir este registro médico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _records.removeWhere((r) => r.id == record.id);
              });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros Médicos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          final patient = _mockPatients.firstWhere(
            (p) => p['id'] == record.pacienteId,
          );
          final doctor = _mockDoctors.firstWhere(
            (d) => d['id'] == record.enfermeiraId,
          );

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paciente: ${patient['name']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Enfermeira: ${doctor['name']}'),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Total de Pontos: ${record.neurologico + record.cardioVascular + record.respiratorio + (record.nebulizacaoResgate ? 3 : 0) + (record.vomitoPersistente ? 3 : 0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Avaliação Neurológica: ${record.neurologico} pontos'),
                  Text(
                      'Avaliação Cardiovascular: ${record.cardioVascular} pontos'),
                  Text('Avaliação Respiratória: ${record.respiratorio} pontos'),
                  Text(
                      'Nebulização de resgate: ${record.nebulizacaoResgate ? "Sim" : "Não"}'),
                  Text(
                      'Vômito Persistente: ${record.vomitoPersistente ? "Sim" : "Não"}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showAddEditDialog(context, record),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
