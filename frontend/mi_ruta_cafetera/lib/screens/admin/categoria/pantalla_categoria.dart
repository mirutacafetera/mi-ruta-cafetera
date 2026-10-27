import 'package:flutter/material.dart';

import '../../../controllers/admin/categoria/categoria_controller.dart';
import '../../../models/categoria_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/categoria/constantes_categoria.dart';
import '../../../widgets/admin/categoria/estado_categoria.dart';
import '../../../widgets/admin/categoria/formulario_categoria.dart';
import '../../../widgets/admin/categoria/tarjeta_categoria.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import 'pantalla_sitios_categoria.dart' as sitios;

class PantallaCategoria extends StatefulWidget {
  const PantallaCategoria({super.key});

  @override
  State<PantallaCategoria> createState() => _PantallaCategoriaState();
}

class _PantallaCategoriaState extends State<PantallaCategoria> {
  late final CategoriaController controller;

  String busqueda = '';
  bool actualizando = false;

  @override
  void initState() {
    super.initState();
    controller = CategoriaController()..cargarDatos();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void mensaje(String texto, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? AppColors.error : verdeEncabezado,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> actualizar() async {
    if (actualizando || controller.cargando) return;

    setState(() => actualizando = true);

    try {
      await controller.cargarDatos();
    } finally {
      if (mounted) setState(() => actualizando = false);
    }
  }

  Future<void> formulario([CategoriaModel? categoria]) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FormularioCategoria(
        categoria: categoria,
        controller: controller,
      ),
    );

    if (resultado == true && mounted) {
      mensaje(
        categoria == null
            ? 'Categoría creada correctamente'
            : 'Categoría actualizada correctamente',
      );
    }
  }

  Future<void> eliminar(CategoriaModel categoria) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: blancoTarjeta,
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Eliminar definitivamente "${categoria.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await controller.eliminarCategoria(categoria.id);

      if (mounted) {
        mensaje('Categoría eliminada correctamente');
      }
    } catch (e) {
      if (mounted) {
        mensaje(
          controller.error ?? 'No se pudo eliminar: $e',
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final categorias = controller.categoriasFiltradas;
        final cargandoInicial =
            controller.cargando && controller.categorias.isEmpty;
        final mostrarCarga = actualizando || cargandoInicial;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: cargandoInicial
              ? null
              : FloatingActionButton(
                  heroTag: 'fab_nueva_categoria',
                  backgroundColor: naranjaAccion,
                  foregroundColor: Colors.white,
                  tooltip: 'Nueva categoría',
                  onPressed:
                      controller.guardando ? null : () => formulario(),
                  child: const Icon(Icons.add_rounded, size: 30),
                ),
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: actualizar,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.pageHorizontalSmall,
                    AppDimensions.spacingLg,
                    AppDimensions.pageHorizontalSmall,
                    100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.eco_rounded,
                          color: verdeEncabezado,
                          size: 30,
                        ),
                        title: const Text(
                          'Explora tu ruta cafetera',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: const Text(
                          'Administra los lugares por tipo de experiencia',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingMd,
                          vertical: AppDimensions.spacingSm,
                        ),
                        decoration: BoxDecoration(
                          color: fondoContador,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.chipRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.place_rounded,
                              color: colorContador,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${controller.sitios.length} sitios turísticos',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      BarraBusqueda(
                        valor: busqueda,
                        textoAyuda: 'Buscar categoría...',
                        onChanged: (valor) {
                          setState(() => busqueda = valor);
                          controller.buscar(valor);
                        },
                        onLimpiar: () {
                          setState(() => busqueda = '');
                          controller.buscar('');
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 42,
                            decoration: BoxDecoration(
                              color: naranjaAccion,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tipos de experiencia',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF2D2C2C),
                                        fontSize: 19,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${categorias.length} disponibles',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFF454342),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Actualizar categorías',
                            onPressed: actualizar,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (mostrarCarga)
                        const Padding(
                          padding: EdgeInsets.only(top: 45),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (controller.error != null &&
                          controller.categorias.isEmpty)
                        EstadoCategoria(
                          mensaje: controller.error!,
                          error: true,
                          icono: Icons.error_outline_rounded,
                        )
                      else if (categorias.isEmpty)
                        const EstadoCategoria(
                          mensaje: 'No se encontraron categorías.',
                          icono: Icons.category_outlined,
                        )
                      else
                        ...categorias.map(
                          (categoria) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TarjetaCategoria(
                              nombre: categoria.nombre,
                              descripcion: categoria.descripcion,
                              cantidadSitios:
                                  controller.contarSitios(categoria),
                              activa: categoria.estado,
                              icono: obtenerIconoCategoria(categoria),
                              color: obtenerColorCategoria(categoria),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      sitios.PantallaSitiosCategoria(
                                    categoria: categoria,
                                  ),
                                ),
                              ),
                              onEditar: () => formulario(categoria),
                              onEliminar: () => eliminar(categoria),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}