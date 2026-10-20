
import 'package:flutter/foundation.dart';

import '../../../models/admin/mensaje_chatbot.dart';
import '../../../services/admin/admin_servicio_autenticacion.dart';
import '../../../services/admin/chatbot/chatbot.dart';

class ChatbotControlador extends ChangeNotifier {
  final List<MensajeChatbot> _mensajes = [];

  bool _cargando = false;
  String? _error;

  List<MensajeChatbot> get mensajes =>
      List.unmodifiable(_mensajes);

  bool get cargando => _cargando;

  String? get error => _error;

  Future<void> enviarMensaje(String texto) async {
    final mensaje = texto.trim();

    if (mensaje.isEmpty || _cargando) return;

    _mensajes.add(
      MensajeChatbot.usuario(mensaje),
    );

    _cargando = true;
    _error = null;

    notifyListeners();

    try {
      // Recuperar el token guardado del administrador.
      var token = AdminServicioAutenticacion.tokenAdmin;

      if (token == null || token.trim().isEmpty) {
        await AdminServicioAutenticacion.cargarToken();

        token = AdminServicioAutenticacion.tokenAdmin;
      }

      // Verificar que exista un token.
      if (token == null || token.trim().isEmpty) {
        throw Exception(
          'No se encontró el token del administrador. '
          'Inicia sesión nuevamente.',
        );
      }

      debugPrint(
        'CHATBOT ADMIN: token disponible: '
        '${token.trim().isNotEmpty}',
      );

      // Enviar el mensaje al chatbot administrativo.
      final respuesta = await ChatbotServicio.enviarMensaje(
        mensaje: mensaje,
        token: token,
      );

      _mensajes.add(respuesta);
    } catch (e) {
      _error = e.toString().replaceFirst(
            'Exception: ',
            '',
          );

      _mensajes.add(
        MensajeChatbot.error(_error!),
      );
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void limpiarConversacion() {
    if (_cargando) return;

    _mensajes.clear();
    _error = null;

    notifyListeners();
  }
}
