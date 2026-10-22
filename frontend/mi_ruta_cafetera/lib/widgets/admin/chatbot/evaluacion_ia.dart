
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class EvaluacionIA extends StatelessWidget {
  final String? decision;
  final String motivo;
  final List<String> criterios;
  final String modelo;
  final DateTime? fechaDecision;
  final String? motivoRechazo;

  const EvaluacionIA({
    super.key,
    required this.decision,
    required this.motivo,
    this.criterios = const [],
    this.modelo = '',
    this.fechaDecision,
    this.motivoRechazo,
  });

  String get _decision => (decision ?? '').trim().toLowerCase();

  bool get _existe =>
      ['aprobado', 'rechazado', 'pendiente_manual', 'error']
          .contains(_decision);

  String get _estado {
    switch (_decision) {
      case 'aprobado':
        return 'Aprobado por IA';
      case 'rechazado':
        return 'Rechazado por IA';
      case 'pendiente_manual':
        return 'Revisión manual';
      case 'error':
        return 'Error en evaluación';
      default:
        return 'Sin evaluación';
    }
  }

  Color get _color {
    switch (_decision) {
      case 'aprobado':
        return const Color(0xFF27824D);
      case 'rechazado':
      case 'error':
        return const Color(0xFFC43F36);
      case 'pendiente_manual':
        return const Color(0xFFE9A23B);
      default:
        return AppColors.primary;
    }
  }

  IconData get _icono {
    switch (_decision) {
      case 'aprobado':
        return Icons.check_circle_rounded;
      case 'rechazado':
        return Icons.cancel_rounded;
      case 'pendiente_manual':
        return Icons.schedule_rounded;
      case 'error':
        return Icons.warning_amber_rounded;
      default:
        return Icons.smart_toy_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalles(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: _color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.smart_toy_outlined,
                color: _color,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evaluación de IA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(_icono, size: 15, color: _color),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _estado,
                            style: TextStyle(
                              color: _color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: _color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalles(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151A16),
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.78,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.smart_toy_rounded,
                          color: _color,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Detalles de la evaluación',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _color.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(_icono, color: _color, size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Resultado',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _estado,
                                    style: TextStyle(
                                      color: _color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _titulo('Motivo de la evaluación'),
                      const SizedBox(height: 8),
                      _texto(
                        _existe && motivo.trim().isNotEmpty
                            ? motivo
                            : _existe
                                ? 'No se registró un motivo para esta evaluación.'
                                : 'Este elemento no tiene una evaluación de IA registrada.',
                      ),
                      if (criterios.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _titulo('Criterios evaluados'),
                        const SizedBox(height: 10),
                        ...criterios
                            .where((e) => e.trim().isNotEmpty)
                            .map(
                              (criterio) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline_rounded,
                                      color: _color,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(child: _texto(criterio)),
                                  ],
                                ),
                              ),
                            ),
                      ],
                      if (motivoRechazo?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: 24),
                        _titulo('Motivo del rechazo registrado'),
                        const SizedBox(height: 8),
                        _texto(motivoRechazo!),
                      ],
                      if (modelo.trim().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _titulo('Modelo de IA'),
                        const SizedBox(height: 8),
                        _texto(modelo),
                      ],
                      if (fechaDecision != null) ...[
                        const SizedBox(height: 24),
                        _titulo('Fecha de evaluación'),
                        const SizedBox(height: 8),
                        _texto(_fecha(fechaDecision!)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: Color(0xFFFF9800),
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _texto(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  String _fecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }
}
