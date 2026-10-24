
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
  State<PantallaReporteAdmin> createState() =>
      _PantallaReporteAdminState();
}

class _PantallaReporteAdminState extends State<PantallaReporteAdmin> {
  late final ReporteController _controller;

  final TextEditingController _busquedaController =
      TextEditingController();

  bool _actualizandoLista = false;

  static const Color _cafe = Color(0xFFB58A70);
  static const Color _naranja = Color(0xFFF58220);

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
    if (_actualizandoLista || _controller.cargando) return;

    setState(() => _actualizandoLista = true);

    try {
      await _controller.cargarReportes();
    } finally {
      if (mounted) {
        setState(() => _actualizandoLista = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final reportes = _controller.reportesFiltrados;
            final cargando =
                _actualizandoLista || _controller.cargando;

            return RefreshIndicator(
              color: _naranja,
              onRefresh: _recargar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(
                  AppDimensions.pageHorizontalSmall,
                ),
                children: [
                  EncabezadoLista(
                    titulo: '',
                    descripcion: 'reportes recibidos',
                    textoNuevo: '',
                    cantidad: _controller.reportes.length,
                    cargando: cargando,
                    mostrarBotonNuevo: false,
                    onActualizar: _recargar,
                    onNuevo: () {},
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingLg,
                  ),
                  ResumenUsuarios(
                    tarjetas: [
                      ResumenTarjeta(
                        titulo: 'Todos',
                        cantidad: _controller.reportes.length,
                        icono: Icons.groups_rounded,
                        color: AppColors.primary,
                      ),
                      ResumenTarjeta(
                        titulo: 'Pendientes',
                        cantidad: _controller.contarPorEstado(
                          'pendiente',
                        ),
                        icono: Icons.mark_email_unread_rounded,
                        color: AppColors.warning,
                      ),
                      ResumenTarjeta(
                        titulo: 'En revisión',
                        cantidad: _controller.contarPorEstado(
                          'en_revision',
                        ),
                        icono: Icons.manage_search_rounded,
                        color: AppColors.info,
                      ),
                      ResumenTarjeta(
                        titulo: 'Resueltos',
                        cantidad: _controller.contarPorEstado(
                          'resuelto',
                        ),
                        icono: Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingLg,
                  ),
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
                  const SizedBox(
                    height: AppDimensions.spacingMd,
                  ),
                  FiltroEstadoReporte(
                    seleccionado: _controller.estadoSeleccionado,
                    onChanged: _controller.cambiarEstadoFiltro,
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingLg,
                  ),
                  if (cargando)
                    SizedBox(
                      height:
                          MediaQuery.sizeOf(context).height * 0.45,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: _naranja,
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
                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),
                    if (_controller.error != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMd,
                        ),
                        child: Text(
                          _controller.error!,
                          style: const TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    if (reportes.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(
                          AppDimensions.spacingXxl,
                        ),
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

    OutlineInputBorder bordeCafe({double ancho = 1.2}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: _cafe,
          width: ancho,
        ),
      );
    }

    try {
      final guardar = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, actualizarDialogo) {
              return Dialog(
                backgroundColor: AppColors.creamLight,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: const BorderSide(
                    color: _cafe,
                    width: 1.3,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 370,
                    maxHeight: 620,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      16,
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
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Text(
                          'Usuario',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reporte.nombreCompleto.isEmpty
                              ? 'Usuario sin nombre'
                              : reporte.nombreCompleto,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Correo electrónico',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          reporte.correoUsuario.isEmpty
                              ? 'Correo no disponible'
                              : reporte.correoUsuario,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Mensaje del usuario',
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
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            border: bordeCafe(),
                            enabledBorder: bordeCafe(),
                            focusedBorder: bordeCafe(),
                            disabledBorder: bordeCafe(),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _naranja,
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
                            border: bordeCafe(),
                            enabledBorder: bordeCafe(),
                            focusedBorder: bordeCafe(),
                            disabledBorder: bordeCafe(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                  false,
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: _naranja,
                                padding:
                                    const EdgeInsets.symmetric(
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
                              onPressed: () {
                                Navigator.pop(
                                  dialogContext,
                                  true,
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: _naranja,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(28),
                                  side: const BorderSide(
                                    color: _cafe,
                                    width: 0.8,
                                  ),
                                ),
                              ),
                              child: const Text(
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

      // Cancelar cierra el diálogo sin guardar cambios.
      if (guardar != true || !mounted) return;

      final correcto = await _controller.responderReporte(
        id: reporte.id,
        estado: estado,
        respuestaAdmin: respuesta.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            correcto
                ? 'Reporte actualizado correctamente.'
                : _controller.error ??
                    'No se pudo actualizar el reporte.',
          ),
        ),
      );
    } finally {
      respuesta.dispose();
    }
  }
}
