
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class RevisionAdministrador extends StatelessWidget {
  final String? estado;
  final String motivo;
  final String? nombreAdministrador;
  final DateTime? fechaRevision;

  const RevisionAdministrador({
    super.key,
    required this.estado,
    required this.motivo,
    this.nombreAdministrador,
    this.fechaRevision,
  });

  String get _estado => (estado ?? '').trim().toLowerCase();

  bool get _tieneRevision =>
      _estado == 'aprobado' ||
      _estado == 'rechazado' ||
      _estado == 'aprobado_manual' ||
      _estado == 'rechazado_manual';

  bool get _aprobado =>
      _estado == 'aprobado' || _estado == 'aprobado_manual';

  bool get _rechazado =>
      _estado == 'rechazado' || _estado == 'rechazado_manual';

  String get _estadoLegible {
    if (!_tieneRevision) return 'Sin revisión manual';
    return _aprobado ? 'Aprobado manualmente' : 'Rechazado manualmente';
  }

  Color get _color {
    if (_rechazado) return AppColors.error;
    if (_aprobado) return AppColors.primary;
    return AppColors.secondary;
  }

  IconData get _icono {
    if (_rechazado) return Icons.cancel_rounded;
    if (_aprobado) return Icons.check_circle_rounded;
    return Icons.person_search_outlined;
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
                Icons.admin_panel_settings_outlined,
                color: AppColors.secondary,
                size: 23,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revisión del administrador',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(_icono, size: 15, color: _color),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _estadoLegible,
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
    final alturaPantalla = MediaQuery.of(context).size.height;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return SizedBox(
          height: alturaPantalla * 0.58,
          child: Container(
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
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: _color,
                          size: AppDimensions.iconLg,
                        ),
                      ),
                      const SizedBox(
                        width: AppDimensions.spacingMd,
                      ),
                      const Expanded(
                        child: Text(
                          'Detalles de la revisión',
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
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.spacingXl,
                      AppDimensions.spacingXl,
                      AppDimensions.spacingXl,
                      32,
                    ),
                    children: [
                      _tarjetaResultado(),
                      const SizedBox(
                        height: AppDimensions.spacingXl,
                      ),
                      _titulo('Motivo registrado'),
                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),
                      _texto(
                        _tieneRevision
                            ? motivo.trim().isNotEmpty
                                ? motivo
                                : 'No se registró un motivo para esta decisión.'
                            : 'Todavía no hay una revisión manual registrada.',
                      ),
                      if ((nombreAdministrador ?? '')
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: AppDimensions.spacingXl,
                        ),
                        _titulo('Administrador responsable'),
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
                        _texto(nombreAdministrador!),
                      ],
                      if (fechaRevision != null) ...[
                        const SizedBox(
                          height: AppDimensions.spacingXl,
                        ),
                        _titulo('Fecha de revisión'),
                        const SizedBox(
                          height: AppDimensions.spacingSm,
                        ),
                        _texto(_fecha(fechaRevision!)),
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
          Icon(
            _rechazado
                ? Icons.cancel_rounded
                : Icons.check_circle_rounded,
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
                  'Resultado de la revisión',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),
                Text(
                  _estadoLegible,
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
