
import '../../models/usuario/avatar_cafetero_model.dart';

class ReporteAdmin {
  final String id;
  final String asunto;
  final String mensaje;
  final String estado;
  final String? respuestaAdmin;
  final String? usuarioId;
  final String nombreUsuario;
  final String apellidoUsuario;
  final String correoUsuario;

  // Foto de perfil del usuario, incluida la de Google.
  final String? fotoPerfil;

  // Configuración del avatar cafetero personalizado.
  final AvatarCafeteroModel? avatar;

  // Datos del sitio que envía el reporte.
  final String? sitioId;
  final String nombreSitio;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReporteAdmin({
    required this.id,
    required this.asunto,
    required this.mensaje,
    required this.estado,
    this.respuestaAdmin,
    this.usuarioId,
    this.nombreUsuario = '',
    this.apellidoUsuario = '',
    this.correoUsuario = '',
    this.fotoPerfil,
    this.avatar,
    this.sitioId,
    this.nombreSitio = '',
    this.createdAt,
    this.updatedAt,
  });

  factory ReporteAdmin.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuarioId'];

    final usuarioMap = usuario is Map
        ? Map<String, dynamic>.from(usuario)
        : <String, dynamic>{};

    final sitio = json['sitioId'];

    final sitioMap = sitio is Map
        ? Map<String, dynamic>.from(sitio)
        : <String, dynamic>{};

    // Obtener la foto de perfil, por ejemplo, la de Google.
    final fotoJson = usuarioMap['fotoPerfil'];

    final String? fotoPerfil = fotoJson is String &&
            fotoJson.trim().isNotEmpty
        ? fotoJson.trim()
        : null;

    // Obtener la configuración del avatar personalizado.
    final avatarJson = usuarioMap['avatar'];

    final AvatarCafeteroModel? avatar = avatarJson is Map
        ? AvatarCafeteroModel.desdeDinamico(avatarJson)
        : null;

    return ReporteAdmin(
      id: (json['_id'] ?? '').toString(),
      asunto: (json['asunto'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      estado: (json['estado'] ?? 'pendiente').toString(),
      respuestaAdmin: json['respuestaAdmin']?.toString(),

      usuarioId: usuarioMap.isNotEmpty
          ? usuarioMap['_id']?.toString()
          : usuario?.toString(),

      nombreUsuario: (usuarioMap['nombre'] ?? '').toString(),
      apellidoUsuario: (usuarioMap['apellido'] ?? '').toString(),
      correoUsuario: (usuarioMap['correo'] ?? '').toString(),

      // Se conservan ambos datos simultáneamente.
      fotoPerfil: fotoPerfil,
      avatar: avatar,

      sitioId: sitioMap.isNotEmpty
          ? sitioMap['_id']?.toString()
          : sitio?.toString(),

      nombreSitio: (sitioMap['nombre'] ?? '').toString(),

      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      ),

      updatedAt: DateTime.tryParse(
        (json['updatedAt'] ?? '').toString(),
      ),
    );
  }

  String get nombreCompleto {
    final nombre = '$nombreUsuario $apellidoUsuario'.trim();

    return nombre.isNotEmpty
        ? nombre
        : 'Usuario no disponible';
  }
}
