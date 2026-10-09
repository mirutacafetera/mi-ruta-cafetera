import 'package:flutter/material.dart';

import '../../../../../theme/app_dimensions.dart';
import 'campo_formulario_sitio.dart';
import 'contenedor_seccion_sitio.dart';
import 'titulo_seccion_sitio.dart';

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
    return ContenedorSeccionSitio(
      contenido: Column(
        children: [
          const TituloSeccionSitio(
            icono: Icons.map_outlined,
            titulo: 'Ubicación',
            subtitulo: 'Indica dónde se encuentra el sitio',
          ),

          CampoFormularioSitio(
            controlador: direccionController,
            etiqueta: 'Dirección',
            icono: Icons.location_on_rounded,
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CampoFormularioSitio(
                  controlador: ciudadController,
                  etiqueta: 'Ciudad',
                  icono: Icons.location_city_rounded,
                  obligatorio: true,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              Expanded(
                child: CampoFormularioSitio(
                  controlador: departamentoController,
                  etiqueta: 'Departamento',
                  icono: Icons.map_rounded,
                  obligatorio: true,
                ),
              ),
            ],
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CampoFormularioSitio(
                  controlador: latitudController,
                  etiqueta: 'Latitud',
                  icono: Icons.explore_rounded,
                  tipoTeclado: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  obligatorio: true,
                ),
              ),
              const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              Expanded(
                child: CampoFormularioSitio(
                  controlador: longitudController,
                  etiqueta: 'Longitud',
                  icono: Icons.explore_outlined,
                  tipoTeclado: const TextInputType.numberWithOptions(
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