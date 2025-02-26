import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medical_app/models/record.dart';
import 'package:medical_app/models/user.dart';
import 'package:medical_app/providers/record_provider.dart';
import 'package:medical_app/providers/patient_provider.dart';
import 'package:medical_app/providers/user_provider.dart';
import 'package:medical_app/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class RecordsScreen extends StatefulWidget {
  final Record? initialRecord;

  const RecordsScreen({super.key, this.initialRecord});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  Record? _editingRecord;

  int _neurologico = 0;
  int _cardioVascular = 0;
  int _respiratorio = 0;
  bool _nebulizacaoResgate = false;
  bool _vomitoPersistente = false;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
    _fetchPatientsAndTeam();

    // Se houver uma triagem inicial, abrir o diálogo de edição
    if (widget.initialRecord != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddEditDialog(context, widget.initialRecord);
      });
    }
  }

  void _fetchRecords() {
    final provider = Provider.of<RecordProvider>(context, listen: false);
    provider.fetchRecords();
  }

  void _fetchPatientsAndTeam() {
    final patientProvider =
        Provider.of<PatientProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    patientProvider.fetchPatients();
    userProvider.fetchTeamMembers();
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
      _neurologico = record.neurologico;
      _cardioVascular = record.cardioVascular;
      _respiratorio = record.respiratorio;
      _nebulizacaoResgate = record.nebulizacaoResgate;
      _vomitoPersistente = record.vomitoPersistente;
    } else {
      _selectedPatientId = null;
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
          title: Text(record == null ? 'Nova Triagem' : 'Editar Triagem'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer2<PatientProvider, UserProvider>(
                    builder: (context, patientProvider, userProvider, _) {
                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Paciente',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedPatientId,
                            items: patientProvider.patients.map((patient) {
                              return DropdownMenuItem(
                                value: patient.id,
                                child: Text(patient.name),
                              );
                            }).toList(),
                            onChanged: (value) => setStateDialog(
                                () => _selectedPatientId = value),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor selecione um paciente';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              final currentUserId = authProvider.currentUser!;
                              final currentUser = userProvider.team.firstWhere(
                                (user) => user.id == currentUserId,
                                orElse: () => User(
                                  id: currentUserId,
                                  name: 'Usuário atual',
                                  email: '',
                                  password: '',
                                  crm: '',
                                  role: 0,
                                ),
                              );
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Profissional responsável:',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${currentUser.name} ',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Avaliação Neurológica',
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
                    'Avaliação Cardiovascular',
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
                    'Avaliação Respiratória',
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
                    title: const Text('Nebulização de Resgate'),
                    value: _nebulizacaoResgate,
                    onChanged: (value) =>
                        setStateDialog(() => _nebulizacaoResgate = value!),
                  ),
                  CheckboxListTile(
                    title: const Text('Vômito Persistente'),
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
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final provider =
                      Provider.of<RecordProvider>(context, listen: false);
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final now = DateTime.now();
                  if (_editingRecord == null) {
                    provider.addRecord(
                      Record(
                        id: DateTime.now().toString(),
                        pacienteId: _selectedPatientId!,
                        enfermeiraId: authProvider.currentUser!,
                        neurologico: _neurologico,
                        cardioVascular: _cardioVascular,
                        respiratorio: _respiratorio,
                        nebulizacaoResgate: _nebulizacaoResgate,
                        vomitoPersistente: _vomitoPersistente,
                        data: now,
                        patientName: _selectedPatientId!,
                        pewsScore: _calculatePewsScore(),
                        createdAt: now,
                      ),
                    );
                  } else {
                    provider.updateRecord(
                      _editingRecord!.id,
                      Record(
                        id: _editingRecord!.id,
                        pacienteId: _selectedPatientId!,
                        enfermeiraId: authProvider.currentUser!,
                        neurologico: _neurologico,
                        cardioVascular: _cardioVascular,
                        respiratorio: _respiratorio,
                        nebulizacaoResgate: _nebulizacaoResgate,
                        vomitoPersistente: _vomitoPersistente,
                        data: _editingRecord!.data,
                        patientName: _selectedPatientId!,
                        pewsScore: _calculatePewsScore(),
                        createdAt: _editingRecord!.createdAt,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(_editingRecord == null ? 'Adicionar' : 'Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleText(int role) {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Médico';
      case 3:
        return 'Enfermeiro';
      case 4:
        return 'Técnico';
      default:
        return 'Desconhecido';
    }
  }

  void _showDeleteConfirmation(BuildContext context, Record record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirme a exclusão'),
        content: const Text('Você tem certeza que quer excluir essa triagem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider =
                  Provider.of<RecordProvider>(context, listen: false);
              provider.deleteRecord(record.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  int _calculatePewsScore() {
    int score = 0;
    score += _neurologico;
    score += _cardioVascular;
    score += _respiratorio;
    if (_nebulizacaoResgate) score += 1;
    if (_vomitoPersistente) score += 1;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Triagens'),
      ),
      body: Consumer<RecordProvider>(
        builder: (context, provider, _) {
          if (provider.records.isEmpty) {
            return const Center(
                child: Text('Nenhuma triagem encontrada! Viva a saúde!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.records.length,
            itemBuilder: (context, index) {
              final record = provider.records[index];
              return RecordCard(
                record: record,
                onEdit: () => _showAddEditDialog(context, record),
                onDelete: () => _showDeleteConfirmation(context, record),
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

class RecordCard extends StatefulWidget {
  final Record record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecordCard({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<RecordCard> {
  String patientName = 'Carregando...';
  String userName = 'Carregando...';
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final patientProvider =
        Provider.of<PatientProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final patient =
        await patientProvider.fetchPatientById(widget.record.pacienteId);
    final user = await userProvider.fetchUserById(widget.record.enfermeiraId);

    if (mounted) {
      setState(() {
        patientName = patient?.name ?? 'Paciente não encontrado';
        userName = user?.name ?? 'Funcionário não encontrado';
        userRole = user != null ? _getRoleText(user.role) : '';
      });
    }
  }

  String _getRoleText(int role) {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Médico';
      case 3:
        return 'Enfermeiro';
      case 4:
        return 'Técnico';
      default:
        return 'Desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paciente: $patientName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
                'Profissional: $userName ${userRole.isNotEmpty ? "($userRole)" : ""}'),
            Text(
                'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.record.data)}'),
            Text(
                'Total de pontos: ${widget.record.neurologico + widget.record.cardioVascular + widget.record.respiratorio + (widget.record.nebulizacaoResgate ? 3 : 0) + (widget.record.vomitoPersistente ? 3 : 0)}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: widget.onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
