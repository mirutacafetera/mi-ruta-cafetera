class AdminActividadModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String horario;
  final String duracion;
  final bool activo;

  final String estadoPublicacion;
  final String motivoRechazo;

  final String sitioId;
  final String sitioNombre;
  final String ciudad;
  final String departamento;

  final String revisadoPor;
  final DateTime? revisadoAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminActividadModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.horario,
    required this.duracion,
    required this.activo,
    required this.estadoPublicacion,
    required this.motivoRechazo,
    required this.sitioId,
    required this.sitioNombre,
    required this.ciudad,
    required this.departamento,
    required this.revisadoPor,
    required this.revisadoAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminActividadModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final sitio = json['sitio'];

    final sitioMap = sitio is Map<String, dynamic>
        ? sitio
        : <String, dynamic>{};

    return AdminActividadModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion:
          json['descripcion']?.toString() ?? '',
      precio: _toDouble(json['precio']),
      horario: json['horario']?.toString() ?? '',
      duracion: json['duracion']?.toString() ?? '',
      activo: json['activo'] == true,
      estadoPublicacion:
          json['estadoPublicacion']?.toString() ??
              'borrador',
      motivoRechazo:
          json['motivoRechazo']?.toString() ?? '',
      sitioId:
          sitioMap['_id']?.toString() ??
              sitio?.toString() ??
              '',
      sitioNombre:
          sitioMap['nombre']?.toString() ?? '',
      ciudad:
          sitioMap['ciudad']?.toString() ?? '',
      departamento:
          sitioMap['departamento']?.toString() ??
              '',
      revisadoPor:
          json['revisadoPor']?.toString() ?? '',
      revisadoAt:
          _toDateTime(json['revisadoAt']),
      createdAt:
          _toDateTime(json['createdAt']),
      updatedAt:
          _toDateTime(json['updatedAt']),
    );
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

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}