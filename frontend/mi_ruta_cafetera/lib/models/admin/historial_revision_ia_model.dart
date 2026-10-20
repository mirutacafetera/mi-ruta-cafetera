class HistorialRevisionIAModel {
  final String id;
  final String tipoSolicitud;
  final String nombreSolicitud;
  final String nombreSitio;
  final String decision;
  final String motivo;
  final List<String> criterios;
  final DateTime? fechaDecision;

  const HistorialRevisionIAModel({
    required this.id,
    required this.tipoSolicitud,
    required this.nombreSolicitud,
    required this.nombreSitio,
    required this.decision,
    required this.motivo,
    required this.criterios,
    this.fechaDecision,
  });

  factory HistorialRevisionIAModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return HistorialRevisionIAModel(
      id: (json['_id'] ?? '').toString(),
      tipoSolicitud: (json['tipoSolicitud'] ?? '').toString(),
      nombreSolicitud: (json['nombreSolicitud'] ?? '').toString(),
      nombreSitio: (json['nombreSitio'] ?? '').toString(),
      decision: (json['decision'] ?? '').toString(),
      motivo: (json['motivo'] ?? '').toString(),
      criterios: (json['criterios'] is List)
          ? (json['criterios'] as List)
              .map((item) => item.toString())
              .toList()
          : [],
      fechaDecision: json['fechaDecision'] == null
          ? null
          : DateTime.tryParse(
              json['fechaDecision'].toString(),
            ),
    );
  }
}