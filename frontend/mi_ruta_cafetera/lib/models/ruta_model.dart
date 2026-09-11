class RutaModel {
  final String id;
  final String nombre;
  final String tipo;
  final List<String> sitios;
  final double distanciaKm;
  final double duracionMinutos;
  final String? usuarioId;
  final DateTime? creadaEn;
  final DateTime? venceEn;
  final bool activa;

  const RutaModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.sitios,
    required this.distanciaKm,
    required this.duracionMinutos,
    required this.usuarioId,
    required this.creadaEn,
    required this.venceEn,
    required this.activa,
  });

  factory RutaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final sitiosJson =
        json['sitios'] ?? json['puntos'] ?? [];

    final sitios = sitiosJson is List
        ? sitiosJson
            .map(
              (item) {
                if (item is Map<String, dynamic>) {
                  return (
                    item['_id'] ??
                            item['id'] ??
                            item['sitioId'] ??
                            ''
                        )
                        .toString();
                }

                return item.toString();
              },
            )
            .toList()
        : <String>[];

    return RutaModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? 'Ruta personalizada')
          .toString(),
      tipo: (json['tipo'] ?? 'personalizada').toString(),
      sitios: List<String>.from(sitios),
      distanciaKm:
          _numeroADouble(
        json['distanciaKm'] ??
            json['distancia'] ??
            0,
      ),
      duracionMinutos:
          _numeroADouble(
        json['duracionMinutos'] ??
            json['duracion'] ??
            0,
      ),
      usuarioId:
          json['usuarioId']?.toString() ??
              json['usuario']?.toString(),
      creadaEn:
          _fechaDesdeJson(
        json['creadaEn'] ??
            json['createdAt'],
      ),
      venceEn:
          _fechaDesdeJson(
        json['venceEn'] ??
            json['expiresAt'],
      ),
      activa:
          json['activa'] ??
              json['activo'] ??
              true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'sitios': sitios,
      'distanciaKm': distanciaKm,
      'duracionMinutos': duracionMinutos,
      'usuarioId': usuarioId,
      'creadaEn': creadaEn?.toIso8601String(),
      'venceEn': venceEn?.toIso8601String(),
      'activa': activa,
    };
  }

  static double _numeroADouble(
    dynamic valor,
  ) {
    if (valor is num) {
      return valor.toDouble();
    }

    return double.tryParse(
          valor?.toString() ?? '',
        ) ??
        0;
  }

  static DateTime? _fechaDesdeJson(
    dynamic valor,
  ) {
    if (valor == null) {
      return null;
    }

    return DateTime.tryParse(
      valor.toString(),
    );
  }
}