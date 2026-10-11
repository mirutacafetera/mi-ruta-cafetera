
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../models/categoria_model.dart';
import '../../../controllers/admin/categoria/categoria_controller.dart';
import '../../../widgets/admin/categoria/estado_categoria.dart';
import '../../../widgets/admin/categoria/selector_iconos_categoria.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import 'pantalla_sitios_categoria.dart' as sitios_categoria;

// ============================================================
// COLORES
// ============================================================

const Color verdeEncabezado = Color(0xFF174B38);
const Color fondoCrema = Color(0xFFF4F0E7);
const Color naranjaAccion = Color(0xFFFF781F);
const Color verdeEstado = Color(0xFF248342);
const Color fondoEstado = Color(0xFFE6F4E8);
const Color blancoTarjeta = Color(0xFFFFFEFC);
const Color colorTextoSuave = Color(0xFF7D867E);
const Color fondoContador = Color(0xFFECE4D6);
const Color colorContador = Color(0xFF76583A);

// ============================================================
// ICONOS Y COLORES DE CATEGORÍAS
// ============================================================

const Map<String, IconData> iconosCategoria = {
  'coffee_rounded': Icons.coffee_rounded,
  'palette_rounded': Icons.palette_rounded,
  'restaurant_rounded': Icons.restaurant_rounded,
  'hotel_rounded': Icons.hotel_rounded,
  'family_restroom_rounded': Icons.family_restroom_rounded,
  'park_rounded': Icons.park_rounded,
  'account_balance_rounded': Icons.account_balance_rounded,
  'hiking_rounded': Icons.hiking_rounded,
  'landscape_rounded': Icons.landscape_rounded,
  'flutter_dash_rounded': Icons.flutter_dash,
  'filter_vintage_rounded': Icons.filter_vintage_rounded,
  'pets_rounded': Icons.pets_rounded,
  'directions_walk_rounded': Icons.directions_walk,
  'directions_bike_rounded': Icons.directions_bike,
  'yard_rounded': Icons.yard,
  'waves_rounded': Icons.waves,
  'nature_people_rounded': Icons.nature_people,
  'location_on': Icons.location_on,
  'visibility_rounded': Icons.visibility_rounded,
  'eco_rounded': Icons.eco_rounded,
};

const Map<String, Color> coloresIconosCategoria = {
  'coffee_rounded': Color(0xFFB86B2C),
  'palette_rounded': Color(0xFF9B5C8F),
  'restaurant_rounded': Color(0xFFD65C45),
  'hotel_rounded': Color(0xFF4D7FA3),
  'family_restroom_rounded': Color(0xFFD39A35),
  'park_rounded': Color(0xFF4E9568),
  'account_balance_rounded': Color(0xFF8B6547),
  'hiking_rounded': Color(0xFF2E7D68),
  'landscape_rounded': Color(0xFF527FA6),
  'flutter_dash_rounded': Color(0xFF247BA0),
  'filter_vintage_rounded': Color(0xFFB76E9B),
  'pets_rounded': Color(0xFFA66A45),
  'directions_walk_rounded': Color(0xFF53856A),
  'directions_bike_rounded': Color(0xFFC47732),
  'yard_rounded': Color(0xFF829447),
  'waves_rounded': Color(0xFF368A9B),
  'nature_people_rounded': Color(0xFF8C6D4F),
  'location_on': Color(0xFF4E9568),
  'visibility_rounded': Color(0xFF247BA0),
  'eco_rounded': Color(0xFF4E9568),
};

IconData obtenerIconoCategoria(CategoriaModel categoria) {
  final icono = categoria.icono.trim().toLowerCase();

  if (icono.isNotEmpty &&
      icono != 'location_on' &&
      icono != 'location' &&
      icono != 'place' &&
      iconosCategoria.containsKey(icono)) {
    return iconosCategoria[icono]!;
  }

  return AppColors.getIconForCategory(
    categoria.nombre.trim().toLowerCase(),
  );
}

Color obtenerColorCategoria(CategoriaModel categoria) {
  final icono = categoria.icono.trim().toLowerCase();

  if (icono.isNotEmpty &&
      icono != 'location_on' &&
      icono != 'location' &&
      icono != 'place' &&
      coloresIconosCategoria.containsKey(icono)) {
    return coloresIconosCategoria[icono]!;
  }

  return AppColors.getIconColorForCategory(categoria.nombre);
}

