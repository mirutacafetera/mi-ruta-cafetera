import 'package:flutter/material.dart';

import '../../l10n/textos.dart';
import '../../services/usuario/preferencias_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

// ============================================================
// PREFERENCIAS
// ============================================================
//
// Idioma, tamaño de texto y tipo de letra de toda la aplicación. Los
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
        title: Text(context.t('pref.titulo')),
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
                Text(
                  context.t('pref.idioma'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  context.t('pref.idioma.desc'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXl),
                ValueListenableBuilder<IdiomaApp>(
                  valueListenable: PreferenciasService.instance.idioma,
                  builder: (context, idiomaActual, _) {
                    return Column(
                      children: [
                        for (final idioma in IdiomaApp.values) ...[
                          _OpcionIdioma(
                            idioma: idioma,
                            seleccionada: idioma == idiomaActual,
                            onTap: () => PreferenciasService.instance
                                .cambiarIdioma(idioma),
                          ),
                          const SizedBox(
                            height: AppDimensions.spacingMd,
                          ),
                        ],
                      ],
                    );
                  },
                ),
                Text(
                  context.t('pref.idioma.nota'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSection),
                Text(
                  context.t('pref.tamano'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  context.t('pref.tamano.desc'),
                  style: const TextStyle(
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
                Text(
                  context.t('pref.fuente'),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  context.t('pref.fuente.desc'),
                  style: const TextStyle(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t('pref.vista'),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        context.t('pref.vista.texto'),
                        style: const TextStyle(
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
                  context.t('pref.tamano.${tamano.id}'),
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
                  context.t('pref.fuente.${fuente.id}'),
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

class _OpcionIdioma extends StatelessWidget {
  final IdiomaApp idioma;
  final bool seleccionada;
  final VoidCallback onTap;

  const _OpcionIdioma({
    required this.idioma,
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
              Text(
                idioma.bandera,
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                // Cada idioma se escribe en su propio idioma.
                child: Text(
                  idioma.etiqueta,
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
