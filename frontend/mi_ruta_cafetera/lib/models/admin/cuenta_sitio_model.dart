class CuentaSitioModel {
  final String id;
  final String sitioId;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final bool activo;

  const CuentaSitioModel({
    required this.id,
    required this.sitioId,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.activo,
  });

  factory CuentaSitioModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final cuenta = json['cuenta'] is Map
        ? Map<String, dynamic>.from(json['cuenta'])
        : json;

    final sitio = cuenta['sitioId'];

    return CuentaSitioModel(
      id: _texto(cuenta['_id'] ?? cuenta['id']),
      sitioId: sitio is Map
          ? _texto(sitio['_id'] ?? sitio['id'])
          : _texto(sitio),
      nombre: _texto(cuenta['nombre']),
      apellido: _texto(cuenta['apellido']),
      correo: _texto(cuenta['correo']),
      telefono: _texto(cuenta['telefono']),
      activo: _booleano(cuenta['activo']),
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
      'activo': activo,
    };
  }

  String get nombreCompleto => '$nombre $apellido'.trim();

  static String _texto(dynamic valor) {
    if (valor == null) return '';

    if (valor is Map) {
      return (
        valor['_id'] ??
        valor['id'] ??
        valor[r'$oid'] ??
        ''
      ).toString();
    }

    return valor.toString().trim();
  }

  static bool _booleano(dynamic valor) {
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;

    if (valor is String) {
      return valor.toLowerCase().trim() == 'true';
    }

    return false;
  }

  @override
  String toString() {
    return 'CuentaSitioModel(id: $id, sitioId: $sitioId, correo: $correo)';
  }
}