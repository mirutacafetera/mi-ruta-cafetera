
import 'package:flutter/material.dart';

import '../../../controllers/admin/reporte/reportes_sitios_controller.dart';
import '../../../models/admin/reporte_sitio_admin.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/reporte/filtro_estado_reporte.dart';
import '../../../widgets/admin/reporte/tarjeta_reporte.dart';
import '../../../widgets/admin/reporte/reporte_sitio_turistico/resumen_reporte.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';

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

  static const Color _cafe = Color(0xFFB58A70);

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
              color: AppColors.secondary,
              onRefresh: _recargar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalSmall,
                ),
                children: [
                  _encabezado(),

                  const SizedBox(height: AppDimensions.spacingMd),

                  if (_controller.error != null)
                    _mensajeError(_controller.error!),

                  ResumenReporte(
                    total: _controller.reportes.length,
                    pendientes: _controller.contarEstado('pendiente'),
                    enRevision: _controller.contarEstado('en_revision'),
                    resueltos: _controller.contarEstado('resuelto'),
                    estadoSeleccionado: _controller.estadoSeleccionado,
                    onEstadoSeleccionado: _controller.cambiarEstado,
                  ),

                  const SizedBox(height: AppDimensions.spacingLg),

                  _campoBusqueda(),

                  const SizedBox(height: AppDimensions.spacingMd),

                  FiltroEstadoReporte(
                    seleccionado: _controller.estadoSeleccionado,
                    onChanged: _controller.cambiarEstado,
                  ),

                  const SizedBox(height: AppDimensions.spacingLg),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Reportes recibidos',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${reportes.length} resultado(s)',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingMd),

                  if (_controller.cargando)
                    const Padding(
                      padding: EdgeInsets.all(AppDimensions.spacingXl),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary,
                        ),
                      ),
                    )
                  else if (reportes.isEmpty)
                    _estadoVacio()
                  else
                    ...reportes.map(
                      (reporte) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMd,
                        ),
                        child: _tarjetaSitio(reporte),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _encabezado() {
  return EncabezadoLista(
    titulo: '',
    descripcion: 'reportes recibidos',
    textoNuevo: '',
    cantidad: _controller.reportes.length,
    cargando: _controller.cargando,
    mostrarBotonNuevo: false,
    onActualizar: _recargar,
    onNuevo: () {},
  );
}

  Widget _campoBusqueda() {
    return TextField(
      controller: _busqueda,
      onChanged: _controller.cambiarBusqueda,
      decoration: InputDecoration(
        hintText: 'Buscar por sitio, asunto o mensaje...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.secondary,
        ),
        suffixIcon: _busqueda.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar búsqueda',
                onPressed: () {
                  _busqueda.clear();
                  _controller.cambiarBusqueda('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        border: _bordeCafe(),
        enabledBorder: _bordeCafe(),
        focusedBorder: _bordeCafe(width: 1.5),
      ),
    );
  }

  OutlineInputBorder _bordeCafe({double width = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      borderSide: BorderSide(color: _cafe, width: width),
    );
  }

  Widget _tarjetaSitio(ReporteSitioAdmin reporte) {
    return TarjetaReporte(
      reporteSitio: reporte,
      onTap: () => _abrirDetalle(reporte),
    );
  }

  Widget _estadoVacio() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 44,
            color: _cafe,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            _controller.error != null
                ? 'No fue posible cargar los reportes.'
                : 'No se encontraron reportes.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          const Text(
            'Prueba cambiando la búsqueda o el estado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          if (_controller.error != null)
            TextButton.icon(
              onPressed: _recargar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Intentar de nuevo'),
            ),
        ],
      ),
    );
  }

  Widget _mensajeError(String mensaje) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        mensaje,
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }

  Future<void> _abrirDetalle(ReporteSitioAdmin reporte) async {
    final respuesta = TextEditingController(
      text: reporte.respuestaAdmin ?? '',
    );

    String estado = reporte.estado;
    bool guardando = false;

    OutlineInputBorder bordeCampo({double width = 1.2}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _cafe, width: width),
      );
    }

    try {
      final resultado = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, actualizarDialogo) {
              return Dialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(
                    color: _cafe,
                    width: 1.3,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 430,
                    maxHeight: 720,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      26,
                      26,
                      26,
                      22,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalle del reporte',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          reporte.asunto,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Sitio turístico',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          reporte.nombreSitio,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Descripción del reporte',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          reporte.mensaje,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 26),

                        const Text(
                          'Estado del reporte',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        DropdownButtonFormField<String>(
                          initialValue: estado,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            border: bordeCampo(),
                            enabledBorder: bordeCampo(),
                            focusedBorder: bordeCampo(width: 1.5),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.secondary,
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
                          onChanged: guardando
                              ? null
                              : (valor) {
                                  if (valor != null) {
                                    actualizarDialogo(() {
                                      estado = valor;
                                    });
                                  }
                                },
                        ),

                        const SizedBox(height: 26),

                        const Text(
                          'Respuesta del administrador',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: respuesta,
                          enabled: !guardando,
                          maxLength: 3000,
                          minLines: 4,
                          maxLines: 6,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            height: 1.4,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Escribe una respuesta...',
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            alignLabelWithHint: true,
                            counterText: '',
                            contentPadding: const EdgeInsets.all(20),
                            border: bordeCampo(),
                            enabledBorder: bordeCampo(),
                            focusedBorder: bordeCampo(width: 1.5),
                            disabledBorder: bordeCampo(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: guardando
                                  ? null
                                  : () => Navigator.pop(
                                        dialogContext,
                                        false,
                                      ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            FilledButton(
                              onPressed: guardando
                                  ? null
                                  : () async {
                                      actualizarDialogo(() {
                                        guardando = true;
                                      });

                                      final correcto =
                                          await _controller.responderReporte(
                                        id: reporte.id,
                                        estado: estado,
                                        respuestaAdmin: respuesta.text.trim(),
                                      );

                                      if (!dialogContext.mounted) return;

                                      if (correcto) {
                                        Navigator.pop(dialogContext, true);
                                      } else {
                                        actualizarDialogo(() {
                                          guardando = false;
                                        });

                                        ScaffoldMessenger.of(
                                          dialogContext,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              _controller.error ??
                                                  'No se pudo guardar la respuesta.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    AppColors.secondary.withValues(
                                  alpha: 0.6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                  side: const BorderSide(
                                    color: _cafe,
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: guardando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Guardar',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );

      if (resultado == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Reporte del sitio actualizado correctamente.',
            ),
          ),
        );
      }
    } finally {
      respuesta.dispose();
    }
  }
}
