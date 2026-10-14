
class ReservaAdminModel {
  final String id;
  final dynamic usuario;
  final dynamic sitio;
  final dynamic actividad;
  final DateTime fecha;
  final int cantidadPersonas;
  final double precioTotal;
  final String estado;
  final String observaciones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReservaAdminModel({
    required this.id,
    required this.usuario,
    required this.sitio,
    required this.actividad,
    required this.fecha,
    required this.cantidadPersonas,
    required this.precioTotal,
    required this.estado,
    required this.observaciones,
    this.createdAt,
    this.updatedAt,
  });

  factory ReservaAdminModel.fromJson(Map<String, dynamic> json) {
    return ReservaAdminModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      usuario: json['usuario'],
      sitio: json['sitio'],
      actividad: json['actividad'],
      fecha: DateTime.tryParse(
            (json['fecha'] ?? '').toString(),
          ) ??
          DateTime.now(),
      cantidadPersonas:
          (json['cantidadPersonas'] as num?)?.toInt() ?? 1,
      precioTotal:
          (json['precioTotal'] as num?)?.toDouble() ?? 0,
      estado: (json['estado'] ?? 'pendiente').toString(),
      observaciones: (json['observaciones'] ?? '').toString(),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      ),
      updatedAt: DateTime.tryParse(
        (json['updatedAt'] ?? '').toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario': usuario,
      'sitio': sitio,
      'actividad': actividad,
      'fecha': fecha.toIso8601String(),
      'cantidadPersonas': cantidadPersonas,
      'precioTotal': precioTotal,
      'estado': estado,
      'observaciones': observaciones,
    };
  }

  String get nombreUsuario => _obtenerNombre(usuario);

  String get nombreSitio => _obtenerNombre(sitio);

  String get nombreActividad => _obtenerNombre(actividad);

  static String _obtenerNombre(dynamic dato) {
    if (dato is Map) {
      return (dato['nombre'] ??
              dato['nombreCompleto'] ??
              dato['titulo'] ??
              dato['correo'] ??
              dato['_id'] ??
              dato['id'] ??
              'Sin información')
          .toString();
    }

    if (dato == null || dato.toString().isEmpty) {
      return 'Sin información';
    }

    return dato.toString();
  }
}
