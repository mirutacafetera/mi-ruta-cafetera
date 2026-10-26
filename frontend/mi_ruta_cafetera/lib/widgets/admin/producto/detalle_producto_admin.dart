import 'package:flutter/material.dart';

import '../../../models/admin/admin_producto_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../fondo_admin.dart';
import '../contenido/galeria_imagenes.dart';
import '../actividades/botones_navegacion_admin.dart';
import '../actividades/componentes_detalle_actividad.dart';
import '../actividades/dialogo_rechazo_actividad.dart';
import '../actividades/galeria_detalle_actividad.dart';
import '../actividades/tarjeta_principal_actividad.dart';

class DetalleProductoAdmin extends StatefulWidget {
  final AdminProductoModel producto;
  final bool procesando;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final ValueChanged<String>? onConfirmarRechazo;
  final Future<void> Function()? onActualizar;

  // Menú lateral existente del panel de administración.
  final Widget menuLateral;

  const DetalleProductoAdmin({
    super.key,
    required this.producto,
    required this.procesando,
    required this.onAprobar,
    required this.onRechazar,
    this.onConfirmarRechazo,
    this.onActualizar,
    required this.menuLateral,
  });

  @override
  State<DetalleProductoAdmin> createState() =>
      _DetalleProductoAdminState();
}

class _DetalleProductoAdminState extends State<DetalleProductoAdmin> {
  bool _actualizando = false;

  final GlobalKey<ScaffoldState> _claveScaffold =
      GlobalKey<ScaffoldState>();

  static const Color _terracota = Color(0xFFB85C50);

  List<String> get _fotos {
    final fotos = <String>[];
    final principal = widget.producto.imagenPrincipal.trim();

    if (principal.isNotEmpty) {
      fotos.add(principal);
    }

    for (final imagen in widget.producto.imagenes) {
      final url = imagen.trim();

      if (url.isNotEmpty && !fotos.contains(url)) {
        fotos.add(url);
      }
    }

    return fotos;
  }

