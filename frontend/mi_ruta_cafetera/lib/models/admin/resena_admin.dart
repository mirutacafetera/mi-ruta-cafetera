
class ResenaAdmin {
  final String id;
  final String usuario;
  final String sitio;
  final String comentario;
  final int calificacion;
  final bool activo;
  final DateTime? fecha;
  final String? fotoPerfil;

  const ResenaAdmin({
    required this.id,
    required this.usuario,
    required this.sitio,
    required this.comentario,
    required this.calificacion,
    required this.activo,
    this.fecha,
    this.fotoPerfil,
  });

  factory ResenaAdmin.fromJson(Map<String, dynamic> json) {
    final usuarioJson = json['usuario'];
    final sitioJson = json['sitio'];

    String? foto;

    if (usuarioJson is Map) {
      final avatar = usuarioJson['avatar'];

      foto = usuarioJson['fotoPerfil']?.toString();

      // El avatar cafetero es una configuración,
      // no necesariamente una URL de imagen.
      if (foto == null || foto.trim().isEmpty) {
        if (avatar is String && avatar.startsWith('http')) {
          foto = avatar;
        }
      }
    }

    return ResenaAdmin(
      id: json['_id']?.toString() ?? '',
      usuario: usuarioJson is Map
          ? '${usuarioJson['nombre'] ?? ''} ${usuarioJson['apellido'] ?? ''}'.trim()
          : 'Usuario no disponible',
      sitio: sitioJson is Map
          ? sitioJson['nombre']?.toString() ?? 'Sitio desconocido'
          : 'Sitio desconocido',
      comentario: json['comentario']?.toString() ?? '',
      calificacion: (json['calificacion'] as num?)?.toInt() ?? 0,
      activo: json['activo'] == true,
      fecha: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      fotoPerfil: foto?.trim().isNotEmpty == true ? foto : null,
    );
  }
}
