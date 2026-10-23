
class ReporteSitioAdmin {
  final String id;
  final String asunto;
  final String mensaje;
  final String estado;
  final String tipoReporte;
  final String? respuestaAdmin;

  final String sitioId;
  final String nombreSitio;
  final String? fotoSitio;
  final String nombreCategoria;

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
    this.fotoSitio,
    this.nombreCategoria = 'Sin categoría',
    this.createdAt,
    this.updatedAt,
  });

  factory ReporteSitioAdmin.fromJson(Map<String, dynamic> json) {
    final sitioJson = json['sitioId'];

    final Map<String, dynamic> sitio = sitioJson is Map
        ? Map<String, dynamic>.from(sitioJson)
        : <String, dynamic>{};

    final categoriaJson = sitio['categoria'];

    final Map<String, dynamic> categoria = categoriaJson is Map
        ? Map<String, dynamic>.from(categoriaJson)
        : <String, dynamic>{};

    // Primero intenta obtener la imagen principal de Cloudinary.
    String? foto = _obtenerUrl(sitio['imagen']);

    // Si no existe, intenta obtener una imagen de la lista fotos.
    foto ??= _obtenerUrl(sitio['fotos']);

    return ReporteSitioAdmin(
      id: (json['_id'] ?? '').toString(),
      asunto: (json['asunto'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      estado: (json['estado'] ?? 'pendiente').toString(),
      tipoReporte: (json['tipoReporte'] ?? 'problema').toString(),
      respuestaAdmin: json['respuestaAdmin']?.toString(),
      sitioId: sitio.isNotEmpty
          ? (sitio['_id'] ?? '').toString()
          : (sitioJson ?? '').toString(),
      nombreSitio: (sitio['nombre'] ?? 'Sitio sin nombre').toString(),
      fotoSitio: foto,
      nombreCategoria:
          (categoria['nombre'] ?? 'Sin categoría').toString(),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      ),
      updatedAt: DateTime.tryParse(
        (json['updatedAt'] ?? '').toString(),
      ),
    );
  }

  static String? _obtenerUrl(dynamic valor) {
    if (valor is String && valor.trim().isNotEmpty) {
      return valor.trim();
    }

    if (valor is List) {
      for (final elemento in valor) {
        if (elemento is String && elemento.trim().isNotEmpty) {
          return elemento.trim();
        }
      }
    }

    return null;
  }

  String get estadoLegible {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_revision':
        return 'En revisión';
      case 'resuelto':
        return 'Resuelto';
      default:
        return estado;
    }
  }

  String get tipoLegible {
    switch (tipoReporte) {
      case 'problema':
        return 'Problema';
      case 'sugerencia':
        return 'Sugerencia';
      case 'mejora':
        return 'Mejora';
      case 'otro':
        return 'Otro';
      default:
        return tipoReporte;
    }
  }
}
