class SitioMultimediaModel {
  final String id;
  final String tipo;
  final String titulo;
  final String descripcion;
  final String url;
  final String idioma;
  final bool activo;

  const SitioMultimediaModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.url,
    required this.idioma,
    required this.activo,
  });

  factory SitioMultimediaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SitioMultimediaModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      tipo: json['tipo']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion:
          json['descripcion']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      idioma: json['idioma']?.toString() ?? 'es',
      activo: json['activo'] == true,
    );
  }
}