// ============================================================
// PANTALLA DE CATEGORÍAS
// ============================================================

class PantallaCategoria extends StatefulWidget {
  const PantallaCategoria({super.key});

  @override
  State<PantallaCategoria> createState() => _PantallaCategoriaState();
}

class _PantallaCategoriaState extends State<PantallaCategoria> {
  late final CategoriaController controller;
  String busqueda = '';

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

  void mostrarMensaje(String texto, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? AppColors.error : verdeEncabezado,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> abrirFormulario([CategoriaModel? categoria]) async {
    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FormularioCategoria(
        categoria: categoria,
        controller: controller,
      ),
    );

    if (resultado == true && mounted) {
      mostrarMensaje(
        categoria == null
            ? 'Categoría creada correctamente'
            : 'Categoría actualizada correctamente',
      );
    }
  }

  Future<void> eliminarCategoria(CategoriaModel categoria) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: blancoTarjeta,
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Deseas eliminar definitivamente '
          '"${categoria.nombre}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await controller.eliminarCategoria(categoria.id);

      if (mounted) {
        mostrarMensaje('Categoría eliminada correctamente');
      }
    } catch (e) {
      if (mounted) {
        mostrarMensaje(
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
      builder: (context, _) {
        final categorias = controller.categoriasFiltradas;

        return Scaffold(
          backgroundColor: fondoCrema,

          // La AppBar del panel se conserva; no se duplica aquí.

          floatingActionButton: FloatingActionButton(
            heroTag: 'fab_nueva_categoria',
            onPressed: controller.guardando
                ? null
                : () => abrirFormulario(),
            backgroundColor: naranjaAccion,
            foregroundColor: Colors.white,
            elevation: AppDimensions.spacingSm,
            shape: const CircleBorder(),
            tooltip: 'Nueva categoría',
            child: const Icon(Icons.add_rounded, size: 30),
          ),

          body: RefreshIndicator(
            color: verdeEncabezado,
            onRefresh: controller.cargarDatos,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pageHorizontalSmall,
                AppDimensions.spacingLg,
                AppDimensions.pageHorizontalSmall,
                110,
              ),
              children: [
                // ENCABEZADO SIN CUADRO
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        color: verdeEncabezado,
                        size: 30,
                      ),
                      const SizedBox(
                        width: AppDimensions.spacingMd,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explora tu ruta cafetera',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Administra los lugares por tipo de experiencia',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // CONTADOR EN PASTILLA BEIGE
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
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
                        const SizedBox(
                          width: AppDimensions.spacingSm,
                        ),
                        Text(
                          '${controller.sitios.length} sitios turísticos',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // BÚSQUEDA
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

                const SizedBox(height: AppDimensions.spacingXl),

                // LISTADO Y ACTUALIZACIÓN
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 25,
                      decoration: BoxDecoration(
                        color: naranjaAccion,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.chipRadius,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tipos de experiencia',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${categorias.length} disponibles',
                            style: TextStyle(
                              color: colorTextoSuave,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: blancoTarjeta,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                        onTap: controller.cargando
                            ? null
                            : controller.cargarDatos,
                        child: SizedBox(
                          width: AppDimensions.buttonHeight,
                          height: AppDimensions.buttonHeight,
                          child: Icon(
                            Icons.refresh_rounded,
                            color: verdeEncabezado,
                            size: AppDimensions.iconMd,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                if (controller.cargando && controller.categorias.isEmpty)
                  const EstadoCategoria(
                    mensaje: 'Cargando categorías...',
                    cargando: true,
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
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingMd,
                      ),
                      child: _TarjetaCategoriaVisual(
                        nombre: categoria.nombre,
                        descripcion: categoria.descripcion,
                        cantidadSitios:
                            controller.contarSitios(categoria),
                        activa: categoria.estado,
                        icono: obtenerIconoCategoria(categoria),
                        color: obtenerColorCategoria(categoria),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  sitios_categoria.PantallaSitiosCategoria(
                                categoria: categoria,
                              ),
                            ),
                          );
                        },
                        onEditar: () => abrirFormulario(categoria),
                        onEliminar: () => eliminarCategoria(categoria),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// TARJETA VISUAL DE CATEGORÍA
// ============================================================

class _TarjetaCategoriaVisual extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final int cantidadSitios;
  final bool activa;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaCategoriaVisual({
    required this.nombre,
    required this.descripcion,
    required this.cantidadSitios,
    required this.activa,
    required this.icono,
    required this.color,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final colorSuave = color.withValues(alpha: 0.13);

    return Container(
      decoration: BoxDecoration(
        color: blancoTarjeta,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color: const Color(0xFFECE5DA),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF614D34).withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: colorSuave,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(icono, size: 29, color: color),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descripcion.trim().isEmpty
                            ? 'Explora esta categoría'
                            : descripcion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingSm,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingSm,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorSuave,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.chipRadius,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.place_rounded,
                              size: 13,
                              color: color,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$cantidadSitios '
                              '${cantidadSitios == 1 ? 'sitio' : 'sitios'}',
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSm,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: activa
                            ? fondoEstado
                            : const Color(0xFFFCE8E6),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.chipRadius,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: activa
                                  ? verdeEstado
                                  : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            activa ? 'Activa' : 'Inactiva',
                            style: TextStyle(
                              color: activa
                                  ? verdeEstado
                                  : AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Opciones',
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.textSecondary,
                        size: AppDimensions.iconMd,
                      ),
                      onSelected: (opcion) {
                        if (opcion == 'editar') {
                          onEditar();
                        } else if (opcion == 'eliminar') {
                          onEliminar();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 19),
                              SizedBox(width: 10),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                                size: 19,
                              ),
                              SizedBox(width: 10),
                              Text('Eliminar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorTextoSuave,
                  size: AppDimensions.iconMd,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FORMULARIO DE CATEGORÍA
// ============================================================

class FormularioCategoria extends StatefulWidget {
  final CategoriaModel? categoria;
  final CategoriaController controller;

  const FormularioCategoria({
    super.key,
    this.categoria,
    required this.controller,
  });

  @override
  State<FormularioCategoria> createState() =>
      _FormularioCategoriaState();
}

class _FormularioCategoriaState extends State<FormularioCategoria> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController nombre;
  late final TextEditingController descripcion;
  late String icono;
  late bool activo;

  bool guardando = false;
  String? error;

  @override
  void initState() {
    super.initState();

    nombre = TextEditingController(
      text: widget.categoria?.nombre ?? '',
    );
    descripcion = TextEditingController(
      text: widget.categoria?.descripcion ?? '',
    );

    final guardado = widget.categoria?.icono;
    icono = iconosCategoria.containsKey(guardado)
        ? guardado!
        : 'location_on';

    activo = widget.categoria?.estado ?? true;
  }

  @override
  void dispose() {
    nombre.dispose();
    descripcion.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (guardando || !formKey.currentState!.validate()) return;

    setState(() {
      guardando = true;
      error = null;
    });

    try {
      await widget.controller.guardarCategoria(
        id: widget.categoria?.id,
        nombre: nombre.text.trim(),
        descripcion: descripcion.text.trim(),
        icono: icono,
        estado: activo,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
        error = widget.controller.error ?? 'No se pudo guardar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: blancoTarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
      ),
      title: Text(
        widget.categoria == null
            ? 'Nueva categoría'
            : 'Editar categoría',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombre,
                  enabled: !guardando,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (valor) =>
                      valor == null || valor.trim().isEmpty
                          ? 'Escribe el nombre'
                          : null,
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                TextFormField(
                  controller: descripcion,
                  enabled: !guardando,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                SelectorIconosCategoria(
                  iconos: iconosCategoria,
                  colores: coloresIconosCategoria,
                  seleccionado: icono,
                  habilitado: !guardando,
                  onSeleccionar: (valor) {
                    setState(() => icono = valor);
                  },
                ),
                if (widget.categoria != null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Categoría activa'),
                    value: activo,
                    onChanged: guardando
                        ? null
                        : (valor) => setState(() => activo = valor),
                  ),
                if (error != null) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      error!,
                      style: const TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: guardando
              ? null
              : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: verdeEncabezado,
            foregroundColor: Colors.white,
          ),
          onPressed: guardando ? null : guardar,
          child: guardando
              ? const SizedBox(
                  width: AppDimensions.iconSm,
                  height: AppDimensions.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
