
import 'package:flutter/material.dart';

import '../../../models/admin/estadistica_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class GraficaEstadisticasMensuales extends StatefulWidget {
  final int anio;
  final List<int> aniosDisponibles;
  final List<EstadisticaMensualModel> datos;
  final ValueChanged<int> onCambiarAnio;

  const GraficaEstadisticasMensuales({
    super.key,
    required this.anio,
    required this.aniosDisponibles,
    required this.datos,
    required this.onCambiarAnio,
  });

  @override
  State<GraficaEstadisticasMensuales> createState() =>
      _GraficaEstadisticasMensualesState();
}

class _GraficaEstadisticasMensualesState
    extends State<GraficaEstadisticasMensuales> {
  String _indicador = 'usuarios';

  static const _indicadores = {
    'usuarios': 'Usuarios',
    'resenas': 'Reseñas',
    'reservas': 'Reservas',
    'reportes': 'Reportes',
  };

  static const _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const Color _cafe = Color(0xFFB58A70);

  int _valor(EstadisticaMensualModel dato) {
    switch (_indicador) {
      case 'resenas':
        return dato.resenas;
      case 'reservas':
        return dato.reservas;
      case 'reportes':
        return dato.reportes;
      default:
        return dato.usuarios;
    }
  }

  Color get _colorIndicador {
    switch (_indicador) {
      case 'resenas':
        return AppColors.secondary;
      case 'reservas':
        return AppColors.info;
      case 'reportes':
        return AppColors.tertiary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final valores = List.generate(12, (i) {
      final mes = widget.datos.where((d) => d.mes == i + 1);
      return mes.isEmpty ? 0 : _valor(mes.first);
    });

    final total = valores.fold<int>(0, (suma, valor) => suma + valor);
    final maximo = valores.fold<int>(
      0,
      (mayor, valor) => valor > mayor ? valor : mayor,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: _cafe, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: _colorIndicador,
                size: 29,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Actividad mensual',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Consulta y compara los registros por mes.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _selector<int>(
                  etiqueta: 'Año',
                  valor: widget.anio,
                  opciones: widget.aniosDisponibles,
                  texto: (anio) => anio.toString(),
                  alCambiar: widget.onCambiarAnio,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _selector<String>(
                  etiqueta: 'Indicador',
                  valor: _indicador,
                  opciones: _indicadores.keys.toList(),
                  texto: (clave) => _indicadores[clave]!,
                  alCambiar: (valor) {
                    setState(() => _indicador = valor);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  _indicadores[_indicador]!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '$total registros en el año',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: _colorIndicador,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            width: double.infinity,
            child: CustomPaint(
              painter: _GraficaLinealPainter(
                valores: valores,
                maximo: maximo,
                color: _colorIndicador,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: _cafe),
          const SizedBox(height: 10),
          const Text(
            'Registros por mes',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 58,
            ),
            itemBuilder: (context, index) {
              final valor = valores[index];

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: valor > 0
                      ? _colorIndicador.withValues(alpha: 0.10)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _cafe.withValues(alpha: 0.65),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _meses[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$valor registros',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: valor > 0
                            ? _colorIndicador
                            : AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _selector<T>({
    required String etiqueta,
    required T valor,
    required List<T> opciones,
    required String Function(T) texto,
    required ValueChanged<T> alCambiar,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 7),
        DropdownButtonFormField<T>(
          initialValue: opciones.contains(valor) ? valor : null,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _cafe),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _cafe),
            ),
          ),
          items: opciones.map((opcion) {
            return DropdownMenuItem<T>(
              value: opcion,
              child: Text(
                texto(opcion),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: (nuevo) {
            if (nuevo != null) alCambiar(nuevo);
          },
        ),
      ],
    );
  }
}

class _GraficaLinealPainter extends CustomPainter {
  final List<int> valores;
  final int maximo;
  final Color color;

  _GraficaLinealPainter({
    required this.valores,
    required this.maximo,
    required this.color,
  });

  static const _meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  static const Color _cafe = Color(0xFFB58A70);

  @override
  void paint(Canvas canvas, Size size) {
    const izquierda = 32.0;
    const derecha = 8.0;
    const arriba = 20.0;
    const abajo = 28.0;

    final ancho = size.width - izquierda - derecha;
    final alto = size.height - arriba - abajo;
    final escala = maximo == 0 ? 1.0 : maximo.toDouble();

    final lineaGuia = Paint()
      ..color = _cafe.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    final texto = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (var i = 0; i < 4; i++) {
      final y = arriba + alto * i / 3;

      canvas.drawLine(
        Offset(izquierda, y),
        Offset(size.width - derecha, y),
        lineaGuia,
      );

      final valor = (maximo * (3 - i) / 3).round();

      texto.text = TextSpan(
        text: '$valor',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      );
      texto.layout();
      texto.paint(canvas, Offset(0, y - texto.height / 2));
    }

    final puntos = List.generate(12, (i) {
      final x = izquierda + ancho * i / 11;
      final y = arriba + alto * (1 - valores[i] / escala);
      return Offset(x, y);
    });

    final area = Path()
      ..moveTo(puntos.first.dx, arriba + alto);

    for (final punto in puntos) {
      area.lineTo(punto.dx, punto.dy);
    }

    area
      ..lineTo(puntos.last.dx, arriba + alto)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..color = color.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill,
    );

    final linea = Path()..moveTo(puntos.first.dx, puntos.first.dy);

    for (final punto in puntos.skip(1)) {
      linea.lineTo(punto.dx, punto.dy);
    }

    canvas.drawPath(
      linea,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    for (var i = 0; i < puntos.length; i++) {
      canvas.drawCircle(
        puntos[i],
        5,
        Paint()..color = color.withValues(alpha: 0.15),
      );
      canvas.drawCircle(puntos[i], 3, Paint()..color = color);
    }

    for (var i = 0; i < _meses.length; i++) {
      final etiqueta = TextPainter(
        text: TextSpan(
          text: _meses[i],
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      etiqueta.paint(
        canvas,
        Offset(
          puntos[i].dx - etiqueta.width / 2,
          size.height - etiqueta.height,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GraficaLinealPainter oldDelegate) {
    return oldDelegate.valores != valores ||
        oldDelegate.maximo != maximo ||
        oldDelegate.color != color;
  }
}
