import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

/// Escenario visual de los accesos de Mi Ruta Cafetera.
///
/// Reúne en un solo lugar el diseño del login de usuario para que los
/// accesos de sitio turístico y de administrador se vean igual:
/// fotografía de fondo difuminada, capa verde oscuro translúcida y
/// tarjeta beige con efecto de cristal esmerilado, con el logo, el
/// nombre de la app y la frase de bienvenida.
///
/// Cada pantalla solo aporta su [titulo] (por ejemplo "Acceso de
/// administrador"), una [descripcion] opcional y su contenido
/// ([children]), que se muestra dentro de la tarjeta.
class EscenarioLogin extends StatelessWidget {
  static const String _assetFondo = 'assets/img/fondo-i-sesion.png';
  static const String _assetLogo = 'assets/img/iconoia.png';

  final String titulo;
  final String? descripcion;
  final List<Widget> children;

  const EscenarioLogin({
    super.key,
    required this.titulo,
    required this.children,
    this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    // El fondo ocupa siempre la pantalla completa (no se encoge ni se
    // reescala cuando aparece el teclado).
    final altoPantalla = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: altoPantalla,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                  child: Image.asset(
                    _assetFondo,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) {
                      return const ColoredBox(color: AppColors.primaryDark);
                    },
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryDark.withValues(alpha: 0.40),
                        AppColors.primaryDark.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(child: _construirTarjeta()),
        ],
      ),
    );
  }

  Widget _construirTarjeta() {
    return Center(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppDimensions.spacingXxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingXl),
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: AutofillGroup(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          _assetLogo,
                          height: 96,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          semanticLabel: Textos.t('Logo de Mi Ruta Cafetera'),
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(height: 96);
                          },
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                      const Tr(
                        'Mi Ruta Cafetera',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      const Tr(
                        'Descubre la Ruta cafetera del Huila',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingLg),
                      Text(
                        titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (descripcion != null) ...[
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          descripcion!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDimensions.spacingXl),
                      ...children,
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

/// Decoración de los campos de texto de los accesos (la misma del login
/// de usuario): relleno blanco translúcido y borde redondeado.
InputDecoration decoracionCampoLogin({
  required String etiqueta,
  required String ayuda,
  required IconData icono,
  Widget? sufijo,
}) {
  return InputDecoration(
    labelText: etiqueta,
    hintText: ayuda,
    prefixIcon: Icon(icono),
    suffixIcon: sufijo,
    filled: true,
    fillColor: AppColors.white.withValues(alpha: 0.78),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
  );
}
