import 'dart:async';
 
import 'package:flutter/material.dart';
 
import '../theme/app_colors.dart';
 
/// Avisos que siempre se muestran ENCIMA de todo (formularios,
/// diálogos y bottom sheets incluidos).
///
/// Un SnackBar normal queda detrás de los diálogos. Este aviso se
/// inserta en el Overlay raíz de la app, por eso siempre se ve.
///
/// Uso:
///   AvisosSitio.error(context, 'No se pudo guardar la actividad.');
///   AvisosSitio.exito(context, 'Actividad guardada correctamente.');
class AvisosSitio {
  AvisosSitio._();
 
  static OverlayEntry? _actual;
  static Timer? _temporizador;
  static Timer? _pendiente;
 
  static void error(BuildContext context, String mensaje) {
    _mostrar(
      context,
      mensaje,
      esError: true,
      duracion: const Duration(seconds: 8),
    );
  }
 
  static void exito(BuildContext context, String mensaje) {
    _mostrar(
      context,
      mensaje,
      esError: false,
      duracion: const Duration(seconds: 4),
    );
  }
 
  static void _mostrar(
    BuildContext context,
    String mensaje, {
    required bool esError,
    required Duration duracion,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
 
    if (overlay == null) return;
 
    _cerrar();
 
    // Pequeña espera: si justo después se abre un diálogo (por
    // ejemplo, el de error del formulario), el aviso se inserta
    // DESPUÉS y queda por encima de él y de su fondo oscuro.
    _pendiente = Timer(const Duration(milliseconds: 350), () {
      _pendiente = null;
 
      late final OverlayEntry entrada;
 
      entrada = OverlayEntry(
        builder: (_) => _AvisoFlotante(
          mensaje: mensaje,
          esError: esError,
          onCerrar: () {
            if (_actual == entrada) _cerrar();
          },
        ),
      );
 
      try {
        overlay.insert(entrada);
      } catch (_) {
        return;
      }
 
      _actual = entrada;
      _temporizador = Timer(duracion, _cerrar);
    });
  }
 
  static void _cerrar() {
    _pendiente?.cancel();
    _pendiente = null;
    _temporizador?.cancel();
    _temporizador = null;
 
    final entrada = _actual;
    _actual = null;
 
    try {
      entrada?.remove();
    } catch (_) {
      // El overlay ya no existe (por ejemplo, se cambió de pantalla).
    }
  }
}
 
class _AvisoFlotante extends StatelessWidget {
  const _AvisoFlotante({
    required this.mensaje,
    required this.esError,
    required this.onCerrar,
  });
 
  final String mensaje;
  final bool esError;
  final VoidCallback onCerrar;
 
  @override
  Widget build(BuildContext context) {
    final color = esError ? AppColors.sitioError : AppColors.sitioPrimary;
 
    return Positioned.fill(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Material(
                color: color,
                elevation: 12,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                  child: Row(
                    children: [
                      Icon(
                        esError
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mensaje,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: onCerrar,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}