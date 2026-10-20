import 'ia_recomendacion_model.dart';

/// Quién escribió un mensaje del chat.
enum ChatRol { usuario, asistente }

/// Un mensaje mostrado en el chat de Mi Ruta Cafetera IA.
class ChatMensaje {
  final ChatRol rol;
  final String texto;

  /// Sitios reales mencionados por el asistente (solo en
  /// mensajes del asistente).
  final List<IaRecomendacion> sitios;

  /// True cuando el mensaje es un aviso de error y no una
  /// respuesta de la IA (no se reenvía como historial).
  final bool esError;

  const ChatMensaje({
    required this.rol,
    required this.texto,
    this.sitios = const [],
    this.esError = false,
  });

  /// Formato que espera POST /api/chat en "historial".
  Map<String, String> toHistorialJson() {
    return {
      'rol': rol == ChatRol.usuario ? 'usuario' : 'asistente',
      'texto': texto,
    };
  }
}

/// Respuesta de POST /api/chat.
class ChatRespuesta {
  final String respuesta;
  final List<IaRecomendacion> sitios;
  final bool ubicacionUsada;

  const ChatRespuesta({
    required this.respuesta,
    required this.sitios,
    required this.ubicacionUsada,
  });

  factory ChatRespuesta.fromJson(Map<String, dynamic> json) {
    final sitios = json['sitios'];

    return ChatRespuesta(
      respuesta: (json['respuesta'] ?? '').toString(),
      // Cada elemento tiene la misma forma que las recomendaciones
      // de IA ({ sitio: {...} }), por lo que se reutiliza su modelo.
      sitios: sitios is List
          ? sitios
              .whereType<Map>()
              .map(
                (item) => IaRecomendacion.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
      ubicacionUsada: json['ubicacionUsada'] == true,
    );
  }
}
