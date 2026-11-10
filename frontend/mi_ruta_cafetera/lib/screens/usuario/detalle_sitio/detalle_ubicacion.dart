
import 'package:flutter/material.dart';

import '../../../../models/sitio_turistico_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import '../../../l10n/textos.dart';
import '../../../widgets/usuario/detalle_sitio/componentes_detalle.dart';

class DetalleUbicacion extends StatelessWidget {
  const DetalleUbicacion({
    super.key,
    required this.sitio,
    required this.onVerMapa,
  });

  final SitioTuristicoModel sitio;
  final VoidCallback onVerMapa;

  @override
  Widget build(BuildContext context) {
    final direccion = sitio.direccion.trim();
    final ciudad = sitio.ciudad.trim();
    final departamento = sitio.departamento.trim();
    final horario = sitio.horario.trim();

    final ubicacion = [
      if (direccion.isNotEmpty) direccion,
      if (ciudad.isNotEmpty) ciudad,
      if (departamento.isNotEmpty) departamento,
    ].join(', ');

    final precio = sitio.precioDesde > 0
    ? '${_formatearPrecio(sitio.precioDesde)} COP'
    : 'No especificado';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TARJETA DE INFORMACIÓN
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: decoracionTarjetaDetalle(
            radio: AppDimensions.cardRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: AppColors.sitioPrimary,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.near_me_rounded,
                      color: AppColors.sitioTextOnPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Tr(
                          'Cómo llegar',
                          style: TextStyle(
                            color: AppColors.sitioTextPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Tr(
                          'Encuentra este destino',
                          style: TextStyle(
                            color: AppColors.sitioTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.sitioSurfaceGreen,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.explore_outlined,
                      color: AppColors.sitioAccent,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              // TÍTULO DE INFORMACIÓN
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.sitioAccent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'INFORMACIÓN DE VISITA',
                    style: TextStyle(
                      color: AppColors.sitioTextSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // DIRECCIÓN, HORARIO Y PRECIO
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DIRECCIÓN
                    Expanded(
                      flex: 5,
                      child: _datoVisita(
                        icono: Icons.location_on_rounded,
                        titulo: 'Dirección',
                        contenido: ubicacion.isNotEmpty
                            ? ubicacion
                            : Textos.t('Ubicación no disponible'),
                      ),
                    ),

                    _separador(),

                    // HORARIO
                    Expanded(
                      flex: 4,
                      child: _datoVisita(
                        icono: Icons.access_time_rounded,
                        titulo: 'Horario de atención',
                        contenido: horario.isNotEmpty
                            ? horario
                            : 'No especificado',
                      ),
                    ),

                    _separador(),

                    // PRECIO DE ENTRADA
                    Expanded(
                      flex: 4,
                      child: _datoVisita(
                        icono: Icons.confirmation_number_outlined,
                        titulo: 'Precio de entrada',
                        contenido: precio,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // BOTÓN INDEPENDIENTE DEL MAPA
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onVerMapa,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioPrimary,
              foregroundColor: AppColors.sitioTextOnPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 21,
                ),
                const SizedBox(width: 10),
                const Tr(
                  'Ver ubicación en el mapa',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 9),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // SEPARADOR VERTICAL
  Widget _separador() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 9),
      color: AppColors.sitioBorder,
    );
  }

  // INFORMACIÓN INDIVIDUAL
  Widget _datoVisita({
    required IconData icono,
    required String titulo,
    required String contenido,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.sitioSurfaceGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icono,
            color: AppColors.sitioAccent,
            size: 19,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          titulo,
          style: const TextStyle(
            color: AppColors.sitioTextPrimary,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          contenido,
          style: const TextStyle(
            color: AppColors.sitioTextSecondary,
            fontSize: 11.5,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // FORMATO DE PRECIO: $5.000
  String _formatearPrecio(double valor) {
    final entero = valor.round();
    final digitos = entero.toString();

    final resultado = digitos.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (coincidencia) => '.',
    );

    return '\$$resultado';
  }
}
