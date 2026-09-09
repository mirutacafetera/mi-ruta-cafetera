import 'package:flutter/material.dart';

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

  static const Color verdePrincipal = Color(0xFF31572C);
  static const Color verdeOscuro = Color(0xFF1B4332);
  static const Color grisTexto = Color(0xFF6B6B6B);
  static const Color grisBorde = Color(0xFFE1E1E1);

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
            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: grisBorde,
              ),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: verdePrincipal,
              title: const Text(
                'Sitio activo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: verdeOscuro,
                ),
              ),
              subtitle: Text(
                activo
                    ? 'Disponible para los visitantes'
                    : 'Oculto para los visitantes',
                style: const TextStyle(
                  fontSize: 11,
                  color: grisTexto,
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