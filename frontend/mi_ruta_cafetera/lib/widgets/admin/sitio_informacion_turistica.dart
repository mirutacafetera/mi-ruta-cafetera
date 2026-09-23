import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import 'sitio_form_field.dart';
import 'sitio_section_card.dart';
import 'sitio_section_title.dart';

class SitioInformacionTuristica extends StatelessWidget {
  final TextEditingController horarioController;
  final TextEditingController precioController;
  final bool activo;
  final ValueChanged<bool> onActivoChanged;

  const SitioInformacionTuristica({
    super.key,
    required this.horarioController,
    required this.precioController,
    required this.activo,
    required this.onActivoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SitioSectionCard(
      child: Column(
        children: [
          const SitioSectionTitle(
            icono: Icons.travel_explore_rounded,
            titulo: 'Información turística',
            subtitulo: 'Información útil para los visitantes',
          ),

          SitioFormField(
            controller: horarioController,
            label: 'Horario de atención',
            icon: Icons.schedule_rounded,
          ),

          SitioFormField(
            controller: precioController,
            label: 'Precio desde',
            icon: Icons.payments_rounded,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd + 2,
              vertical: AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: const Text(
                'Sitio activo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              subtitle: Text(
                activo
                    ? 'Disponible para los visitantes'
                    : 'Oculto para los visitantes',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              value: activo,
              onChanged: onActivoChanged,
            ),
          ),
        ],
      ),
    );
  }
}