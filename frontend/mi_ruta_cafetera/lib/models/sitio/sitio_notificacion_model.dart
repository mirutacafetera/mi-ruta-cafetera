// ============================================================
// NOTIFICACIÓN DEL ESTABLECIMIENTO
// ============================================================
//
// Campos del modelo Notificacion del backend: titulo, mensaje,
// tipo ('reserva_nueva', 'reserva_cancelada', ...), leida, reserva.
// ============================================================

class SitioNotificacionModel {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool leida;
  final String reservaId;
  final DateTime? creadaEn;

  const SitioNotificacionModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.leida,
    required this.reservaId,
    required this.creadaEn,
  });

  factory SitioNotificacionModel.fromJson(Map<String, dynamic> json) {
    final reserva = json['reserva'];

    return SitioNotificacionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      tipo: (json['tipo'] ?? 'general').toString(),
      leida: json['leida'] == true,
      reservaId: reserva is Map
          ? (reserva['_id'] ?? reserva['id'] ?? '').toString()
          : (reserva ?? '').toString(),
      creadaEn: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