  Future<void> _actualizarDetalle() async {
    if (_actualizando || widget.onActualizar == null) return;

    setState(() {
      _actualizando = true;
    });

    try {
      await widget.onActualizar!();
    } finally {
      if (mounted) {
        setState(() {
          _actualizando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotos = _fotos;

    return FondoAdmin(
      child: Scaffold(
        key: _claveScaffold,
        backgroundColor: Colors.transparent,
        drawer: widget.menuLateral,
        body: Column(
          children: [
            _encabezadoPrincipal(),
            _encabezadoDetalle(context),
            Expanded(
              child: _actualizando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.pageHorizontalSmall,
                        AppDimensions.spacingSm,
                        AppDimensions.pageHorizontalSmall,
                        AppDimensions.spacingXl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TarjetaPrincipalActividad(
                            titulo: widget.producto.nombre.trim().isEmpty
                                ? 'Producto sin nombre'
                                : widget.producto.nombre,
                            descripcion: widget.producto.descripcion,
                            imagenUrl:
                                fotos.isNotEmpty ? fotos.first : null,
                            estado: _estadoParaTarjeta(
                              widget.producto.estadoPublicacion,
                            ),
                          ),

                          const SizedBox(height: 16),

                          TarjetaDetalleActividad(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TituloDetalleActividad(
                                    texto: 'Información del producto',
                                    icono: Icons.inventory_2_outlined,
                                  ),
                                  const SizedBox(height: 22),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final ancho = constraints.maxWidth;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          DatoDetalleActividad(
                                            ancho: ancho,
                                            icono: Icons.payments_outlined,
                                            titulo: 'Precio del producto',
                                            valor: _precio(
                                              widget.producto.precio,
                                            ),
                                          ),

                                          const SizedBox(height: 22),

                                          DatoDetalleActividad(
                                            ancho: ancho,
                                            icono: Icons.storefront_outlined,
                                            titulo: 'Sitio turístico',
                                            valor: widget.producto.sitioNombre
                                                    .trim()
                                                    .isEmpty
                                                ? 'No especificado'
                                                : widget.producto.sitioNombre,
                                          ),

                                          const SizedBox(height: 22),

                                          DatoDetalleActividad(
                                            ancho: ancho,
                                            icono:
                                                Icons.check_circle_outline,
                                            titulo: 'Disponibilidad',
                                            valor: widget.producto.activo
                                                ? 'Activo'
                                                : 'Inactivo',
                                          ),

                                          const SizedBox(height: 22),

                                          DatoDetalleActividad(
                                            ancho: ancho,
                                            icono: Icons.event_outlined,
                                            titulo: 'Fecha de creación',
                                            valor:
                                                widget.producto.createdAt ==
                                                        null
                                                    ? 'No disponible'
                                                    : FormateadorFechaActividad
                                                        .formatear(
                                                        widget.producto
                                                            .createdAt!,
                                                      ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          GaleriaDetalleActividad(
                            imagenes: fotos,
                            onMostrarGaleria: (imagenes, indice) {
                              GaleriaImagenes.mostrar(
                                context,
                                imagenes,
                                indice,
                              );
                            },
                          ),

                          if (widget.producto.estaPendiente) ...[
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: widget.procesando
                                        ? null
                                        : () {
                                            mostrarDialogoRechazoAdmin(
                                              context: context,
                                              titulo: 'Motivo de rechazo *',
                                              textoAyuda:
                                                  'Explica por qué se rechaza el producto...',
                                              onRechazar: (motivo) {
                                                if (widget
                                                        .onConfirmarRechazo !=
                                                    null) {
                                                  widget.onConfirmarRechazo!(
                                                    motivo,
                                                  );
                                                } else {
                                                  widget.onRechazar();
                                                }
                                              },
                                            );
                                          },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Rechazar'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _terracota,
                                      side: const BorderSide(
                                        color: _terracota,
                                        width: 1.3,
                                      ),
                                      minimumSize:
                                          const Size.fromHeight(48),
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: widget.procesando
                                        ? null
                                        : widget.onAprobar,
                                    icon: const Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 20,
                                    ),
                                    label: const Text('Aprobar'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      minimumSize:
                                          const Size.fromHeight(48),
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ENCABEZADO VERDE CON MENÚ LATERAL.
  Widget _encabezadoPrincipal() {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              const SizedBox(width: 12),

              IconButton(
                tooltip: 'Abrir menú',
                onPressed: () {
                  _claveScaffold.currentState?.openDrawer();
                },
                icon: const Icon(
                  Icons.menu_rounded,
                  color: AppColors.white,
                  size: 27,
                ),
              ),

              const Expanded(
                child: Center(
                  child: Text(
                    'Productos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 51),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezadoDetalle(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.adminBorder.withValues(alpha: 0.65),
          ),
        ),
      ),
      child: Row(
        children: [
          BotonNavegacionAdmin(
            icono: Icons.arrow_back_rounded,
            tooltip: 'Volver',
            onPressed: () => Navigator.of(context).maybePop(),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Detalles del producto',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Información y gestión del producto',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          BotonNavegacionAdmin(
            icono: Icons.refresh_rounded,
            tooltip: 'Actualizar producto',
            onPressed: _actualizando || widget.procesando
                ? null
                : _actualizarDetalle,
          ),
        ],
      ),
    );
  }

  String _estadoParaTarjeta(String estado) {
    switch (estado.toLowerCase().trim()) {
      case 'aprobado':
      case 'aprobada':
      case 'aprobado_manual':
      case 'aprobada_manual':
        return 'aprobada';

      case 'rechazado':
      case 'rechazada':
      case 'rechazado_manual':
      case 'rechazada_manual':
        return 'rechazada';

      case 'pendiente':
      case 'pendiente_revision':
        return 'pendiente_revision';

      default:
        return estado;
    }
  }

  String _precio(double precio) {
    final numero = precio.toStringAsFixed(0);
    final buffer = StringBuffer();

    for (var i = 0; i < numero.length; i++) {
      buffer.write(numero[i]);

      if (i < numero.length - 1 &&
          (numero.length - i - 1) % 3 == 0) {
        buffer.write('.');
      }
    }

    return '\$ $buffer COP';
  }
}