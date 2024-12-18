class Record {
  final String id;
  final String pacienteId;
  final String enfermeiraId;
  final int neurologico;
  final int cardioVascular;
  final int respiratorio;
  final bool nebulizacaoResgate;
  final bool vomitoPersistente;
  final String date;

  Record({
    required this.id,
    required this.pacienteId,
    required this.enfermeiraId,
    required this.neurologico,
    required this.cardioVascular,
    required this.respiratorio,
    required this.nebulizacaoResgate,
    required this.vomitoPersistente,
    required this.date,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      id: json['id'] as String,
      pacienteId: json['pacienteId'] as String,
      enfermeiraId: json['enfermeiraId'] as String,
      neurologico: json['neurologico'] as int,
      cardioVascular: json['cardioVascular'] as int,
      respiratorio: json['respiratorio'] as int,
      nebulizacaoResgate: json['nebulizacaoResgate'] as bool,
      vomitoPersistente: json['vomitoPersistente'] as bool,
      date: json['date'] as String,
    );
  }
}
