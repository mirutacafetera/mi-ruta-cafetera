class AdminContenidoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String imagenPrincipal;
  final List<String> imagenes;
  final List<AdminAudioGuiaModel> audioGuias;
  final String sitioId;
  final String sitioNombre;
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
    required this.ciudad,
    required this.departamento,
    required this.estadoPublicacion,
    required this.motivoRechazo,
    required this.activo,
    required this.createdAt,
  });

  factory AdminContenidoModel.fromJson(Map<String, dynamic> json) {
    final sitio = json['sitio'];
    final sitioMap = sitio is Map
        ? Map<String, dynamic>.from(sitio)
        : <String, dynamic>{};

    final imagenesJson = json['imagenes'];
    final imagenes = imagenesJson is List
        ? imagenesJson
              .map((e) {
                if (e is Map) {
                  return (e['url'] ?? e['ruta'] ?? e['src'] ?? '').toString();
                }
                return e.toString();
              })
              .where((e) => e.trim().isNotEmpty)
              .toList()
        : <String>[];

    final audiosJson = json['audioGuias'];
    final audioGuias = audiosJson is List
        ? audiosJson
              .whereType<Map>()
              .map(
                (e) =>
                    AdminAudioGuiaModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .where((audio) => audio.url.isNotEmpty)
              .toList()
        : <AdminAudioGuiaModel>[];

    return AdminContenidoModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      imagenPrincipal: (json['imagenPrincipal'] ?? '').toString(),
      imagenes: imagenes,
      audioGuias: audioGuias,
      sitioId: (sitioMap['_id'] ?? sitio ?? '').toString(),
      sitioNombre: (sitioMap['nombre'] ?? '').toString(),
      ciudad: (sitioMap['ciudad'] ?? '').toString(),
      departamento: (sitioMap['departamento'] ?? '').toString(),
      estadoPublicacion: (json['estadoPublicacion'] ?? 'borrador').toString(),
      motivoRechazo: (json['motivoRechazo'] ?? '').toString(),
      activo: json['activo'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
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

  factory AdminAudioGuiaModel.fromJson(Map<String, dynamic> json) {
    return AdminAudioGuiaModel(
      titulo: (json['titulo'] ?? 'Guía de audio').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      url: (json['url'] ?? '').toString().trim(),
      duracion: (json['duracion'] ?? '').toString(),
    );
  }
}
