class AudioGuiaModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String url;
  final String duracion;

  const AudioGuiaModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.url,
    required this.duracion,
  });

  factory AudioGuiaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AudioGuiaModel(
      id: _stringValue(
        json['_id'] ?? json['id'],
      ),
      titulo: _stringValue(
        json['titulo'],
      ),
      descripcion: _stringValue(
        json['descripcion'],
      ),
      url: _stringValue(
        json['url'],
      ),
      duracion: _stringValue(
        json['duracion'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'url': url,
      'duracion': duracion,
    };
  }

  static String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final texto = value.toString().trim();

    return texto.isEmpty ? fallback : texto;
  }
}

class ContenidoModel {
  final String id;
  final String sitioId;
  final String titulo;
  final String descripcion;
  final String imagenPrincipal;
  final List<String> imagenes;
  final List<AudioGuiaModel> audioGuias;
  final String estadoPublicacion;
  final String motivoRechazo;
  final String? revisadoPor;
  final DateTime? revisadoAt;
  final bool activo;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;

  const ContenidoModel({
    required this.id,
    required this.sitioId,
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
    required this.creadoEn,
    required this.actualizadoEn,
  });

  bool get tieneImagenPrincipal =>
      imagenPrincipal.trim().isNotEmpty;

  bool get tieneImagenes =>
      imagenes.isNotEmpty;

  bool get tieneAudio =>
      audioGuias.isNotEmpty;

  factory ContenidoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final sitioJson = json['sitio'];

    final sitioId = sitioJson is Map
        ? _stringValue(
            sitioJson['_id'] ??
                sitioJson['id'],
          )
        : _stringValue(
            sitioJson,
          );

    final imagenesJson =
        json['imagenes'];

    final imagenes =
        imagenesJson is List
            ? imagenesJson
                .map(
                  (item) =>
                      _stringValue(item),
                )
                .where(
                  (imagen) =>
                      imagen.isNotEmpty,
                )
                .toList()
            : <String>[];

    final audioJson =
        json['audioGuias'];

    final audioGuias =
        audioJson is List
            ? audioJson
                .whereType<Map>()
                .map(
                  (item) =>
                      AudioGuiaModel.fromJson(
                    Map<String, dynamic>.from(
                      item,
                    ),
                  ),
                )
                .toList()
            : <AudioGuiaModel>[];

    return ContenidoModel(
      id: _stringValue(
        json['_id'] ?? json['id'],
      ),
      sitioId: sitioId,
      titulo: _stringValue(
        json['titulo'],
        fallback: 'Experiencia turística',
      ),
      descripcion: _stringValue(
        json['descripcion'],
      ),
      imagenPrincipal: _stringValue(
        json['imagenPrincipal'],
      ),
      imagenes: imagenes,
      audioGuias: audioGuias,
      estadoPublicacion: _stringValue(
        json['estadoPublicacion'],
        fallback: 'borrador',
      ),
      motivoRechazo: _stringValue(
        json['motivoRechazo'],
      ),
      revisadoPor:
          json['revisadoPor'] == null
              ? null
              : _stringValue(
                  json['revisadoPor'] is Map
                      ? json['revisadoPor']['_id'] ??
                          json['revisadoPor']['id']
                      : json['revisadoPor'],
                ),
      revisadoAt: _dateTimeValue(
        json['revisadoAt'],
      ),
      activo: _boolValue(
        json['activo'],
        fallback: true,
      ),
      creadoEn: _dateTimeValue(
        json['createdAt'] ??
            json['creadoEn'],
      ),
      actualizadoEn: _dateTimeValue(
        json['updatedAt'] ??
            json['actualizadoEn'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sitioId': sitioId,
      'titulo': titulo,
      'descripcion': descripcion,
      'imagenPrincipal': imagenPrincipal,
      'imagenes': imagenes,
      'audioGuias': audioGuias
          .map(
            (audio) => audio.toJson(),
          )
          .toList(),
      'estadoPublicacion':
          estadoPublicacion,
      'motivoRechazo':
          motivoRechazo,
      'revisadoPor':
          revisadoPor,
      'revisadoAt':
          revisadoAt?.toIso8601String(),
      'activo': activo,
      'creadoEn':
          creadoEn?.toIso8601String(),
      'actualizadoEn':
          actualizadoEn?.toIso8601String(),
    };
  }

  static String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final texto = value.toString().trim();

    return texto.isEmpty ? fallback : texto;
  }

  static bool _boolValue(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      final texto = value
          .trim()
          .toLowerCase();

      if (texto == 'true') {
        return true;
      }

      if (texto == 'false') {
        return false;
      }
    }

    return fallback;
  }

  static DateTime? _dateTimeValue(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}