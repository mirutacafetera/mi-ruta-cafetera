
class AdminProductoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String imagenPrincipal;
  final List<String> imagenes;
  final bool activo;
  final String estadoPublicacion;
  final String motivoRechazo;
  final String sitioNombre;
  final String ciudad;
  final String departamento;
  final DateTime? createdAt;

  // Evaluación de IA.
  final String? decisionIA;
  final String motivoIA;
  final List<String> criteriosIA;
  final String modeloIA;
  final DateTime? fechaDecisionIA;

  // Revisión del administrador.
  final String? nombreAdministrador;
  final String? administradorId;
  final DateTime? fechaRevisionManual;

  const AdminProductoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.imagenPrincipal,
    required this.imagenes,
    required this.activo,
    required this.estadoPublicacion,
    required this.motivoRechazo,
    required this.sitioNombre,
    required this.ciudad,
    required this.departamento,
    required this.createdAt,
    this.decisionIA,
    this.motivoIA = '',
    this.criteriosIA = const [],
    this.modeloIA = '',
    this.fechaDecisionIA,
    this.nombreAdministrador,
    this.administradorId,
    this.fechaRevisionManual,
  });

  factory AdminProductoModel.fromJson(Map<String, dynamic> json) {
    final sitioJson = json['sitio'];
    final evaluacionJson = json['evaluacionIA'];
    final revisadoPorJson = json['revisadoPor'];

    final sitio = sitioJson is Map
        ? Map<String, dynamic>.from(sitioJson)
        : <String, dynamic>{};

    final evaluacion = evaluacionJson is Map
        ? Map<String, dynamic>.from(evaluacionJson)
        : <String, dynamic>{};

    final administrador = revisadoPorJson is Map
        ? Map<String, dynamic>.from(revisadoPorJson)
        : <String, dynamic>{};

    final idAdmin = revisadoPorJson is Map
        ? (revisadoPorJson['_id'] ?? revisadoPorJson['id'])?.toString()
        : revisadoPorJson?.toString();

    final nombreAdmin = administrador['nombre'] ??
        administrador['nombreCompleto'] ??
        administrador['correo'];

    final criterios = evaluacion['criterios'];

    return AdminProductoModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      precio: _parsePrecio(json['precio']),
      categoria: (json['categoria'] ?? '').toString(),
      imagenPrincipal: (json['imagenPrincipal'] ?? '').toString(),
      imagenes: json['imagenes'] is List
          ? (json['imagenes'] as List)
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList()
          : [],
      activo: json['activo'] is bool ? json['activo'] as bool : true,
      estadoPublicacion:
          (json['estadoPublicacion'] ?? 'borrador').toString(),
      motivoRechazo: (json['motivoRechazo'] ?? '').toString(),
      sitioNombre: (sitio['nombre'] ?? 'Sitio turístico').toString(),
      ciudad: (sitio['ciudad'] ?? '').toString(),
      departamento: (sitio['departamento'] ?? '').toString(),
      createdAt: _parseFecha(json['createdAt']),

      // Evaluación de IA.
      decisionIA: evaluacion['decision']?.toString(),
      motivoIA: (evaluacion['motivo'] ?? '').toString(),
      criteriosIA: criterios is List
          ? criterios.map((e) => e.toString()).toList()
          : [],
      modeloIA: (evaluacion['modeloIA'] ?? '').toString(),
      fechaDecisionIA: _parseFecha(evaluacion['fechaDecision']),

      // Revisión manual.
      nombreAdministrador: nombreAdmin?.toString(),
      administradorId: idAdmin,
      fechaRevisionManual: _parseFecha(json['revisadoAt']),
    );
  }

  static double _parsePrecio(dynamic valor) =>
      valor is num
          ? valor.toDouble()
          : double.tryParse(valor?.toString() ?? '') ?? 0.0;

  static DateTime? _parseFecha(dynamic valor) =>
      valor == null || valor.toString().isEmpty
          ? null
          : DateTime.tryParse(valor.toString());

  bool get estaPendiente =>
      estadoPublicacion == 'pendiente_revision';

  bool get estaAprobado => estadoPublicacion == 'aprobado';

  bool get estaRechazado => estadoPublicacion == 'rechazado';

  bool get evaluacionIAExiste =>
      decisionIA != null && decisionIA!.isNotEmpty;

  bool get aprobadoPorIA => decisionIA == 'aprobado';

  bool get rechazadoPorIA => decisionIA == 'rechazado';

  bool get pendienteIA => decisionIA == 'pendiente_manual';

  // Solo considera revisión manual cuando existe evidencia
  // de un administrador identificado o una fecha de revisión.
  bool get tieneRevisionManual =>
      (administradorId?.isNotEmpty ?? false) &&
      (fechaRevisionManual != null ||
          (nombreAdministrador?.trim().isNotEmpty ?? false));

  String get estadoLegible {
    switch (estadoPublicacion) {
      case 'pendiente_revision':
        return 'Pendiente de revisión';
      case 'aprobado':
        return 'Aprobado';
      case 'rechazado':
        return 'Rechazado';
      case 'borrador':
        return 'Borrador';
      default:
        return 'Desconocido';
    }
  }

  String get decisionIALegible {
    switch (decisionIA) {
      case 'aprobado':
        return 'Aprobado por IA';
      case 'rechazado':
        return 'Rechazado por IA';
      case 'pendiente_manual':
        return 'Pendiente de revisión manual';
      case 'error':
        return 'Error en la revisión de IA';
      default:
        return 'Sin evaluación de IA';
    }
  }
}
