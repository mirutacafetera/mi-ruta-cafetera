import 'package:flutter/material.dart';

import 'sitio_form_field.dart';
import 'sitio_section_card.dart';
import 'sitio_section_title.dart';

class SitioUbicacion extends StatelessWidget {
  final TextEditingController direccionController;
  final TextEditingController ciudadController;
  final TextEditingController departamentoController;
  final TextEditingController latitudController;
  final TextEditingController longitudController;

  const SitioUbicacion({
    super.key,
    required this.direccionController,
    required this.ciudadController,
    required this.departamentoController,
    required this.latitudController,
    required this.longitudController,
  });

  @override
  Widget build(BuildContext context) {
    return SitioSectionCard(
      child: Column(
        children: [
          const SitioSectionTitle(
            icono: Icons.map_outlined,
            titulo: 'Ubicación',
            subtitulo: 'Indica dónde se encuentra el sitio',
          ),

          SitioFormField(
            controller: direccionController,
            label: 'Dirección',
            icon: Icons.location_on_rounded,
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SitioFormField(
                  controller: ciudadController,
                  label: 'Ciudad',
                  icon: Icons.location_city_rounded,
                  obligatorio: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SitioFormField(
                  controller: departamentoController,
                  label: 'Departamento',
                  icon: Icons.map_rounded,
                  obligatorio: true,
                ),
              ),
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SitioFormField(
                  controller: latitudController,
                  label: 'Latitud',
                  icon: Icons.explore_rounded,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  obligatorio: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SitioFormField(
                  controller: longitudController,
                  label: 'Longitud',
                  icon: Icons.explore_outlined,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  obligatorio: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}