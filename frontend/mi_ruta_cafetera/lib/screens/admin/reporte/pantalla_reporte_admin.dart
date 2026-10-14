
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../controllers/admin/reporte/reporte_controller.dart';
import '../../../models/admin/reporte_admin.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import '../../../widgets/admin/usuario/resumen_usuarios.dart';
import '../../../widgets/admin/reporte/tarjeta_reporte.dart';
import '../../../widgets/admin/reporte/filtro_estado_reporte.dart';

class PantallaReporteAdmin extends StatefulWidget {
  const PantallaReporteAdmin({super.key});

  @override
  State<PantallaReporteAdmin> createState() => _PantallaReporteAdminState();
}

class _PantallaReporteAdminState extends State<PantallaReporteAdmin> {
  late final ReporteController _controller;
  final _busquedaController = TextEditingController();
  bool _actualizandoLista = false;

  @override
  void initState() {
    super.initState();
    _controller = ReporteController()..cargarReportes();
  }

  @override
  void dispose() {
    _controller.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _recargar() async {
    if (_actualizandoLista) return;
    setState(() => _actualizandoLista = true);

    try {
      await _controller.cargarReportes();
    } finally {
      if (mounted) setState(() => _actualizandoLista = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final reportes = _controller.reportesFiltrados;
            final cargando = _actualizandoLista || _controller.cargando;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _recargar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(
                  AppDimensions.pageHorizontalSmall,
                ),
                children: [
                  EncabezadoLista(
                    titulo: 'Gestión de reportes',
                    descripcion: 'reportes recibidos',
                    textoNuevo: '',
                    cantidad: _controller.reportes.length,
                    cargando: _actualizandoLista,
                    onActualizar: _recargar,
                    onNuevo: () {},
                    mostrarBotonNuevo: false,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  ResumenUsuarios(
                    tarjetas: [
                      ResumenTarjeta(
                        titulo: 'Pendientes',
                        cantidad: _controller.contarPorEstado('pendiente'),
                        icono: Icons.mark_email_unread_rounded,
                        color: AppColors.warning,
                      ),
                      ResumenTarjeta(
                        titulo: 'En revisión',
                        cantidad: _controller.contarPorEstado('en_revision'),
                        icono: Icons.manage_search_rounded,
                        color: AppColors.info,
                      ),
                      ResumenTarjeta(
                        titulo: 'Resueltos',
                        cantidad: _controller.contarPorEstado('resuelto'),
                        icono: Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  BarraBusqueda(
                    controller: _busquedaController,
                    valor: _busquedaController.text,
                    textoAyuda: 'Buscar por asunto o usuario...',
                    onChanged: _controller.cambiarBusqueda,
                    onLimpiar: () {
                      _busquedaController.clear();
                      _controller.cambiarBusqueda('');
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  FiltroEstadoReporte(
                    seleccionado: _controller.estadoSeleccionado,
                    onChanged: _controller.cambiarEstadoFiltro,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  if (cargando)
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.75,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Reportes recibidos',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${reportes.length} resultados',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    if (_controller.error != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMd,
                        ),
                        child: Text(
                          _controller.error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    if (reportes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(AppDimensions.spacingXxl),
                        child: Center(
                          child: Text(
                            'No se encontraron reportes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...reportes.map(
                        (reporte) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacingMd,
                          ),
                          child: TarjetaReporte(
                            reporte: reporte,
                            onTap: () => _abrirReporte(reporte),
                          ),
                        ),
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

  Future<void> _abrirReporte(ReporteAdmin reporte) async {
    final respuesta = TextEditingController(
      text: reporte.respuestaAdmin ?? '',
    );
    String estado = reporte.estado;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, actualizarDialogo) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Detalle del reporte'),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reporte.asunto,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Usuario: ${reporte.nombreCompleto.isEmpty ? 'Sin nombre' : reporte.nombreCompleto}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Correo: ${reporte.correoUsuario.isEmpty ? 'No disponible' : reporte.correoUsuario}',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mensaje del usuario',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(reporte.mensaje),
                  const SizedBox(height: 18),
                  const Text(
                    'Estado del reporte',
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
                  const SizedBox(height: 18),
                  const Text(
                    'Respuesta del administrador',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: respuesta,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una respuesta...',
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
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (guardar == true && mounted) {
      final correcto = await _controller.responderReporte(
        id: reporte.id,
        estado: estado,
        respuestaAdmin: respuesta.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              correcto
                  ? 'Reporte actualizado correctamente.'
                  : _controller.error ?? 'No se pudo actualizar el reporte.',
            ),
          ),
        );
      }
    }

    respuesta.dispose();
  }
}
