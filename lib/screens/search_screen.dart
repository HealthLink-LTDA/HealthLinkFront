import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medical_app/providers/record_provider.dart';
import 'package:medical_app/models/record.dart';
import 'package:medical_app/providers/patient_provider.dart';
import 'package:medical_app/providers/auth_provider.dart';
import 'package:medical_app/providers/user_provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class MonitoringTimer extends StatefulWidget {
  final DateTime lastUpdate;
  final int pewsScore;

  const MonitoringTimer({
    super.key,
    required this.lastUpdate,
    required this.pewsScore,
  });

  @override
  State<MonitoringTimer> createState() => _MonitoringTimerState();
}

class _MonitoringTimerState extends State<MonitoringTimer> {
  Timer? _timer;
  Duration _timeUntilNextCheck = Duration.zero;
  late DateTime _nextCheck;

  @override
  void initState() {
    super.initState();
    _initializeNextCheck();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeNextCheck() {
    int intervalHours;
    if (widget.pewsScore >= 7) {
      return;
    } else if (widget.pewsScore >= 4) {
      intervalHours = 1;
    } else if (widget.pewsScore >= 3) {
      intervalHours = 2;
    } else if (widget.pewsScore >= 1) {
      intervalHours = 4;
    } else {
      intervalHours = 6;
    }

    _nextCheck = widget.lastUpdate;
    while (_nextCheck.isBefore(DateTime.now())) {
      _nextCheck = _nextCheck.add(Duration(hours: intervalHours));
    }
    _timeUntilNextCheck = _nextCheck.difference(DateTime.now());
  }

  void _startTimer() {
    if (widget.pewsScore >= 7) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _timeUntilNextCheck = _nextCheck.difference(DateTime.now());
        });
      }
    });
  }

  String _getMonitoringText() {
    if (widget.pewsScore >= 7) {
      return 'Monitorização Contínua';
    } else if (_timeUntilNextCheck.isNegative) {
      return 'ATRASADO';
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(_timeUntilNextCheck.inHours);
    String minutes = twoDigits(_timeUntilNextCheck.inMinutes.remainder(60));
    String seconds = twoDigits(_timeUntilNextCheck.inSeconds.remainder(60));
    return 'Próxima verificação em: $hours:$minutes:$seconds';
  }

  Color _getTextColor() {
    if (widget.pewsScore >= 7 || _timeUntilNextCheck.isNegative) {
      return Colors.red;
    } else if (widget.pewsScore >= 4) {
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.pewsScore < 7) const Icon(Icons.timer, size: 16),
        const SizedBox(width: 4),
        Text(
          _getMonitoringText(),
          style: TextStyle(
            color: _getTextColor(),
            fontWeight: _timeUntilNextCheck.isNegative || widget.pewsScore >= 7
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPatientId;
  int _neurologico = 0;
  int _cardioVascular = 0;
  int _respiratorio = 0;
  bool _nebulizacaoResgate = false;
  bool _vomitoPersistente = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<RecordProvider>(context, listen: false).fetchRecords());
  }

  void _showEditDialog(BuildContext context, Record record) {
    _selectedPatientId = record.pacienteId;
    _neurologico = record.neurologico;
    _cardioVascular = record.cardioVascular;
    _respiratorio = record.respiratorio;
    _nebulizacaoResgate = record.nebulizacaoResgate;
    _vomitoPersistente = record.vomitoPersistente;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Triagem'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<PatientProvider>(
                    builder: (context, patientProvider, _) {
                      return Text(
                        'Paciente: ${record.patientName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final provider =
                      Provider.of<RecordProvider>(context, listen: false);
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);

                  final success = await provider.updateRecord(
                    record.id,
                    Record(
                      id: record.id,
                      pacienteId: record.pacienteId,
                      enfermeiraId: authProvider.currentUser!,
                      neurologico: _neurologico,
                      cardioVascular: _cardioVascular,
                      respiratorio: _respiratorio,
                      nebulizacaoResgate: _nebulizacaoResgate,
                      vomitoPersistente: _vomitoPersistente,
                      data: record.data,
                      patientName: record.patientName,
                      pewsScore: _neurologico +
                          _cardioVascular +
                          _respiratorio +
                          (_nebulizacaoResgate ? 3 : 0) +
                          (_vomitoPersistente ? 3 : 0),
                      createdAt: record.createdAt,
                    ),
                  );

                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoramento de Pacientes'),
      ),
      body: Consumer<RecordProvider>(
        builder: (context, recordProvider, child) {
          final records = List<Record>.from(recordProvider.records)
            ..sort((a, b) =>
                b.calculatedPewsScore.compareTo(a.calculatedPewsScore));

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final pewsScore = record.calculatedPewsScore;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  title: Text(
                    record.patientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nota PEWS: $pewsScore'),
                      MonitoringTimer(
                        key: ValueKey('timer_${record.id}'),
                        lastUpdate: record.data,
                        pewsScore: pewsScore,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.update),
                    onPressed: () => _showEditDialog(context, record),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
