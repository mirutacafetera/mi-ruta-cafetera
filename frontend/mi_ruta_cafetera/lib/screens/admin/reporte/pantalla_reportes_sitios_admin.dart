import 'package:flutter/material.dart';

import '../../../controllers/admin/reporte/reportes_sitios_controller.dart';
import '../../../models/admin/reporte_sitio_admin.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class PantallaReportesSitiosAdmin extends StatefulWidget {
  const PantallaReportesSitiosAdmin({super.key});

  @override
  State<PantallaReportesSitiosAdmin> createState() =>
      _PantallaReportesSitiosAdminState();
}

class _PantallaReportesSitiosAdminState
    extends State<PantallaReportesSitiosAdmin> {
  late final ReportesSitiosController _controller;
  final TextEditingController _busqueda = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ReportesSitiosController()..cargarReportes();
  }

  @override
  void dispose() {
    _controller.dispose();
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _recargar() => _controller.cargarReportes();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final reportes = _controller.reportesFiltrados;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _recargar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(
                  AppDimensions.pageHorizontalSmall,
                ),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reportes de sitios',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Solicitudes, problemas y sugerencias de sitios turísticos',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Actualizar',
                        onPressed: _controller.cargando ? null : _recargar,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),

                  if (_controller.error != null)
                    _mensajeError(_controller.error!),

                  Row(
                    children: [
                      Expanded(
                        child: _resumen(
                          'Total',
                          _controller.reportes.length,
                          Icons.inbox_rounded,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _resumen(
                          'Pendientes',
                          _controller.contarEstado('pendiente'),
                          Icons.mark_email_unread_rounded,
                          AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _resumen(
                          'Resueltos',
                          _controller.contarEstado('resuelto'),
                          Icons.check_circle_rounded,
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingLg),

                  TextField(
                    controller: _busqueda,
                    onChanged: _controller.cambiarBusqueda,
                    decoration: InputDecoration(
                      hintText: 'Buscar por sitio, asunto o mensaje...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _busqueda.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _busqueda.clear();
                                _controller.cambiarBusqueda('');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spacingMd),

                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _controller.estadoSeleccionado,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos los estados'),
                            ),
                            DropdownMenuItem(
                              value: 'pendiente',
                              child: Text('Pendiente'),
                            ),
                            DropdownMenuItem(
                              value: 'en_revision',
                              child: Text('En revisión'),
                            ),
                            DropdownMenuItem(
                              value: 'resuelto',
                              child: Text('Resuelto'),
                            ),
                          ],
                          onChanged: (valor) {
                            if (valor != null) {
                              _controller.cambiarEstado(valor);
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _controller.tipoSeleccionado,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de reporte',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos los tipos'),
                            ),
                            DropdownMenuItem(
                              value: 'problema',
                              child: Text('Problema'),
                            ),
                            DropdownMenuItem(
                              value: 'sugerencia',
                              child: Text('Sugerencia'),
                            ),
                            DropdownMenuItem(
                              value: 'mejora',
                              child: Text('Mejora'),
                            ),
                            DropdownMenuItem(
                              value: 'otro',
                              child: Text('Otro'),
                            ),
                          ],
                          onChanged: (valor) {
                            if (valor != null) {
                              _controller.cambiarTipo(valor);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingLg),

                  if (_controller.cargando)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (reportes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'No se encontraron reportes de sitios.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      '${reportes.length} reporte(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    for (final reporte in reportes)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMd,
                        ),
                        child: _tarjeta(reporte),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _resumen(String titulo, int cantidad, IconData icono, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icono, color: color),
            const SizedBox(height: 8),
            Text(
              '$cantidad',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(ReporteSitioAdmin reporte) {
    final colorEstado = switch (reporte.estado) {
      'resuelto' => AppColors.success,
      'en_revision' => AppColors.info,
      _ => AppColors.warning,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirDetalle(reporte),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(reporte.tipoLegible),
                    avatar: const Icon(Icons.flag_outlined, size: 16),
                  ),
                  Chip(
                    label: Text(reporte.estadoLegible),
                    backgroundColor: colorEstado.withValues(alpha: 0.12),
                    labelStyle: TextStyle(
                      color: colorEstado,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                reporte.asunto,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reporte.nombreSitio,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                reporte.mensaje,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _abrirDetalle(reporte),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Ver y responder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mensajeError(String mensaje) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(mensaje, style: const TextStyle(color: AppColors.error)),
    );
  }

  Future<void> _abrirDetalle(ReporteSitioAdmin reporte) async {
    final respuesta = TextEditingController(text: reporte.respuestaAdmin ?? '');
    String estado = reporte.estado;
    bool guardandoLocal = false;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, actualizarDialogo) => AlertDialog(
          title: const Text('Reporte del sitio'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reporte.nombreSitio,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    reporte.asunto,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Tipo: ${reporte.tipoLegible}'),
                  const SizedBox(height: 12),
                  const Text(
                    'Descripción del sitio',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(reporte.mensaje),
                  const SizedBox(height: 20),
                  const Text(
                    'Estado',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: estado,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pendiente',
                        child: Text('Pendiente'),
                      ),
                      DropdownMenuItem(
                        value: 'en_revision',
                        child: Text('En revisión'),
                      ),
                      DropdownMenuItem(
                        value: 'resuelto',
                        child: Text('Resuelto'),
                      ),
                    ],
                    onChanged: (valor) {
                      if (valor != null) {
                        actualizarDialogo(() => estado = valor);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Respuesta del administrador',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: respuesta,
                    maxLength: 3000,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Escribe la respuesta para el sitio...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: guardandoLocal
                  ? null
                  : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: guardandoLocal
                  ? null
                  : () async {
                      if (respuesta.text.trim().length > 3000) return;

                      actualizarDialogo(() => guardandoLocal = true);

                      final correcto = await _controller.responderReporte(
                        id: reporte.id,
                        estado: estado,
                        respuestaAdmin: respuesta.text.trim(),
                      );

                      if (!dialogContext.mounted) return;

                      if (correcto) {
                        Navigator.pop(dialogContext, true);
                      } else {
                        actualizarDialogo(() => guardandoLocal = false);
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              _controller.error ??
                                  'No se pudo guardar la respuesta.',
                            ),
                          ),
                        );
                      }
                    },
              child: guardandoLocal
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    respuesta.dispose();

    if (guardar == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte del sitio actualizado.')),
      );
    }
  }
}
