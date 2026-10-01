class SitioSesionModel {
  final String token;

  final String id;
  final String sitioId;

  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;

  final String rol;
  final bool activo;

  SitioSesionModel({
    required this.token,
    required this.id,
    required this.sitioId,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.rol,
    required this.activo,
  });

  factory SitioSesionModel.fromJson(Map<String, dynamic> json) {
    final cuenta = json['cuenta'] ?? {};

    return SitioSesionModel(
      token: json['token']?.toString() ?? '',
      id: cuenta['id']?.toString() ?? '',
      sitioId: cuenta['sitioId']?.toString() ?? '',
      nombre: cuenta['nombre']?.toString() ?? '',
      apellido: cuenta['apellido']?.toString() ?? '',
      correo: cuenta['correo']?.toString() ?? '',
      telefono: cuenta['telefono']?.toString() ?? '',
      rol: cuenta['rol']?.toString() ?? '',
      activo: cuenta['activo'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'cuenta': {
        'id': id,
        'sitioId': sitioId,
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'telefono': telefono,
        'rol': rol,
        'activo': activo,
      },
    };
  }
}