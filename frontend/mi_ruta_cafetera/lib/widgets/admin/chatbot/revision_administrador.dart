
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

  String get _estadoLegible {
    if (!_tieneRevision) return 'Sin revisión manual';
    return _aprobado ? 'Aprobado manualmente' : 'Rechazado manualmente';
  }

  Color get _color {
    if (!_tieneRevision) return AppColors.primary;
    return _aprobado
        ? const Color(0xFF27824D)
        : const Color(0xFFC43F36);
  }

  IconData get _icono {
    if (!_tieneRevision) return Icons.person_search_rounded;
    return _aprobado
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
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
            color: _color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: _color,
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
            heightFactor: 0.72,
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
                          Icons.admin_panel_settings_rounded,
                          color: _color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Detalles de la revisión',
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
                                    'Resultado de la revisión',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _estadoLegible,
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
                      _titulo('Motivo registrado'),
                      const SizedBox(height: 8),
                      _texto(
                        _tieneRevision
                            ? motivo.trim().isNotEmpty
                                ? motivo
                                : 'No se registró un motivo para esta decisión.'
                            : 'Todavía no hay una revisión manual registrada.',
                      ),
                      if ((nombreAdministrador ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _titulo('Administrador responsable'),
                        const SizedBox(height: 8),
                        _texto(nombreAdministrador!),
                      ],
                      if (fechaRevision != null) ...[
                        const SizedBox(height: 24),
                        _titulo('Fecha de revisión'),
                        const SizedBox(height: 8),
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
