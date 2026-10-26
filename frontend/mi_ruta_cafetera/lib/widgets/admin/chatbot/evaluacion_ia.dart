
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

  bool get _aprobado => _decision == 'aprobado';

  bool get _rechazado =>
      _decision == 'rechazado' || _decision == 'error';

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

  // Mismo color de texto que el aprobado manual.
  Color get _color {
    if (_rechazado) return AppColors.error;
    if (_aprobado) return AppColors.primary;
    return AppColors.secondary;
  }

  // Mismo icono de aprobado que el de revisión del administrador.
  IconData get _icono {
    if (_rechazado) return Icons.cancel_rounded;
    if (_aprobado) return Icons.check_circle_rounded;
    if (_decision == 'pendiente_manual') {
      return Icons.schedule_rounded;
    }
    return Icons.smart_toy_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _mostrarDetalles(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.creamLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.adminBorder,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.secondary,
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
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _icono,
                          size: 15,
                          color: _color,
                        ),
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
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: AppColors.secondary,
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
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.sheetRadius),
        ),
      ),
      builder: (context) {
        final alturaPantalla = MediaQuery.of(context).size.height;

        return Container(
          constraints: BoxConstraints(
            maxHeight: alturaPantalla * 0.65,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.sheetRadius),
            ),
            border: const Border(
              top: BorderSide(
                color: AppColors.adminBorder,
                width: 2,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _indicador(),

                Padding(
                  padding: const EdgeInsets.all(
                    AppDimensions.spacingXl,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                        child: const Icon(
                          Icons.smart_toy_outlined,
                          color: AppColors.primary,
                          size: AppDimensions.iconLg,
                        ),
                      ),
                      const SizedBox(
                        width: AppDimensions.spacingMd,
                      ),
                      const Expanded(
                        child: Text(
                          'Detalles de la evaluación',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Cerrar',
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.coffee,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(
                  color: AppColors.adminBorder,
                  height: 1,
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingXl,
                    ),
                    children: [
                      _tarjetaResultado(),

                      const SizedBox(
                        height: AppDimensions.spacingXl,
                      ),

                      _titulo('Motivo de la evaluación'),
                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),
                      _texto(
                        _existe && motivo.trim().isNotEmpty
                            ? motivo
                            : _existe
                                ? 'No se registró un motivo para esta evaluación.'
                                : 'Este elemento no tiene una evaluación de IA registrada.',
                      ),

                      if (criterios.any(
                        (criterio) => criterio.trim().isNotEmpty,
                      )) ...[
                        const SizedBox(
                          height: AppDimensions.spacingXl,
                        ),
                        _titulo('Criterios evaluados'),
                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),
                        ...criterios
                            .where(
                              (criterio) => criterio.trim().isNotEmpty,
                            )
                            .map(
                              (criterio) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.spacingMd,
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      _icono,
                                      color: _color,
                                      size: AppDimensions.iconMd,
                                    ),
                                    const SizedBox(
                                      width: AppDimensions.spacingMd,
                                    ),
                                    Expanded(
                                      child: _texto(criterio),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      ],

                      if (motivoRechazo?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(
                          height: AppDimensions.spacingXl,
                        ),
                        _titulo('Motivo del rechazo registrado'),
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
                        _texto(motivoRechazo!),
                      ],

                      

                      if (fechaDecision != null) ...[
                        const SizedBox(
                          height: AppDimensions.spacingXl,
                        ),
                        _titulo('Fecha de evaluación'),
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
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

  Widget _indicador() {
    return Container(
      width: 42,
      height: 5,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.adminBorder,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusFull,
        ),
      ),
    );
  }

  Widget _tarjetaResultado() {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color: AppColors.adminBorder,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono relleno, igual al de aprobación manual.
          Icon(
            _icono,
            color: _color,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultado',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),
                Text(
                  _estado,
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: AppColors.secondary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _texto(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.6,
      ),
    );
  }

  String _fecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}
