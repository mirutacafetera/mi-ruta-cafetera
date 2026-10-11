
class CuentaSitioModel {
  final String id;
  final String sitioId;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String rol;
  final bool activo;

  const CuentaSitioModel({
    required this.id,
    required this.sitioId,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.rol,
    required this.activo,
  });

  factory CuentaSitioModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final cuenta = json['cuenta'] is Map
        ? Map<String, dynamic>.from(
            json['cuenta'] as Map,
          )
        : json;

    return CuentaSitioModel(
      id: (cuenta['id'] ?? cuenta['_id'] ?? '').toString(),
      sitioId: (cuenta['sitioId'] ?? '').toString(),
      nombre: (cuenta['nombre'] ?? '').toString(),
      apellido: (cuenta['apellido'] ?? '').toString(),
      correo: (cuenta['correo'] ?? '').toString(),
      telefono: (cuenta['telefono'] ?? '').toString(),
      rol: (cuenta['rol'] ?? '').toString(),
      activo: cuenta['activo'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sitioId': sitioId,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'rol': rol,
      'activo': activo,
    };
  }

  @override
  String toString() {
    return 'CuentaSitioModel(id: $id, nombre: $nombre, correo: $correo)';
  }
}
