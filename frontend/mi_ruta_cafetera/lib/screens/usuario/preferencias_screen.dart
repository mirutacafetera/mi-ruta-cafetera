import 'package:flutter/material.dart';

import '../../services/usuario/preferencias_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

// ============================================================
// PREFERENCIAS
// ============================================================
//
// Tamaño de texto y tipo de letra de toda la aplicación. Los
// cambios se aplican al instante y se conservan al cerrar la app.
// ============================================================

class PreferenciasScreen extends StatelessWidget {
  const PreferenciasScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Preferencias'),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<TamanoTexto>(
          valueListenable: PreferenciasService.instance.tamanoTexto,
          builder: (context, actual, _) {
            return ListView(
              padding: const EdgeInsets.all(
                AppDimensions.pageHorizontal,
              ),
              children: [
                const Text(
                  'Tamaño del texto',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                const Text(
                  'Elige qué tan grande quieres leer la aplicación.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                for (final tamano in TamanoTexto.values) ...[
                  _OpcionTamano(
                    tamano: tamano,
                    seleccionada: tamano == actual,
                    onTap: () => PreferenciasService.instance
                        .cambiarTamanoTexto(tamano),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                ],
                const SizedBox(height: AppDimensions.spacingSection),
                const Text(
                  'Tipo de letra',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                const Text(
                  'Cambia la letra de toda la aplicación.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                ValueListenableBuilder<FuenteApp>(
                  valueListenable: PreferenciasService.instance.fuente,
                  builder: (context, fuenteActual, _) {
                    return Column(
                      children: [
                        for (final fuente in FuenteApp.values) ...[
                          _OpcionFuente(
                            fuente: fuente,
                            seleccionada: fuente == fuenteActual,
                            onTap: () => PreferenciasService.instance
                                .cambiarFuente(fuente),
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingMd,
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingXl),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius,
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Así se verá',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        'Descubre fincas, miradores y sabores del '
                        'Huila a tu propio ritmo.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OpcionTamano extends StatelessWidget {
  final TamanoTexto tamano;
  final bool seleccionada;
  final VoidCallback onTap;

  const _OpcionTamano({
    required this.tamano,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius,
            ),
            border: Border.all(
              color:
                  seleccionada ? AppColors.secondary : AppColors.border,
              width: seleccionada ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.text_fields_rounded,
                color: AppColors.secondary,
                size: AppDimensions.iconLg * tamano.factor,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Text(
                  tamano.etiqueta,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (seleccionada)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcionFuente extends StatelessWidget {
  final FuenteApp fuente;
  final bool seleccionada;
  final VoidCallback onTap;

  const _OpcionFuente({
    required this.fuente,
    required this.seleccionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius,
            ),
            border: Border.all(
              color:
                  seleccionada ? AppColors.secondary : AppColors.border,
              width: seleccionada ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.font_download_rounded,
                color: AppColors.secondary,
                size: AppDimensions.iconLg,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                // Cada opción se muestra con su propia letra.
                child: Text(
                  fuente.etiqueta,
                  style: TextStyle(
                    fontFamily: fuente.familia,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (seleccionada)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
