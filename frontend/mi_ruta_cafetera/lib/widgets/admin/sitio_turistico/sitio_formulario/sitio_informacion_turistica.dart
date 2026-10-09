import 'package:flutter/material.dart';

import '../../../../../theme/app_colors.dart';
import '../../../../../theme/app_dimensions.dart';
import 'campo_formulario_sitio.dart';
import 'contenedor_seccion_sitio.dart';
import 'titulo_seccion_sitio.dart';

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
    return ContenedorSeccionSitio(
      contenido: Column(
        children: [
          const TituloSeccionSitio(
            icono: Icons.travel_explore_rounded,
            titulo: 'Información turística',
            subtitulo: 'Información útil para los visitantes',
          ),

          CampoFormularioSitio(
            controlador: horarioController,
            etiqueta: 'Horario de atención',
            icono: Icons.schedule_rounded,
          ),

          CampoFormularioSitio(
            controlador: precioController,
            etiqueta: 'Precio desde',
            icono: Icons.payments_rounded,
            tipoTeclado: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.creamLight,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.secondary,
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