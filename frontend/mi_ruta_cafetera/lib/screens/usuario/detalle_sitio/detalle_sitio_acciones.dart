import 'package:flutter/material.dart';

import '../../../l10n/textos.dart';
import '../../../models/sitio_turistico_model.dart';
import '../../../models/sitio/sitio_actividad_model.dart';
import '../../../services/usuario/usuario_sesion_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/mapa/mapa_detalle_sitio.dart';
import '../../../widgets/usuario/detalle_sitio/componentes_detalle.dart';
import '../../../widgets/usuario/detalle_sitio/panel_detalle_adaptable.dart';
import '../../mapa_screen_2.dart';
import '../reservar_actividad_screen.dart';

class DetalleSitioAcciones {
  DetalleSitioAcciones._();

  // =====================================================
  // ABRIR MAPA DEL SITIO
  // =====================================================

  static void verMapa(
    BuildContext context,
    SitioTuristicoModel sitio,
  ) {
    if (!sitio.tieneCoordenadas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Tr(
            'Este sitio todavía no tiene una ubicación válida.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaScreen2(sitioInicial: sitio),
      ),
    );
  }

  // =====================================================
  // DETALLE DEL SITIO DESDE EL MAPA
  // =====================================================

  static void mostrarDetalleMapa(
    BuildContext context,
    SitioTuristicoModel sitio,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapaDetalleSitio(
        sitio: sitio,
        onVerMapa: () => verMapa(context, sitio),
        onAgregarRuta: () => agregarRuta(context),
      ),
    );
  }

  // =====================================================
  // AGREGAR A LA RUTA
  // =====================================================

  static void agregarRuta(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Tr(
          'La selección de sitios para tu ruta estará disponible aquí.',
        ),
      ),
    );
  }

  // =====================================================
  // DETALLE DE ACTIVIDAD
  // =====================================================

  static void mostrarActividad(
    BuildContext context,
    SitioActividadModel actividad, {
    String nombreSitio = '',
  }) {
    final imagenes = unirImagenesDetalle(
      actividad.imagenPrincipal,
      actividad.imagenes,
    );

    PanelDetalleAdaptable.mostrar<void>(
      context: context,
      titulo: actividad.nombre,
      icono: Icons.eco_rounded,
      maxWidth: 820,
      builder: (panelContext) => _ContenidoDetalleActividad(
        actividad: actividad,
        imagenes: imagenes,
        onSolicitarReserva: () {
          final sesion =
              UsuarioSesionService.instance.sesionActual.value;

          final mensajes = ScaffoldMessenger.of(context);

          // Cerrar el panel antes de continuar.
          Navigator.of(panelContext).pop();

          if (sesion == null) {
            mensajes.showSnackBar(
              const SnackBar(
                content: Tr(
                  'Inicia sesión para solicitar una reserva.',
                ),
              ),
            );
            return;
          }

          if (!context.mounted) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReservarActividadScreen(
                actividad: actividad,
                nombreSitio: nombreSitio,
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================================
// CONTENIDO DEL DETALLE DE LA ACTIVIDAD
//
// El nombre ya aparece en el encabezado del panel, por
// eso no se repite en el cuerpo.
// =====================================================

class _ContenidoDetalleActividad extends StatelessWidget {
  const _ContenidoDetalleActividad({
    required this.actividad,
    required this.imagenes,
    required this.onSolicitarReserva,
  });

  final SitioActividadModel actividad;
  final List<String> imagenes;
  final VoidCallback onSolicitarReserva;

  @override
  Widget build(BuildContext context) {
    final descripcion = actividad.descripcion.trim();
    final duracion = actividad.duracion.trim();
    final horario = actividad.horario.trim();

    final tieneInformacion =
        duracion.isNotEmpty || horario.isNotEmpty || actividad.precio > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imágenes de la actividad.
        if (imagenes.isNotEmpty)
          CarruselImagenesDetalle(imagenes: imagenes)
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: const AspectRatio(
              aspectRatio: 16 / 9,
              child: PlaceholderImagenDetalle(
                mensaje: 'Esta actividad aún no tiene imágenes',
              ),
            ),
          ),

        const SizedBox(height: AppDimensions.spacingLg),

        const EtiquetaDetalle(
          texto: 'EXPERIENCIA TURÍSTICA',
          icono: Icons.eco_rounded,
          traducir: true,
          mayusculas: true,
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Descripción.
        Text(
          descripcion.isEmpty
              ? Textos.t(
                  'No hay una descripción disponible para esta actividad.',
                )
              : descripcion,
          style: const TextStyle(
            color: AppColors.sitioTextPrimary,
            fontSize: 15,
            height: 1.7,
          ),
        ),

        // Información adicional.
        if (tieneInformacion) ...[
          const SizedBox(height: AppDimensions.spacingXl),

          const Divider(
            color: AppColors.sitioDivider,
            height: 1,
          ),

          const SizedBox(height: AppDimensions.spacingLg),

          const Tr(
            'Información de la actividad',
            style: TextStyle(
              color: AppColors.sitioPrimaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingMd),

          if (duracion.isNotEmpty)
            FilaDatoDetalle(
              icono: Icons.schedule_rounded,
              titulo: Textos.t('Duración'),
              valor: duracion,
            ),

          if (horario.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            FilaDatoDetalle(
              icono: Icons.access_time_rounded,
              titulo: Textos.t('Horario'),
              valor: horario,
            ),
          ],

          if (actividad.precio > 0) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            FilaDatoDetalle(
              icono: Icons.payments_outlined,
              titulo: Textos.t('Precio'),
              valor: formatearPrecioCop(actividad.precio),
            ),
          ],
        ],

        const SizedBox(height: AppDimensions.spacingXl),

        // Solicitar reserva.
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSolicitarReserva,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioAccent,
              foregroundColor: AppColors.sitioTextOnPrimary,
              minimumSize: const Size.fromHeight(
                AppDimensions.detalleActionHeight,
              ),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
            ),
            icon: const Icon(Icons.event_available_rounded),
            label: const Tr(
              'Solicitar reserva',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
