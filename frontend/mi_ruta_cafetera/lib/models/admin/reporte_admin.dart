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
    this.createdAt,
    this.updatedAt,
  });

  factory ReporteAdmin.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuarioId'];

    return ReporteAdmin(
      id: (json['_id'] ?? '').toString(),
      asunto: (json['asunto'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      estado: (json['estado'] ?? 'pendiente').toString(),
      respuestaAdmin: json['respuestaAdmin']?.toString(),
      usuarioId: usuario is Map<String, dynamic>
          ? usuario['_id']?.toString()
          : usuario?.toString(),
      nombreUsuario: usuario is Map<String, dynamic>
          ? (usuario['nombre'] ?? '').toString()
          : '',
      apellidoUsuario: usuario is Map<String, dynamic>
          ? (usuario['apellido'] ?? '').toString()
          : '',
      correoUsuario: usuario is Map<String, dynamic>
          ? (usuario['correo'] ?? '').toString()
          : '',
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      ),
      updatedAt: DateTime.tryParse(
        (json['updatedAt'] ?? '').toString(),
      ),
    );
  }

  String get nombreCompleto {
    return '$nombreUsuario $apellidoUsuario'.trim();
  }
}