/// Notificación del usuario devuelta por GET /api/notificaciones.
///
/// Las de novedades (tipo 'actividad' o 'producto') traen el sitio
/// que publicó en `sitioOrigen` (poblado con su nombre) y el id de
/// la actividad o del producto. Las demás (reservas, generales)
/// solo se muestran.
class NotificacionUsuarioModel {
  final String id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool leida;
  final DateTime? fecha;

  final String? sitioId;
  final String? sitioNombre;
  final String? actividadId;
  final String? productoId;

  const NotificacionUsuarioModel({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.leida,
    this.fecha,
    this.sitioId,
    this.sitioNombre,
    this.actividadId,
    this.productoId,
  });

  /// True si al tocarla se puede abrir el detalle de un sitio.
  bool get abreSitio =>
      (tipo == 'actividad' || tipo == 'producto') && sitioId != null;

  factory NotificacionUsuarioModel.fromJson(Map<String, dynamic> json) {
    final sitio = json['sitioOrigen'];

    String? sitioId;
    String? sitioNombre;

    if (sitio is Map) {
      sitioId = _texto(sitio['_id'] ?? sitio['id']);
      sitioNombre = _texto(sitio['nombre']);
    } else {
      sitioId = _texto(sitio);
    }

    return NotificacionUsuarioModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      mensaje: (json['mensaje'] ?? '').toString(),
      tipo: (json['tipo'] ?? 'general').toString(),
      leida: json['leida'] == true,
      fecha: DateTime.tryParse((json['createdAt'] ?? '').toString()),
      sitioId: sitioId,
      sitioNombre: sitioNombre,
      actividadId: _texto(json['actividad']),
      productoId: _texto(json['producto']),
    );
  }

  NotificacionUsuarioModel copiarLeida() {
    return NotificacionUsuarioModel(
      id: id,
      titulo: titulo,
      mensaje: mensaje,
      tipo: tipo,
      leida: true,
      fecha: fecha,
      sitioId: sitioId,
      sitioNombre: sitioNombre,
      actividadId: actividadId,
      productoId: productoId,
    );
  }

  static String? _texto(dynamic valor) {
    final texto = valor?.toString().trim();

    if (texto == null || texto.isEmpty || texto == 'null') {
      return null;
    }

    return texto;
  }
}
