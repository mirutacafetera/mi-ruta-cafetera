
class MensajeChatbot {
  final String contenido;
  final bool esUsuario;
  final DateTime fecha;
  final bool esError;

  const MensajeChatbot({
    required this.contenido,
    required this.esUsuario,
    required this.fecha,
    this.esError = false,
  });

  factory MensajeChatbot.usuario(String contenido) {
    return MensajeChatbot(
      contenido: contenido,
      esUsuario: true,
      fecha: DateTime.now(),
    );
  }

  factory MensajeChatbot.asistente(String contenido) {
    return MensajeChatbot(
      contenido: contenido,
      esUsuario: false,
      fecha: DateTime.now(),
    );
  }

  factory MensajeChatbot.error(String contenido) {
    return MensajeChatbot(
      contenido: contenido,
      esUsuario: false,
      fecha: DateTime.now(),
      esError: true,
    );
  }

  factory MensajeChatbot.fromJson(Map<String, dynamic> json) {
    return MensajeChatbot(
      contenido: json['contenido']?.toString() ??
          json['mensaje']?.toString() ??
          json['respuesta']?.toString() ??
          '',
      esUsuario: json['esUsuario'] == true,
      fecha: DateTime.tryParse(
            json['fecha']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      esError: json['esError'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contenido': contenido,
      'esUsuario': esUsuario,
      'fecha': fecha.toIso8601String(),
      'esError': esError,
    };
  }
}
