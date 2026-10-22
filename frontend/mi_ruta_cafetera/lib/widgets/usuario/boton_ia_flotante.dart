import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/usuario/chat_ia_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'icono_ia.dart';
import '../../l10n/textos.dart';

/// Botón flotante de café que abre el chat de Mi Ruta Cafetera IA.
///
/// Es la única implementación del acceso al chat: el contenedor
/// principal ([PublicShellScreen]) lo coloca sobre las 5 secciones
/// (Inicio, Mapa, Favoritos, Rutas y Perfil) cuando hay sesión.
/// El Inicio conserva además su tarjeta de IA.
///
/// La persona puede arrastrarlo a cualquier punto de la pantalla.
/// La posición se guarda como fracción del área disponible (por lo
/// que se adapta a distintos tamaños de pantalla) y se recuerda al
/// cambiar de sección y al reabrir la aplicación.
///
/// Debe colocarse ocupando toda el área donde puede moverse
/// (por ejemplo dentro de un `Positioned.fill`). Las zonas vacías
/// no interceptan toques, por lo que el contenido de abajo sigue
/// funcionando con normalidad.
class BotonIaFlotante extends StatefulWidget {
  /// Dónde aparece la primera vez, antes de que la persona lo mueva.
  final bool inicioIzquierda;

  const BotonIaFlotante({super.key, this.inicioIzquierda = false});

  static void abrirChat(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChatIaScreen()));
  }

  @override
  State<BotonIaFlotante> createState() => _BotonIaFlotanteState();
}

class _BotonIaFlotanteState extends State<BotonIaFlotante> {
  static const double _tamano = 56;

  static const double _margen = AppDimensions.spacingLg;

  static const String _claveX = 'boton_ia_posicion_x';
  static const String _claveY = 'boton_ia_posicion_y';

  // Posición recordada (0 a 1) mientras la app está abierta, para
  // que el botón no "salte" al cambiar de sección.
  static double? _fraccionX;
  static double? _fraccionY;

  @override
  void initState() {
    super.initState();

    if (_fraccionX == null || _fraccionY == null) {
      _restaurar();
    }
  }

  Future<void> _restaurar() async {
    try {
      final preferencias = await SharedPreferences.getInstance();

      final x = preferencias.getDouble(_claveX);
      final y = preferencias.getDouble(_claveY);

      if (x == null || y == null || !mounted) {
        return;
      }

      setState(() {
        _fraccionX = x.clamp(0.0, 1.0).toDouble();
        _fraccionY = y.clamp(0.0, 1.0).toDouble();
      });
    } catch (_) {
      // Sin preferencias el botón usa su posición inicial.
    }
  }

  Future<void> _guardar() async {
    final x = _fraccionX;
    final y = _fraccionY;

    if (x == null || y == null) {
      return;
    }

    try {
      final preferencias = await SharedPreferences.getInstance();

      await preferencias.setDouble(_claveX, x);
      await preferencias.setDouble(_claveY, y);
    } catch (_) {
      // Si no se puede guardar, la posición solo dura esta sesión.
    }
  }

  @override
  Widget build(BuildContext context) {
    final margenSuperior = MediaQuery.of(context).padding.top;

    return LayoutBuilder(
      builder: (context, restricciones) {
        final minX = _margen;
        final maxX = math.max(minX, restricciones.maxWidth - _tamano - _margen);

        final minY = margenSuperior + _margen;
        final maxY = math.max(
          minY,
          restricciones.maxHeight - _tamano - _margen,
        );

        final fraccionX = _fraccionX;
        final fraccionY = _fraccionY;

        final double x;
        final double y;

        if (fraccionX != null && fraccionY != null) {
          x = minX + fraccionX * (maxX - minX);
          y = minY + fraccionY * (maxY - minY);
        } else {
          x = widget.inicioIzquierda ? minX : maxX;
          y = maxY;
        }

        return Stack(
          children: [
            Positioned(
              left: x,
              top: y,
              child: GestureDetector(
                onPanUpdate: (detalle) {
                  final nuevoX = (x + detalle.delta.dx)
                      .clamp(minX, maxX)
                      .toDouble();
                  final nuevoY = (y + detalle.delta.dy)
                      .clamp(minY, maxY)
                      .toDouble();

                  setState(() {
                    _fraccionX = maxX > minX
                        ? (nuevoX - minX) / (maxX - minX)
                        : 0;
                    _fraccionY = maxY > minY
                        ? (nuevoY - minY) / (maxY - minY)
                        : 0;
                  });
                },
                onPanEnd: (_) => _guardar(),
                child: _construirBoton(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _construirBoton(BuildContext context) {
    return Tooltip(
      message: Textos.t('Mi Ruta Cafetera IA (mantén y arrastra para moverlo)'),
      child: Material(
        color: AppColors.secondary,
        elevation: AppDimensions.elevationHigh,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => BotonIaFlotante.abrirChat(context),
          child: const SizedBox(
            width: _tamano,
            height: _tamano,
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacingSm),
              child: IconoIa(
                size: _tamano - AppDimensions.spacingSm * 2,
                iconoRespaldo: Icons.coffee_rounded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
