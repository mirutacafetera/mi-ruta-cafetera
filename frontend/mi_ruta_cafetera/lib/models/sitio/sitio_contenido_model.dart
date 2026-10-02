class SitioAudioGuiaModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String url;
  final String duracion;

  const SitioAudioGuiaModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.url,
    required this.duracion,
  });

  factory SitioAudioGuiaModel.fromJson(Map<String, dynamic> json) {
    return SitioAudioGuiaModel(
      id: json['_id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      duracion: json['duracion']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'url': url,
      'duracion': duracion,
    };
  }
}

class SitioContenidoModel {
  final String id;
  final String sitio;
  final String titulo;
  final String descripcion;
  final String imagenPrincipal;
  final List<String> imagenes;
  final List<SitioAudioGuiaModel> audioGuias;

  final String estadoPublicacion;
  final String motivoRechazo;
  final String revisadoPor;
  final DateTime? revisadoAt;

  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SitioContenidoModel({
    required this.id,
    required this.sitio,
    required this.titulo,
    required this.descripcion,
    required this.imagenPrincipal,
    required this.imagenes,
    required this.audioGuias,
    required this.estadoPublicacion,
    required this.motivoRechazo,
    required this.revisadoPor,
    required this.revisadoAt,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SitioContenidoModel.fromJson(Map<String, dynamic> json) {
    final audioGuiasJson = json['audioGuias'];

    return SitioContenidoModel(
      id: json['_id']?.toString() ?? '',
      sitio: json['sitio']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      imagenPrincipal: json['imagenPrincipal']?.toString() ?? '',
      imagenes: _convertirListaString(json['imagenes']),
      audioGuias: audioGuiasJson is List
          ? audioGuiasJson
              .whereType<Map>()
              .map(
                (item) => SitioAudioGuiaModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
      estadoPublicacion:
          json['estadoPublicacion']?.toString() ?? 'borrador',
      motivoRechazo: json['motivoRechazo']?.toString() ?? '',
      revisadoPor: json['revisadoPor']?.toString() ?? '',
      revisadoAt: _convertirFecha(json['revisadoAt']),
      activo: json['activo'] == true,
      createdAt: _convertirFecha(json['createdAt']),
      updatedAt: _convertirFecha(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'imagenPrincipal': imagenPrincipal,
      'imagenes': imagenes,
      'audioGuias': audioGuias.map((audio) => audio.toJson()).toList(),
    };
  }

  static List<String> _convertirListaString(dynamic valor) {
    if (valor is! List) {
      return [];
    }

    return valor
        .map((item) => item?.toString() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static DateTime? _convertirFecha(dynamic valor) {
    if (valor == null) {
      return null;
    }

    return DateTime.tryParse(valor.toString());
  }
}