
class UsuarioAdmin {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String ciudad;
  final String fotoPerfil;
  final bool activo;
  final bool correoVerificado;
  final DateTime? creadoEn;

  const UsuarioAdmin({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.ciudad,
    required this.fotoPerfil,
    required this.activo,
    required this.correoVerificado,
    this.creadoEn,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory UsuarioAdmin.fromJson(Map<String, dynamic> json) {
    return UsuarioAdmin(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      ciudad: json['ciudad']?.toString() ?? '',
      fotoPerfil: json['fotoPerfil']?.toString() ?? '',
      activo: json['activo'] == true,
      correoVerificado: json['correoVerificado'] == true,
      creadoEn: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'ciudad': ciudad,
      'fotoPerfil': fotoPerfil,
      'activo': activo,
      'correoVerificado': correoVerificado,
      'createdAt': creadoEn?.toIso8601String(),
    };
  }

  UsuarioAdmin copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? correo,
    String? telefono,
    String? ciudad,
    String? fotoPerfil,
    bool? activo,
    bool? correoVerificado,
    DateTime? creadoEn,
  }) {
    return UsuarioAdmin(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      ciudad: ciudad ?? this.ciudad,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      activo: activo ?? this.activo,
      correoVerificado: correoVerificado ?? this.correoVerificado,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}
