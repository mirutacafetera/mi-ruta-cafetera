import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../models/categoria_model.dart';
import '../../../controllers/admin/categoria/categoria_controller.dart';
import '../../../widgets/admin/categoria/estado_categoria.dart';
import '../../../widgets/admin/categoria/selector_iconos_categoria.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import 'pantalla_sitios_categoria.dart' as sitios_categoria;

const verdeEncabezado = Color(0xFF174B38);
const fondoCrema = Color(0xFFF4F0E7);
const naranjaAccion = Color(0xFFFF781F);
const verdeEstado = Color(0xFF248342);
const blancoTarjeta = Color(0xFFFFFEFC);
const colorTextoSuave = Color(0xFF7D867E);
const fondoContador = Color(0xFFECE4D6);
const colorContador = Color(0xFF76583A);

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

IconData obtenerIconoCategoria(CategoriaModel c) {
  final i = c.icono.trim().toLowerCase();

  if (i.isNotEmpty &&
      !['location_on', 'location', 'place'].contains(i) &&
      iconosCategoria.containsKey(i)) {
    return iconosCategoria[i]!;
  }

  return AppColors.getIconForCategory(c.nombre.trim().toLowerCase());
}

Color obtenerColorCategoria(CategoriaModel c) {
  final i = c.icono.trim().toLowerCase();

  if (i.isNotEmpty &&
      !['location_on', 'location', 'place'].contains(i) &&
      coloresIconosCategoria.containsKey(i)) {
    return coloresIconosCategoria[i]!;
  }

  return AppColors.getIconColorForCategory(c.nombre);
}

class PantallaCategoria extends StatefulWidget {
  const PantallaCategoria({super.key});

  @override
  State<PantallaCategoria> createState() => _PantallaCategoriaState();
}

class _PantallaCategoriaState extends State<PantallaCategoria> {
  late final CategoriaController controller;
  String busqueda = '';
  bool _actualizandoLista = false;

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

  Future<void> actualizarPantalla() async {
    if (_actualizandoLista || controller.cargando) return;

    setState(() => _actualizandoLista = true);

    try {
      await controller.cargarDatos();
    } finally {
      if (mounted) {
        setState(() => _actualizandoLista = false);
      }
    }
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
      builder: (ctx) => AlertDialog(
        backgroundColor: blancoTarjeta,
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Deseas eliminar definitivamente "${categoria.nombre}"?\n\nEsta acción no se puede deshacer.',
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
        final cargando = _actualizandoLista || controller.cargando;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: cargando
              ? null
              : FloatingActionButton(
                  heroTag: 'fab_nueva_categoria',
                  backgroundColor: naranjaAccion,
                  foregroundColor: Colors.white,
                  onPressed: controller.guardando
                      ? null
                      : () => abrirFormulario(),
                  tooltip: 'Nueva categoría',
                  child: const Icon(Icons.add_rounded, size: 30),
                ),
          body: RefreshIndicator(
            color: verdeEncabezado,
            onRefresh: actualizarPantalla,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pageHorizontalSmall,
                AppDimensions.spacingLg,
                AppDimensions.pageHorizontalSmall,
                110,
              ),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.eco_rounded,
                    color: verdeEncabezado,
                    size: 30,
                  ),
                  title: Text(
                    'Explora tu ruta cafetera',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    'Administra los lugares por tipo de experiencia',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        const SizedBox(width: 8),
                        Text(
                          '${controller.sitios.length} sitios turísticos',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BarraBusqueda(
                  valor: busqueda,
                  textoAyuda: 'Buscar categoría...',
                  onChanged: (v) {
                    setState(() => busqueda = v);
                    controller.buscar(v);
                  },
                  onLimpiar: () {
                    setState(() => busqueda = '');
                    controller.buscar('');
                  },
                ),
                const SizedBox(height: 24),
                if (cargando)
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.75,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: verdeEncabezado,
                        strokeWidth: 3,
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 25,
                        decoration: BoxDecoration(
                          color: naranjaAccion,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                              style: const TextStyle(
                                color: colorTextoSuave,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Actualizar categorías',
                        onPressed: actualizarPantalla,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: verdeEncabezado,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (controller.error != null &&
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
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TarjetaCategoria(
                          categoria: c,
                          cantidad: controller.contarSitios(c),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    sitios_categoria.PantallaSitiosCategoria(
                                  categoria: c,
                                ),
                              ),
                            );
                          },
                          onEditar: () => abrirFormulario(c),
                          onEliminar: () => eliminarCategoria(c),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TarjetaCategoria extends StatelessWidget {
  final CategoriaModel categoria;
  final int cantidad;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _TarjetaCategoria({
    required this.categoria,
    required this.cantidad,
    required this.onTap,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final color = obtenerColorCategoria(categoria);

    return Container(
      decoration: BoxDecoration(
        color: blancoTarjeta,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFFECE5DA)),
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    obtenerIconoCategoria(categoria),
                    size: 28,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoria.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoria.descripcion.trim().isEmpty
                            ? 'Explora esta categoría'
                            : categoria.descripcion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$cantidad ${cantidad == 1 ? 'sitio' : 'sitios'}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        categoria.estado ? 'Activa' : 'Inactiva',
                        style: TextStyle(
                          color: categoria.estado
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
                  onSelected: (v) {
                    if (v == 'editar') onEditar();
                    if (v == 'eliminar') onEliminar();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 19),
                          SizedBox(width: 8),
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
                          SizedBox(width: 8),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: colorTextoSuave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormularioCategoria extends StatefulWidget {
  final CategoriaModel? categoria;
  final CategoriaController controller;

  const FormularioCategoria({
    super.key,
    this.categoria,
    required this.controller,
  });

  @override
  State<FormularioCategoria> createState() => _FormularioCategoriaState();
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
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
                  validator: (v) => v == null || v.trim().isEmpty
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
                  onSeleccionar: (v) => setState(() => icono = v),
                ),
                if (widget.categoria != null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Categoría activa'),
                    value: activo,
                    onChanged: guardando
                        ? null
                        : (v) => setState(() => activo = v),
                  ),
                if (error != null) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      error!,
                      style: const TextStyle(color: AppColors.error),
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