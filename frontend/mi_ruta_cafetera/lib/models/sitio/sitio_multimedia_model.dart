
class SitioMultimediaModel {
  final String id;
  final String tipo;
  final String titulo;
  final String descripcion;
  final String url;
  final String idioma;
  final bool activo;
  final String origen;
  final String origenId;

  const SitioMultimediaModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.url,
    required this.idioma,
    required this.activo,
    this.origen = 'Multimedia',
    this.origenId = '',
  });

  factory SitioMultimediaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SitioMultimediaModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      tipo: json['tipo']?.toString() ?? 'imagen',
      titulo: json['titulo']?.toString() ?? '',
      descripcion:
          json['descripcion']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      idioma: json['idioma']?.toString() ?? 'es',
      activo: json['activo'] != false,
      origen: json['origen']?.toString() ?? 'Multimedia',
      origenId: json['origenId']?.toString() ?? '',
    );
  }
}
