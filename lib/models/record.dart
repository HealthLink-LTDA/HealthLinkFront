class Record {
  final String id;
  final String pacienteId;
  final String enfermeiraId;
  final int neurologico;
  final int cardioVascular;
  final int respiratorio;
  final bool nebulizacaoResgate;
  final bool vomitoPersistente;

  Record({
    required this.id,
    required this.pacienteId,
    required this.enfermeiraId,
    required this.neurologico,
    required this.cardioVascular,
    required this.respiratorio,
    required this.nebulizacaoResgate,
    required this.vomitoPersistente,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'] as String,
      pacienteId: json['paciente'] as String,
      enfermeiraId: json['enfermeira'] as String,
      neurologico: json['neurologico'] as int,
      cardioVascular: json['cardioVascular'] as int,
      respiratorio: json['respiratorio'] as int,
      nebulizacaoResgate: json['nebulizacaoResgate'] as bool,
      vomitoPersistente: json['vomitoPersistente'] as bool,
    );
  }
}
