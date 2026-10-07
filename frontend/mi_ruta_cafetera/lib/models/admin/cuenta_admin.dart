class CuentaAdmin {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final bool activo;
  final bool isVerified;
  final String rol;

  const CuentaAdmin({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.activo,
    required this.isVerified,
    required this.rol,
  });

  factory CuentaAdmin.fromJson(Map<String, dynamic> json) {
    return CuentaAdmin(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      activo: json['activo'] == true,
      isVerified: json['isVerified'] == true,
      rol: json['rol']?.toString() ?? 'admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'activo': activo,
      'isVerified': isVerified,
      'rol': rol,
    };
  }

  CuentaAdmin copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? correo,
    String? telefono,
    bool? activo,
    bool? isVerified,
    String? rol,
  }) {
    return CuentaAdmin(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      activo: activo ?? this.activo,
      isVerified: isVerified ?? this.isVerified,
      rol: rol ?? this.rol,
    );
  }
}