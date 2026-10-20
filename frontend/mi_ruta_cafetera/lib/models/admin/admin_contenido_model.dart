
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
  });

  bool get estaPendiente =>
      estadoPublicacion == 'pendiente_revision';

  bool get estaAprobado => estadoPublicacion == 'aprobado';

  bool get estaRechazado => estadoPublicacion == 'rechazado';

  factory AdminContenidoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic sitio = json['sitio'];

    final Map<String, dynamic> sitioMap = sitio is Map
        ? Map<String, dynamic>.from(sitio)
        : <String, dynamic>{};

    final dynamic categoria = sitioMap['categoria'];

    final Map<String, dynamic> categoriaMap =
        categoria is Map
            ? Map<String, dynamic>.from(categoria)
            : <String, dynamic>{};

    final dynamic imagenesJson = json['imagenes'];

    final List<String> imagenes = imagenesJson is List
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

    final List<AdminAudioGuiaModel> audioGuias =
        audiosJson is List
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

    return AdminContenidoModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      imagenPrincipal:
          (json['imagenPrincipal'] ?? '').toString(),
      imagenes: imagenes,
      audioGuias: audioGuias,
      sitioId: (
        sitioMap['_id'] ??
        sitioMap['id'] ??
        (sitio is String ? sitio : '')
      ).toString(),
      sitioNombre: (sitioMap['nombre'] ?? '').toString(),
      sitioCategoriaIcono:
          (categoriaMap['icono'] ?? '').toString(),
      sitioCategoriaNombre:
          (categoriaMap['nombre'] ?? '').toString(),
      ciudad: (sitioMap['ciudad'] ?? '').toString(),
      departamento:
          (sitioMap['departamento'] ?? '').toString(),
      estadoPublicacion:
          (json['estadoPublicacion'] ?? 'pendiente_revision')
              .toString(),
      motivoRechazo:
          (json['motivoRechazo'] ?? '').toString(),
      activo: json['activo'] == true,
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      ),
    );
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
