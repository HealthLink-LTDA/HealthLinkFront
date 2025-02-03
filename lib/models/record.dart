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
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'] as String,
      pacienteId: json['paciente']['id']
          as String, // Ajustado para pegar o ID corretamente
      enfermeiraId: json['enfermeira']['id']
          as String, // Ajustado para pegar o ID corretamente
      neurologico: json['neurologico'] as int,
      cardioVascular: json['cardioVascular'] as int,
      respiratorio: json['respiratorio'] as int,
      nebulizacaoResgate: json['nebulizacaoResgate'] as bool,
      vomitoPersistente: json['vomitoPersistente'] as bool,
      data: DateTime.parse(json['data']), // Convertendo string para DateTime
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
    };
  }
}
