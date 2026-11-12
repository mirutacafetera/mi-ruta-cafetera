import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/textos.dart';
import '../../screens/usuario/notificaciones_usuario_screen.dart';
import '../../services/usuario/notificacion_usuario_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';

/// Campana con el contador de notificaciones sin leer.
///
/// Solo se muestra con sesión iniciada. Actualiza el contador al
/// aparecer, cada minuto y al volver de la lista.
class CampanaNotificaciones extends StatefulWidget {
  const CampanaNotificaciones({super.key});

  @override
  State<CampanaNotificaciones> createState() =>
      _CampanaNotificacionesState();
}

class _CampanaNotificacionesState extends State<CampanaNotificaciones> {
  final NotificacionUsuarioService _servicio =
      NotificacionUsuarioService.instance;

  Timer? _temporizador;

  @override
  void initState() {
    super.initState();

    UsuarioSesionService.instance.sesionActual.addListener(_sesionCambio);

    _servicio.actualizarContador();

    _temporizador = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _servicio.actualizarContador(),
    );
  }

  @override
  void dispose() {
    _temporizador?.cancel();

    UsuarioSesionService.instance.sesionActual.removeListener(_sesionCambio);

    super.dispose();
  }

  void _sesionCambio() {
    if (UsuarioSesionService.instance.sesionActual.value == null) {
      _servicio.limpiar();
    } else {
      _servicio.actualizarContador();
    }
  }

  Future<void> _abrir() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificacionesUsuarioScreen(),
      ),
    );

    _servicio.actualizarContador();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _servicio.noLeidas,
      builder: (context, total, _) {
        return IconButton(
          tooltip: Textos.t('Notificaciones'),
          onPressed: _abrir,
          icon: Badge.count(
            count: total,
            isLabelVisible: total > 0,
            child: const Icon(Icons.notifications_none_rounded),
          ),
        );
      },
    );
  }
}
