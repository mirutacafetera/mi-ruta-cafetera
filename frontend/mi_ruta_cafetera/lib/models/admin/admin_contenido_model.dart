
class AdminContenidoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String imagenPrincipal;
  final List<String> imagenes;
  final List<AdminAudioGuiaModel> audioGuias;
  final String sitioId;
  final String sitioNombre;
  final String sitioCategoriaIcono;
  final String sitioCategoriaNombre;
  final String ciudad;
  final String departamento;
  final String estadoPublicacion;
  final String motivoRechazo;
  final bool activo;
  final DateTime? createdAt;

  // Evaluación de inteligencia artificial.
  final String? decisionIA;
  final String motivoIA;
  final List<String> criteriosIA;
  final String modeloIA;
  final DateTime? fechaDecisionIA;

  // Revisión manual del administrador.
  final String? nombreAdministrador;
  final DateTime? fechaRevisionManual;
  final bool tieneAdministradorRevisor;

  const AdminContenidoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.imagenPrincipal,
    required this.imagenes,
    required this.audioGuias,
    required this.sitioId,
    required this.sitioNombre,
    this.sitioCategoriaIcono = '',
    this.sitioCategoriaNombre = '',
    required this.ciudad,
    required this.departamento,
    required this.estadoPublicacion,
    required this.motivoRechazo,
    required this.activo,
    required this.createdAt,
    this.decisionIA,
    this.motivoIA = '',
    this.criteriosIA = const [],
    this.modeloIA = '',
    this.fechaDecisionIA,
    this.nombreAdministrador,
    this.fechaRevisionManual,
    this.tieneAdministradorRevisor = false,
  });

  bool get estaPendiente =>
      estadoPublicacion == 'pendiente_revision';

  bool get estaAprobado => estadoPublicacion == 'aprobado';

  bool get estaRechazado => estadoPublicacion == 'rechazado';

  bool get evaluacionIAExiste =>
      decisionIA != null &&
      ['aprobado', 'rechazado', 'pendiente_manual', 'error']
          .contains(decisionIA!.trim().toLowerCase());

  bool get tieneRevisionManual =>
      tieneAdministradorRevisor ||
      (nombreAdministrador?.trim().isNotEmpty ?? false);

  bool get aprobadoPorIA =>
      decisionIA?.trim().toLowerCase() == 'aprobado';

  bool get rechazadoPorIA =>
      decisionIA?.trim().toLowerCase() == 'rechazado';

  factory AdminContenidoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic sitioJson = json['sitio'];
    final dynamic evaluacionJson = json['evaluacionIA'];
    final dynamic revisadoPorJson = json['revisadoPor'];

    final sitio = sitioJson is Map
        ? Map<String, dynamic>.from(sitioJson)
        : <String, dynamic>{};

    final categoriaJson = sitio['categoria'];
    final categoria = categoriaJson is Map
        ? Map<String, dynamic>.from(categoriaJson)
        : <String, dynamic>{};

    final evaluacion = evaluacionJson is Map
        ? Map<String, dynamic>.from(evaluacionJson)
        : <String, dynamic>{};

    final administrador = revisadoPorJson is Map
        ? Map<String, dynamic>.from(revisadoPorJson)
        : <String, dynamic>{};

    final nombreAdmin = (
      administrador['nombre'] ??
      administrador['nombreCompleto'] ??
      administrador['correo']
    )?.toString().trim();

    final dynamic imagenesJson = json['imagenes'];
    final imagenes = imagenesJson is List
        ? imagenesJson
            .map((elemento) {
              if (elemento is Map) {
                return (
                  elemento['url'] ??
                  elemento['ruta'] ??
                  elemento['src'] ??
                  ''
                ).toString();
              }
              return elemento.toString();
            })
            .where((url) => url.trim().isNotEmpty)
            .toList()
        : <String>[];

    final dynamic audiosJson = json['audioGuias'];
    final audioGuias = audiosJson is List
        ? audiosJson
            .whereType<Map>()
            .map(
              (audio) => AdminAudioGuiaModel.fromJson(
                Map<String, dynamic>.from(audio),
              ),
            )
            .where((audio) => audio.url.isNotEmpty)
            .toList()
        : <AdminAudioGuiaModel>[];

    final dynamic criteriosJson = evaluacion['criterios'];

    final idAdministrador = revisadoPorJson is String
        ? revisadoPorJson.trim()
        : '';

    return AdminContenidoModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      imagenPrincipal: (json['imagenPrincipal'] ?? '').toString(),
      imagenes: imagenes,
      audioGuias: audioGuias,
      sitioId: (
        sitio['_id'] ??
        sitio['id'] ??
        (sitioJson is String ? sitioJson : '')
      ).toString(),
      sitioNombre: (sitio['nombre'] ?? '').toString(),
      sitioCategoriaIcono: (categoria['icono'] ?? '').toString(),
      sitioCategoriaNombre: (categoria['nombre'] ?? '').toString(),
      ciudad: (sitio['ciudad'] ?? '').toString(),
      departamento: (sitio['departamento'] ?? '').toString(),
      estadoPublicacion:
          (json['estadoPublicacion'] ?? 'pendiente_revision').toString(),
      motivoRechazo: (json['motivoRechazo'] ?? '').toString(),
      activo: json['activo'] == true,
      createdAt: _fecha(json['createdAt']),

      // Datos de IA.
      decisionIA: evaluacion['decision']?.toString(),
      motivoIA: (evaluacion['motivo'] ?? '').toString(),
      criteriosIA: criteriosJson is List
          ? criteriosJson.map((e) => e.toString()).toList()
          : <String>[],
      modeloIA: (evaluacion['modeloIA'] ?? '').toString(),
      fechaDecisionIA: _fecha(evaluacion['fechaDecision']),

      // Datos del administrador.
      nombreAdministrador:
          nombreAdmin != null && nombreAdmin.isNotEmpty
              ? nombreAdmin
              : null,
      fechaRevisionManual: _fecha(json['revisadoAt']),
      tieneAdministradorRevisor:
          idAdministrador.isNotEmpty ||
          (nombreAdmin?.isNotEmpty ?? false),
    );
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor == null || valor.toString().trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(valor.toString());
  }
}

class AdminAudioGuiaModel {
  final String titulo;
  final String descripcion;
  final String url;
  final String duracion;

  const AdminAudioGuiaModel({
    required this.titulo,
    required this.descripcion,
    required this.url,
    required this.duracion,
  });

  factory AdminAudioGuiaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminAudioGuiaModel(
      titulo: (json['titulo'] ?? 'Guía de audio').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      url: (json['url'] ?? '').toString().trim(),
      duracion: (json['duracion'] ?? '').toString(),
    );
  }
}
