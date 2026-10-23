
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
}
