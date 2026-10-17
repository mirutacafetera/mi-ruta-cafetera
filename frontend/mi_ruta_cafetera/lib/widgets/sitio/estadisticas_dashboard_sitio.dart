
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/sitio/sitio_dashboard_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'tarjeta_estadistica_sitio.dart';

class EstadisticasDashboardSitio extends StatelessWidget {
  final SitioDashboardModel dashboard;
  final bool esEscritorio;

  const EstadisticasDashboardSitio({
    super.key,
    required this.dashboard,
    required this.esEscritorio,
  });

  @override
  Widget build(BuildContext context) {
    final tarjetas = [
      TarjetaEstadisticaSitio(
        titulo: 'Reservas',
        valor: '${dashboard.totalReservas}',
        descripcion: 'Reservas recibidas',
        icono: Icons.calendar_month_rounded,
      ),
      TarjetaEstadisticaSitio(
        titulo: 'Reseñas',
        valor: '${dashboard.totalResenas}',
        descripcion:
            'Calificación promedio: ${dashboard.promedioCalificacion.toStringAsFixed(1)} / 5',
        icono: Icons.star_rounded,
      ),
      TarjetaEstadisticaSitio(
        titulo: 'Actividades',
        valor: '${dashboard.totalActividades}',
        descripcion: 'Actividades publicadas',
        icono: Icons.local_activity_rounded,
      ),
      TarjetaEstadisticaSitio(
        titulo: 'Contenidos',
        valor: '${dashboard.totalContenidos}',
        descripcion: 'Contenidos publicados',
        icono: Icons.article_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const espacio = 14.0;
        const columnas = 2;

        final anchoTarjeta =
            (constraints.maxWidth - espacio) / columnas;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de tu sitio',
              style: TextStyle(
                color: AppColors.sitioTextPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Consulta el estado de tu actividad turística.',
              style: TextStyle(
                color: AppColors.sitioTextSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: espacio,
              runSpacing: espacio,
              children: tarjetas.map((tarjeta) {
                return SizedBox(
                  width: anchoTarjeta,
                  height: 164,
                  child: tarjeta,
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            const Text(
              'Análisis de actividad',
              style: TextStyle(
                color: AppColors.sitioTextPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Indicadores visuales del comportamiento de tu sitio.',
              style: TextStyle(
                color: AppColors.sitioTextSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            _tarjetaGrafica(
              titulo: 'Estado de las reservas',
              subtitulo: 'Distribución según su estado actual',
              icono: Icons.donut_large_rounded,
              child: _graficaReservas(),
            ),
            const SizedBox(height: 18),
            _tarjetaGrafica(
              titulo: 'Actividades y contenidos',
              subtitulo: 'Comparación de publicaciones activas',
              icono: Icons.bar_chart_rounded,
              child: _graficaContenido(),
            ),
            const SizedBox(height: 18),
            _tarjetaCalificacion(),
          ],
        );
      },
    );
  }

  Widget _tarjetaGrafica({
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icono,
                  color: AppColors.sitioPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: AppColors.sitioTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        color: AppColors.sitioTextSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _graficaReservas() {
    final pendientes = dashboard.reservasPendientes;
    final confirmadas = dashboard.reservasConfirmadas;

    final otras = math.max(
      0,
      dashboard.totalReservas - pendientes - confirmadas,
    );

    final total = pendientes + confirmadas + otras;

    if (total == 0) {
      return _mensajeSinDatos(
        'Todavía no hay reservas para representar.',
      );
    }

    final segmentos = [
      _SegmentoReserva(
        titulo: 'Confirmadas',
        cantidad: confirmadas,
        color: AppColors.sitioSuccess,
      ),
      _SegmentoReserva(
        titulo: 'Pendientes',
        cantidad: pendientes,
        color: AppColors.sitioWarning,
      ),
      _SegmentoReserva(
        titulo: 'Otros estados',
        cantidad: otras,
        color: AppColors.sitioInfo,
      ),
    ].where((segmento) => segmento.cantidad > 0).toList();

    return Column(
      children: [
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(220, 220),
                painter: _GraficaTortaPainter(
                  segmentos: segmentos,
                  total: total,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Reservas',
                    style: TextStyle(
                      color: AppColors.sitioTextSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total',
                    style: const TextStyle(
                      color: AppColors.sitioTextPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'en total',
                    style: TextStyle(
                      color: AppColors.sitioTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ...segmentos.map((segmento) {
          final porcentaje =
              segmento.cantidad / total * 100;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: segmento.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    segmento.titulo,
                    style: const TextStyle(
                      color: AppColors.sitioTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${segmento.cantidad}',
                  style: const TextStyle(
                    color: AppColors.sitioTextPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 52,
                  child: Text(
                    '${porcentaje.toStringAsFixed(1)}%',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.sitioTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _graficaContenido() {
    final actividades = dashboard.totalActividades;
    final contenidos = dashboard.totalContenidos;

    final maximo = math.max(actividades, contenidos);

    if (maximo == 0) {
      return _mensajeSinDatos(
        'Todavía no hay actividades ni contenidos publicados.',
      );
    }

    return Column(
      children: [
        _barraContenido(
          titulo: 'Actividades',
          cantidad: actividades,
          maximo: maximo,
          color: AppColors.sitioSuccess,
          icono: Icons.local_activity_rounded,
        ),
        const SizedBox(height: 24),
        _barraContenido(
          titulo: 'Contenidos',
          cantidad: contenidos,
          maximo: maximo,
          color: AppColors.sitioAccent,
          icono: Icons.article_rounded,
        ),
      ],
    );
  }

  Widget _barraContenido({
    required String titulo,
    required int cantidad,
    required int maximo,
    required Color color,
    required IconData icono,
  }) {
    final proporcion = cantidad / maximo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icono,
              color: color,
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  color: AppColors.sitioTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$cantidad',
              style: const TextStyle(
                color: AppColors.sitioTextPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: proporcion,
            minHeight: 12,
            backgroundColor: AppColors.sitioDivider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _tarjetaCalificacion() {
    final calificacion =
        dashboard.promedioCalificacion.clamp(0.0, 5.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.sitioWarningSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: AppColors.sitioWarning,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calificación de tu sitio',
                  style: TextStyle(
                    color: AppColors.sitioTextPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: List.generate(5, (indice) {
                    return Icon(
                      indice < calificacion.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.sitioAccent,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
          ),
          Text(
            calificacion.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.sitioPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mensajeSinDatos(String mensaje) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.insert_chart_outlined_rounded,
            size: 34,
            color: AppColors.sitioTextSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentoReserva {
  final String titulo;
  final int cantidad;
  final Color color;

  const _SegmentoReserva({
    required this.titulo,
    required this.cantidad,
    required this.color,
  });
}

class _GraficaTortaPainter extends CustomPainter {
  final List<_SegmentoReserva> segmentos;
  final int total;

  const _GraficaTortaPainter({
    required this.segmentos,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;

    final centro = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radio = size.shortestSide / 2 - 5;

    final rect = Rect.fromCircle(
      center: centro,
      radius: radio,
    );

    var anguloInicial = -math.pi / 2;

    for (final segmento in segmentos) {
      if (segmento.cantidad <= 0) continue;

      final barrido =
          segmento.cantidad / total * 2 * math.pi;

      final pintura = Paint()
        ..color = segmento.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect,
        anguloInicial,
        barrido,
        false,
        pintura,
      );

      anguloInicial += barrido;
    }
  }

  @override
  bool shouldRepaint(
    covariant _GraficaTortaPainter oldDelegate,
  ) {
    if (oldDelegate.total != total) return true;
    if (oldDelegate.segmentos.length != segmentos.length) {
      return true;
    }

    for (var i = 0; i < segmentos.length; i++) {
      final anterior = oldDelegate.segmentos[i];
      final actual = segmentos[i];

      if (anterior.cantidad != actual.cantidad ||
          anterior.color != actual.color ||
          anterior.titulo != actual.titulo) {
        return true;
      }
    }

    return false;
  }
}
