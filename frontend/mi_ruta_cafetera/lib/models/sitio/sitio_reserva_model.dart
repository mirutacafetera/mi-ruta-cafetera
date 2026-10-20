class SitioReservaModel {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final String apellidoUsuario;
  final String correoUsuario;
  final String telefonoUsuario;
  final String sitioId;
  final String nombreSitio;
  final String actividadId;
  final String nombreActividad;
  final String descripcionActividad;
  final double precioActividad;
  final DateTime? fecha;
  final int cantidadPersonas;
  final double precioTotal;
  final String estado;
  final String observaciones;
  final DateTime? creadaEn;
  final String respuestaSitio;

  const SitioReservaModel({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.apellidoUsuario,
    required this.correoUsuario,
    required this.telefonoUsuario,
    required this.sitioId,
    required this.nombreSitio,
    required this.actividadId,
    required this.nombreActividad,
    required this.descripcionActividad,
    required this.precioActividad,
    required this.fecha,
    required this.cantidadPersonas,
    required this.precioTotal,
    required this.estado,
    required this.observaciones,
    required this.creadaEn,
    this.respuestaSitio = '',
  });

  factory SitioReservaModel.fromJson(Map<String, dynamic> json) {
    final usuario = _mapa(json['usuario']);
    final sitio = _mapa(json['sitio']);
    final actividad = _mapa(json['actividad']);

    return SitioReservaModel(
      id: _texto(json['_id']),
      usuarioId: _idDe(json['usuario']),
      nombreUsuario: _texto(usuario['nombre']),
      apellidoUsuario: _texto(usuario['apellido']),
      correoUsuario: _texto(usuario['correo']),
      telefonoUsuario: _texto(usuario['telefono']),
      sitioId: _idDe(json['sitio']),
      nombreSitio: _texto(sitio['nombre']),
      actividadId: _idDe(json['actividad']),
      nombreActividad: _texto(json['actividadNombre']).isNotEmpty
          ? _texto(json['actividadNombre'])
          : _texto(actividad['nombre']),
      descripcionActividad: _texto(actividad['descripcion']),
      precioActividad: _numero(actividad['precio']),
      fecha: _fecha(json['fecha']),
      cantidadPersonas: _numero(json['cantidadPersonas']).toInt(),
      precioTotal: _numero(json['precioTotal']),
      estado: _texto(json['estado'], defecto: 'pendiente'),
      observaciones: _texto(json['observaciones']),
      creadaEn: _fecha(json['createdAt']),
      respuestaSitio: _texto(json['respuestaSitio']),
    );
  }

  static Map<String, dynamic> _mapa(dynamic valor) {
    if (valor is Map<String, dynamic>) return valor;

    if (valor is Map) {
      return Map<String, dynamic>.from(valor);
    }

    return {};
  }

  static String _texto(dynamic valor, {String defecto = ''}) {
    if (valor == null) return defecto;
    return valor.toString();
  }

  static String _idDe(dynamic valor) {
    if (valor is Map) {
      return _texto(valor['_id'] ?? valor['id']);
    }

    return _texto(valor);
  }

  static double _numero(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor == null) return null;
    if (valor is DateTime) return valor;

    return DateTime.tryParse(valor.toString());
  }
}
