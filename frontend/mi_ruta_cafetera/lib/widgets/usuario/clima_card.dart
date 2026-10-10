import 'package:flutter/material.dart';

import '../../models/clima_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

enum EstadoClima {
  cargando,
  disponible,
  sinUbicacion,
  error,
}

/// Tarjeta "Clima en tu zona" del Home del usuario.
///
/// Nunca ocupa la pantalla con errores: si no hay ubicación o el
/// servicio falla, muestra un mensaje breve y un botón para
/// reintentar.
class ClimaCard extends StatelessWidget {
  final EstadoClima estado;
  final ClimaModel? clima;

  /// Mensaje cuando no hay ubicación disponible.
  final String mensajeUbicacion;

  final VoidCallback onReintentar;

  const ClimaCard({
    super.key,
    required this.estado,
    required this.clima,
    required this.onReintentar,
    this.mensajeUbicacion =
        'Activa tu ubicación para ver el clima de tu zona.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: _construirContenido(),
    );
  }

  Widget _construirContenido() {
    switch (estado) {
      case EstadoClima.cargando:
        return const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(
              width: AppDimensions.spacingMd,
            ),
            Expanded(
              child: Text(
                'Consultando el clima en tu zona...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );

      case EstadoClima.disponible:
        return _construirClima(clima!);

      case EstadoClima.sinUbicacion:
        return _construirAviso(
          icono: Icons.location_off_rounded,
          mensaje: mensajeUbicacion,
        );

      case EstadoClima.error:
        return _construirAviso(
          icono: Icons.cloud_off_rounded,
          mensaje:
              'No pudimos consultar el clima en este momento.',
        );
    }
  }

  Widget _construirClima(ClimaModel clima) {
    final probabilidad = clima.probabilidadLluvia;

    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: AppColors.orangeSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            clima.icono,
            color: AppColors.secondary,
            size: AppDimensions.iconLg + 4,
          ),
        ),
        const SizedBox(
          width: AppDimensions.spacingMd,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clima en tu zona',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXs,
              ),
              Text(
                '${clima.temperatura.round()}°C · '
                '${clima.descripcion}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (probabilidad != null) ...[
                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),
                Text(
                  'Probabilidad de lluvia: $probabilidad%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _construirAviso({
    required IconData icono,
    required String mensaje,
  }) {
    return Row(
      children: [
        Icon(
          icono,
          color: AppColors.textSecondary,
          size: AppDimensions.iconLg,
        ),
        const SizedBox(
          width: AppDimensions.spacingMd,
        ),
        Expanded(
          child: Text(
            mensaje,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
        TextButton(
          onPressed: onReintentar,
          child: const Text('Reintentar'),
        ),
      ],
    );
  }
}