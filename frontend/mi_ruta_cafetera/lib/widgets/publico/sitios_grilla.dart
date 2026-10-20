import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../theme/app_dimensions.dart';

/// Cuadrícula de tarjetas de sitios turísticos.
///
/// Las columnas se adaptan al ancho disponible: 2 en celulares y
/// hasta 4 en tabletas y Web. Las tarjetas de una misma fila tienen
/// la misma altura. Quien la usa decide cómo se dibuja cada tarjeta
/// ([construirTarjeta]), así se reutiliza SitioCard con su favorito,
/// su toque y su botón sin duplicar nada.
class SitiosGrilla extends StatelessWidget {
  static const double _anchoIdealTarjeta = 220;
  static const int _columnasMinimas = 2;
  static const int _columnasMaximas = 4;

  final List<SitioTuristicoModel> sitios;
  final Widget Function(SitioTuristicoModel sitio) construirTarjeta;

  const SitiosGrilla({
    super.key,
    required this.sitios,
    required this.construirTarjeta,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        const separacion = AppDimensions.spacingMd;

        final calculadas =
            ((restricciones.maxWidth + separacion) /
                    (_anchoIdealTarjeta + separacion))
                .floor();

        final columnas = max(
          _columnasMinimas,
          min(_columnasMaximas, calculadas),
        );

        final filas = <Widget>[];

        for (var inicio = 0; inicio < sitios.length; inicio += columnas) {
          final celdas = <Widget>[];

          for (var i = 0; i < columnas; i++) {
            final indice = inicio + i;

            if (i > 0) {
              celdas.add(const SizedBox(width: separacion));
            }

            celdas.add(
              Expanded(
                child: indice < sitios.length
                    ? construirTarjeta(sitios[indice])
                    : const SizedBox.shrink(),
              ),
            );
          }

          if (filas.isNotEmpty) {
            filas.add(const SizedBox(height: separacion));
          }

          filas.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: celdas,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: filas,
        );
      },
    );
  }
}
