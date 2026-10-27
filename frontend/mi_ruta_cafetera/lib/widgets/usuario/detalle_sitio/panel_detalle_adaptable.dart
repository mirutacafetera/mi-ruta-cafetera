import 'package:flutter/material.dart';

import '../../../l10n/textos.dart';
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
    this.esPanelInferior = false,
  });

  final String titulo;
  final Widget child;
  final IconData icono;
  final double maxWidth;
  final double maxHeightFactor;
  final EdgeInsetsGeometry paddingContenido;
  final bool alineacionCentrada;

  /// En el panel inferior solo se redondean las esquinas de arriba,
  /// porque el borde de abajo toca el borde de la pantalla.
  final bool esPanelInferior;

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
              horizontal: AppDimensions.spacingXxl,
              vertical: AppDimensions.spacingXxl,
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
              esPanelInferior: true,
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

    final radio = Radius.circular(AppDimensions.detalleContentRadius);

    // Deja libre la zona de los gestos del sistema en el panel inferior.
    final espacioInferior =
        esPanelInferior ? mediaQuery.viewPadding.bottom : 0.0;

    final padding = paddingContenido.resolve(Directionality.of(context));

    return Material(
      color: AppColors.sitioBackground,
      clipBehavior: Clip.antiAlias,
      borderRadius: esPanelInferior
          ? BorderRadius.only(topLeft: radio, topRight: radio)
          : BorderRadius.all(radio),
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
                  padding: padding.copyWith(
                    bottom: padding.bottom + espacioInferior,
                  ),
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
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingXl,
        14,
        AppDimensions.spacingMd,
        14,
      ),
      decoration: const BoxDecoration(color: AppColors.sitioPrimaryDark),
      child: Row(
        children: [
          Container(
            width: AppDimensions.buttonHeightSmall,
            height: AppDimensions.buttonHeightSmall,
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              icono,
              color: AppColors.sitioPrimary,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Semantics(
              header: true,
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
          ),
          IconButton(
            tooltip: Textos.t('Cerrar detalle'),
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.sitioTextOnPrimary,
          ),
        ],
      ),
    );
  }
}
