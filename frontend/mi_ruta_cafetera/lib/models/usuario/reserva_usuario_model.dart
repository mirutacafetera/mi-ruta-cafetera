// ============================================================
// RESERVA DEL USUARIO
// ============================================================
//
// Representa una solicitud de reserva de una actividad vista desde
// la cuenta del usuario. Campos tomados de la respuesta real de
// GET /api/reservas (modelo Reserva del backend).
// ============================================================

class ReservaUsuarioModel {
  final String id;
  final String sitioId;
  final String nombreSitio;
  final String actividadId;
  final String nombreActividad;
  final DateTime? fecha;
  final int cantidadPersonas;
  final double precioUnitario;
  final double precioTotal;
  final String estado;
  final String observaciones;
  final String respuestaSitio;
  final DateTime? respondidaEn;
  final DateTime? creadaEn;

  const ReservaUsuarioModel({
    required this.id,
    required this.sitioId,
    required this.nombreSitio,
    required this.actividadId,
    required this.nombreActividad,
    required this.fecha,
    required this.cantidadPersonas,
    required this.precioUnitario,
    required this.precioTotal,
    required this.estado,
    required this.observaciones,
    required this.respuestaSitio,
    required this.respondidaEn,
    required this.creadaEn,
  });

  factory ReservaUsuarioModel.fromJson(Map<String, dynamic> json) {
    final sitio = _mapa(json['sitio']);
    final actividad = _mapa(json['actividad']);

    final nombreActividad = _texto(json['actividadNombre']).isNotEmpty
        ? _texto(json['actividadNombre'])
        : _texto(actividad['nombre']);

    return ReservaUsuarioModel(
      id: _texto(json['_id'] ?? json['id']),
      sitioId: _idDe(json['sitio']),
      nombreSitio: _texto(sitio['nombre']),
      actividadId: _idDe(json['actividad']),
      nombreActividad: nombreActividad,
      fecha: _fecha(json['fecha']),
      cantidadPersonas: _numero(json['cantidadPersonas']).toInt(),
      precioUnitario: _numero(json['precioUnitario']),
      precioTotal: _numero(json['precioTotal']),
      estado: _texto(json['estado'], defecto: 'pendiente').toLowerCase(),
      observaciones: _texto(json['observaciones']),
      respuestaSitio: _texto(json['respuestaSitio']),
      respondidaEn: _fecha(json['respondidaAt']),
      creadaEn: _fecha(json['createdAt']),
    );
  }

  bool get esPendiente => estado == 'pendiente';

  bool get esConfirmada => estado == 'confirmada';

  /// El usuario puede cancelar mientras esté pendiente o confirmada.
  bool get sePuedeCancelar => esPendiente || esConfirmada;

  String get estadoLegible => nombreEstado(estado);

  static String nombreEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmada':
        return 'Confirmada';
      case 'rechazada':
        return 'Rechazada';
      case 'cancelada':
        return 'Cancelada';
      case 'completada':
        return 'Completada';
      default:
        return estado;
    }
  }

  static Map<String, dynamic> _mapa(dynamic valor) {
    if (valor is Map<String, dynamic>) return valor;
    if (valor is Map) return Map<String, dynamic>.from(valor);
    return {};
  }

  static String _texto(dynamic valor, {String defecto = ''}) {
    if (valor == null) return defecto;
    return valor.toString();
  }

  static String _idDe(dynamic valor) {
    if (valor is Map) return _texto(valor['_id'] ?? valor['id']);
    return _texto(valor);
  }

  static double _numero(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }
}
