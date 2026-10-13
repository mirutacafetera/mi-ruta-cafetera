
class SitioResenaModel {
  final String id;
  final String sitioId;
  final String usuarioId;
  final String nombreUsuario;
  final String comentario;
  final int calificacion;
  final bool activo;
  final DateTime? creadaEn;
  final String? fotoPerfil;

  const SitioResenaModel({
    required this.id,
    required this.sitioId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.comentario,
    required this.calificacion,
    this.activo = true,
    this.creadaEn,
    this.fotoPerfil,
  });

  factory SitioResenaModel.fromJson(Map<String, dynamic> json) {
    final usuarioRaw = json['usuario'];
    final sitioRaw = json['sitio'];

    final Map<String, dynamic> usuario = usuarioRaw is Map
        ? Map<String, dynamic>.from(usuarioRaw)
        : <String, dynamic>{};

    final fechaRaw = json['createdAt'];

    final nombre = [
      usuario['nombre'],
      usuario['apellido'],
    ]
        .where(
          (parte) =>
              parte != null &&
              parte.toString().trim().isNotEmpty,
        )
        .join(' ')
        .trim();

    // La API devuelve la fotografía dentro de usuario.fotoPerfil.
    final fotoRaw = usuario['fotoPerfil'];
    final foto = fotoRaw?.toString().trim();

    return SitioResenaModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      sitioId: _idDe(sitioRaw ?? json['sitioId']),
      usuarioId: _idDe(usuarioRaw ?? json['usuarioId']),
      nombreUsuario: nombre.isNotEmpty ? nombre : 'Visitante',
      comentario: (json['comentario'] ?? '').toString(),
      calificacion: _leerCalificacion(json['calificacion']),
      activo: json['activo'] != false,
      creadaEn: fechaRaw == null
          ? null
          : DateTime.tryParse(fechaRaw.toString()),
      fotoPerfil: foto == null || foto.isEmpty ? null : foto,
    );
  }

  static String _idDe(dynamic valor) {
    if (valor is Map) {
      return (valor['_id'] ?? valor['id'] ?? '').toString();
    }

    return valor?.toString() ?? '';
  }

  static int _leerCalificacion(dynamic valor) {
    final numero =
        valor is num ? valor.toInt() : int.tryParse('$valor') ?? 0;

    return numero.clamp(0, 5);
  }

  Map<String, dynamic> toJson() {
    return {
      'sitio': sitioId,
      'comentario': comentario,
      'calificacion': calificacion,
    };
  }
}
