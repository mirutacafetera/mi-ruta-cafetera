class SitioActividadModel {
  final String id;
  final String sitio;
  final String nombre;
  final String descripcion;
  final double precio;
  final String horario;
  final String duracion;
  final String imagenPrincipal;
  final List<String> imagenes;
  final bool activo;
  final String estadoPublicacion;
  final String motivoRechazo;
  final String revisadoPor;
  final DateTime? revisadoAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SitioActividadModel({
    required this.id,
    required this.sitio,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.horario,
    required this.duracion,
    required this.imagenPrincipal,
    required this.imagenes,
    required this.activo,
    required this.estadoPublicacion,
    required this.motivoRechazo,
    required this.revisadoPor,
    this.revisadoAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SitioActividadModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SitioActividadModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      sitio: json['sitio']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      precio: _toDouble(json['precio']),
      horario: json['horario']?.toString() ?? '',
      duracion: json['duracion']?.toString() ?? '',
      imagenPrincipal:
          json['imagenPrincipal']?.toString() ?? '',
      imagenes: _toStringList(json['imagenes']),
      activo: json['activo'] == true,
      estadoPublicacion:
          json['estadoPublicacion']?.toString() ??
              'borrador',
      motivoRechazo:
          json['motivoRechazo']?.toString() ?? '',
      revisadoPor:
          json['revisadoPor']?.toString() ?? '',
      revisadoAt: _toDateTime(json['revisadoAt']),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'horario': horario,
      'duracion': duracion,
      'imagenPrincipal': imagenPrincipal,
      'imagenes': imagenes,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is! List) {
      return [];
    }

    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }
}