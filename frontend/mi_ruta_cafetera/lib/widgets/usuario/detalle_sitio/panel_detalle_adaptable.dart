import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

/// Contenedor reutilizable para los detalles de actividades,
/// productos e historias del sitio turístico.
///
/// En móvil aparece como panel inferior.
/// En web y pantallas amplias aparece como panel centrado.
class PanelDetalleAdaptable extends StatelessWidget {
  const PanelDetalleAdaptable({
    super.key,
    required this.titulo,
    required this.child,
    this.icono = Icons.info_outline_rounded,
    this.maxWidth = 760,
    this.maxHeightFactor = 0.92,
    this.paddingContenido = const EdgeInsets.all(AppDimensions.spacingLg),
    this.alineacionCentrada = false,
  });

  final String titulo;
  final Widget child;
  final IconData icono;
  final double maxWidth;
  final double maxHeightFactor;
  final EdgeInsetsGeometry paddingContenido;
  final bool alineacionCentrada;

  /// Abre un diálogo centrado en pantallas amplias
  /// o un panel inferior en dispositivos móviles.
  static Future<T?> mostrar<T>({
    required BuildContext context,
    required String titulo,
    required WidgetBuilder builder,
    IconData icono = Icons.info_outline_rounded,
    double maxWidth = 760,
  }) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esPantallaAmplia = ancho >= 700;

    if (esPantallaAmplia) {
      return showDialog<T>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: MediaQuery.sizeOf(dialogContext).height * 0.92,
              ),
              child: PanelDetalleAdaptable(
                titulo: titulo,
                icono: icono,
                maxWidth: maxWidth,
                child: builder(dialogContext),
              ),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final alturaMaxima = MediaQuery.sizeOf(sheetContext).height * 0.92;

        return SizedBox(
          width: double.infinity,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: alturaMaxima),
            child: PanelDetalleAdaptable(
              titulo: titulo,
              icono: icono,
              maxWidth: maxWidth,
              child: builder(sheetContext),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final alturaMaxima = mediaQuery.size.height * maxHeightFactor;

    return Material(
      color: AppColors.sitioBackground,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(AppDimensions.detalleContentRadius),
      child: SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: alturaMaxima,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _encabezado(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: paddingContenido,
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      decoration: const BoxDecoration(color: AppColors.sitioPrimaryDark),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icono, color: AppColors.sitioPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.sitioTextOnPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar detalle',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.sitioTextOnPrimary,
          ),
        ],
      ),
    );
  }
}
