import 'package:flutter/material.dart';

import '../../../../theme/app_dimensions.dart';
import '../../../l10n/textos.dart';

class DetalleResenasReservas extends StatelessWidget {
  final List<Widget> resenas;
  final List<Widget> reservas;
  final bool cargandoResenas;
  final bool cargandoReservas;

  const DetalleResenasReservas({
    super.key,
    this.resenas = const [],
    this.reservas = const [],
    this.cargandoResenas = false,
    this.cargandoReservas = false,
  });

  @override
  Widget build(BuildContext context) {
    if (resenas.isEmpty &&
        reservas.isEmpty &&
        !cargandoResenas &&
        !cargandoReservas) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reservas.isNotEmpty || cargandoReservas) ...[
            Tr(
              'Reservas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppDimensions.spacingMd),
            if (cargandoReservas)
              const Center(child: CircularProgressIndicator())
            else
              ...reservas,
            SizedBox(height: AppDimensions.spacingXxl),
          ],
          if (resenas.isNotEmpty || cargandoResenas) ...[
            Tr(
              'Opiniones de los visitantes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppDimensions.spacingMd),
            if (cargandoResenas)
              const Center(child: CircularProgressIndicator())
            else
              ...resenas,
          ],
        ],
      ),
    );
  }

  /// Visor global de imágenes con zoom integrado para asegurar su funcionamiento en Web y móvil
  static void mostrarVisorImagenGlobal(BuildContext context, String url) {
    final size = MediaQuery.sizeOf(context);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.92),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size.width * 0.9,
              height: size.height * 0.9,
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_rounded, color: Colors.white, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'No se pudo cargar la imagen',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 34),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}