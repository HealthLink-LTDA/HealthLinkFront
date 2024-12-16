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
}
