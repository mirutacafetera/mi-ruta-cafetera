class ActividadAdminModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String estadoPublicacion;
  final String motivoRechazo;
  final String imagenPrincipal;
  final List<String> imagenes;
  final String sitioId;
  final String nombreSitio;
  final String ciudad;
  final String departamento;
  final dynamic precio;
  final String horario;
  final String duracion;
  final DateTime? fechaCreacion;
  final String? revisadoPor;
  final DateTime? revisadoAt;
  final EvaluacionActividadIA? evaluacionIA;

  const ActividadAdminModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estadoPublicacion,
    this.motivoRechazo = '',
    this.imagenPrincipal = '',
    this.imagenes = const [],
    this.sitioId = '',
    this.nombreSitio = '',
    this.ciudad = '',
    this.departamento = '',
    this.precio,
    this.horario = '',
    this.duracion = '',
    this.fechaCreacion,
    this.revisadoPor,
    this.revisadoAt,
    this.evaluacionIA,
  });

  factory ActividadAdminModel.fromJson(Map<String, dynamic> json) {
    final sitio = json['sitio'];
    final sitioJson = sitio is Map
        ? Map<String, dynamic>.from(sitio)
        : <String, dynamic>{};

    final listaImagenes = json['imagenes'];
    final evaluacion = json['evaluacionIA'];
    final revisado = json['revisadoPor'];

    return ActividadAdminModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      estadoPublicacion:
          (json['estadoPublicacion'] ?? 'borrador').toString(),
      motivoRechazo: (json['motivoRechazo'] ?? '').toString(),
      imagenPrincipal: (json['imagenPrincipal'] ?? '').toString(),
      imagenes: listaImagenes is List
          ? listaImagenes.whereType<String>().toList()
          : [],
      sitioId: sitio is Map
          ? (sitioJson['_id'] ?? sitioJson['id'] ?? '').toString()
          : (sitio ?? '').toString(),
      nombreSitio: (sitioJson['nombre'] ?? '').toString(),
      ciudad: (sitioJson['ciudad'] ?? '').toString(),
      departamento: (sitioJson['departamento'] ?? '').toString(),
      precio: json['precio'],
      horario: (json['horario'] ?? '').toString(),
      duracion: (json['duracion'] ?? '').toString(),
      fechaCreacion: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      ),
      revisadoPor: _idComoTexto(revisado),
      revisadoAt: DateTime.tryParse(
        (json['revisadoAt'] ?? '').toString(),
      ),
      evaluacionIA: evaluacion is Map
          ? EvaluacionActividadIA.fromJson(
              Map<String, dynamic>.from(evaluacion),
            )
          : null,
    );
  }

  static String? _idComoTexto(dynamic valor) {
    if (valor == null) return null;

    if (valor is Map) {
      final mapa = Map<String, dynamic>.from(valor);
      final id = mapa['_id'] ?? mapa['id'];
      return id?.toString();
    }

    final texto = valor.toString();
    return texto.isEmpty ? null : texto;
  }

  bool get revisado => revisadoPor != null;

  List<String> get todasLasImagenes {
    return [
      if (imagenPrincipal.trim().isNotEmpty) imagenPrincipal,
      ...imagenes.where(
        (imagen) =>
            imagen.trim().isNotEmpty &&
            imagen != imagenPrincipal,
      ),
    ];
  }
}

class EvaluacionActividadIA {
  final String decision;
  final String motivo;
  final List<String> criterios;
  final String modeloIA;
  final DateTime? fechaDecision;

  const EvaluacionActividadIA({
    required this.decision,
    required this.motivo,
    this.criterios = const [],
    this.modeloIA = '',
    this.fechaDecision,
  });

  factory EvaluacionActividadIA.fromJson(Map<String, dynamic> json) {
    final criteriosJson = json['criterios'];

    return EvaluacionActividadIA(
      decision: (json['decision'] ?? '').toString(),
      motivo: (json['motivo'] ?? '').toString(),
      criterios: criteriosJson is List
          ? criteriosJson.map((criterio) => criterio.toString()).toList()
          : [],
      modeloIA: (json['modeloIA'] ?? '').toString(),
      fechaDecision: DateTime.tryParse(
        (json['fechaDecision'] ?? '').toString(),
      ),
    );
  }
}