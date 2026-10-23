import '../usuario/avatar_cafetero_model.dart';

class ResenaAdmin {
  final String id;
  final String usuario;
  final String sitio;
  final String comentario;
  final int calificacion;
  final bool activo;
  final DateTime? fecha;
  final String? fotoPerfil;
  final AvatarCafeteroModel? avatar;

  const ResenaAdmin({
    required this.id,
    required this.usuario,
    required this.sitio,
    required this.comentario,
    required this.calificacion,
    required this.activo,
    this.fecha,
    this.fotoPerfil,
    this.avatar,
  });

  factory ResenaAdmin.fromJson(Map<String, dynamic> json) {
    final usuarioJson = json['usuario'];
    final sitioJson = json['sitio'];

    final usuarioMap = usuarioJson is Map
        ? Map<String, dynamic>.from(usuarioJson)
        : <String, dynamic>{};

    final sitioMap = sitioJson is Map
        ? Map<String, dynamic>.from(sitioJson)
        : <String, dynamic>{};

    final foto = usuarioMap['fotoPerfil']?.toString().trim();

    return ResenaAdmin(
      id: json['_id']?.toString() ?? '',
      usuario: usuarioJson is Map
          ? '${usuarioMap['nombre'] ?? ''} '
                  '${usuarioMap['apellido'] ?? ''}'
              .trim()
          : 'Usuario no disponible',
      sitio: sitioJson is Map
          ? sitioMap['nombre']?.toString() ?? 'Sitio desconocido'
          : 'Sitio desconocido',
      comentario: json['comentario']?.toString() ?? '',
      calificacion: json['calificacion'] is num
          ? (json['calificacion'] as num).toInt()
          : 0,
      activo: json['activo'] == true,
      fecha: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
      fotoPerfil: foto == null || foto.isEmpty ? null : foto,
      avatar: AvatarCafeteroModel.desdeDinamico(
        usuarioMap['avatar'],
      ),
    );
  }
}