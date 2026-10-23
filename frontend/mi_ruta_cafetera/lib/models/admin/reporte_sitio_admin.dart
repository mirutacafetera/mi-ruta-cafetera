class ReporteSitioAdmin {
  final String id;
  final String asunto;
  final String mensaje;
  final String estado;
  final String tipoReporte;
  final String? respuestaAdmin;
  final String sitioId;
  final String nombreSitio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReporteSitioAdmin({
    required this.id,
    required this.asunto,
    required this.mensaje,
    required this.estado,
    required this.tipoReporte,
    required this.sitioId,
    required this.nombreSitio,
    this.respuestaAdmin,
    this.createdAt,
    this.updatedAt,
  });

  factory ReporteSitioAdmin.fromJson(Map<String, dynamic> json) {
    final sitio = json['sitioId'];
    final sitioMap = sitio is Map
        ? Map<String, dynamic>.from(sitio)
        : <String, dynamic>{};

    return ReporteSitioAdmin(
      id: (json['_id'] ?? '').toString(),
      asunto: (json['asunto'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      estado: (json['estado'] ?? 'pendiente').toString(),
      tipoReporte: (json['tipoReporte'] ?? 'problema').toString(),
      respuestaAdmin: json['respuestaAdmin']?.toString(),
      sitioId: sitioMap.isNotEmpty
          ? (sitioMap['_id'] ?? '').toString()
          : (sitio ?? '').toString(),
      nombreSitio: (sitioMap['nombre'] ?? 'Sitio sin nombre').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()),
    );
  }

  String get estadoLegible {
    switch (estado) {
      case 'en_revision':
        return 'En revisión';
      case 'resuelto':
        return 'Resuelto';
      default:
        return 'Pendiente';
    }
  }

  String get tipoLegible {
    switch (tipoReporte) {
      case 'sugerencia':
        return 'Sugerencia';
      case 'mejora':
        return 'Mejora';
      case 'otro':
        return 'Otro';
      default:
        return 'Problema';
    }
  }
}
