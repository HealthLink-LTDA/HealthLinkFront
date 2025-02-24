class Record {
  final String id;
  final String pacienteId;
  final String enfermeiraId;
  final int neurologico;
  final int cardioVascular;
  final int respiratorio;
  final bool nebulizacaoResgate;
  final bool vomitoPersistente;
  final DateTime data; // Adicionado o campo de data
  final String patientName;
  final int pewsScore;
  final DateTime createdAt;

  Record({
    required this.id,
    required this.pacienteId,
    required this.enfermeiraId,
    required this.neurologico,
    required this.cardioVascular,
    required this.respiratorio,
    required this.nebulizacaoResgate,
    required this.vomitoPersistente,
    required this.data,
    required this.patientName,
    required this.pewsScore,
    required this.createdAt,
  });

  int get calculatedPewsScore =>
      neurologico +
      cardioVascular +
      respiratorio +
      (nebulizacaoResgate ? 3 : 0) +
      (vomitoPersistente ? 3 : 0);

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'] as String,
      pacienteId: json['paciente']['id'] as String,
      enfermeiraId: json['enfermeira']['id'] as String,
      neurologico: json['neurologico'] as int,
      cardioVascular: json['cardioVascular'] as int,
      respiratorio: json['respiratorio'] as int,
      nebulizacaoResgate: json['nebulizacaoResgate'] as bool,
      vomitoPersistente: json['vomitoPersistente'] as bool,
      data: DateTime.parse(json['data']),
      patientName: json['paciente']['nome'] as String,
      pewsScore: (json['neurologico'] as int) +
          (json['cardioVascular'] as int) +
          (json['respiratorio'] as int) +
          ((json['nebulizacaoResgate'] as bool) ? 3 : 0) +
          ((json['vomitoPersistente'] as bool) ? 3 : 0),
      createdAt: DateTime.parse(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paciente': pacienteId,
      'enfermeira': enfermeiraId,
      'neurologico': neurologico,
      'cardioVascular': cardioVascular,
      'respiratorio': respiratorio,
      'nebulizacaoResgate': nebulizacaoResgate,
      'vomitoPersistente': vomitoPersistente,
      'data': data.toIso8601String(), // Convertendo DateTime para string ISO
      'nomePaciente': patientName,
      'notaPews': pewsScore,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
