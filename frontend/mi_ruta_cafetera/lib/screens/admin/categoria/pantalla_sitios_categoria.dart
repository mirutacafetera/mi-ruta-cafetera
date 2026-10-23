
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../models/categoria_model.dart';
import '../../../models/admin/sitio_admin_model.dart';
import '../../../services/admin/sitio/servicio_admin_sitio.dart';
import '../../../widgets/admin/fondo_admin.dart';
import '../../../widgets/admin/sitio_turistico/detalle_sitio_turistico.dart';

class PantallaSitiosCategoria extends StatefulWidget {
  final CategoriaModel categoria;

  const PantallaSitiosCategoria({
    super.key,
    required this.categoria,
  });

  @override
  State<PantallaSitiosCategoria> createState() =>
      _PantallaSitiosCategoriaState();
}

class _PantallaSitiosCategoriaState extends State<PantallaSitiosCategoria> {
  List<SitioAdminModel> sitios = [];
  bool cargando = true;
  String? error;
  String busqueda = '';

  static const Color cafe = Color(0xFF966F52);
  static const Color beigeTarjeta = Color(0xFFFAF3E8);
  static const Color beigeBuscador = Color(0xFFFFFCF6);

  @override
  void initState() {
    super.initState();
    cargarSitios();
  }

  Future<void> cargarSitios() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final todos = await ServicioAdminSitio.obtenerSitios();

      if (!mounted) return;

      setState(() {
        sitios = todos
            .where((sitio) => sitio.categoria?.id == widget.categoria.id)
            .toList();
        cargando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = 'No se pudieron cargar los sitios turísticos.';
        cargando = false;
      });
    }
  }

  List<SitioAdminModel> get sitiosFiltrados {
    final texto = busqueda.trim().toLowerCase();

    if (texto.isEmpty) return sitios;

    return sitios.where((sitio) {
      return sitio.nombre.toLowerCase().contains(texto) ||
          sitio.descripcion.toLowerCase().contains(texto) ||
          sitio.direccion.toLowerCase().contains(texto);
    }).toList();
  }

  Future<void> _mostrarDetalle(SitioAdminModel sitio) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              controller: scrollController,
              child: DetalleSitioTuristico(sitio: sitio),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = sitiosFiltrados;
    final colorCategoria =
        AppColors.getColorForCategory(widget.categoria.nombre);
    final iconoCategoria =
        AppColors.getIconForCategory(widget.categoria.nombre);

    return FondoAdmin(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
          ),
          titleTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(
            widget.categoria.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              onPressed: cargando ? null : cargarSitios,
              tooltip: 'Actualizar',
              color: AppColors.textPrimary,
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: AppDimensions.spacingXs),
          ],
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: beigeBuscador,
            onRefresh: cargarSitios,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(
                AppDimensions.pageHorizontalSmall,
              ),
              children: [
                SizedBox(
                  height: AppDimensions.searchHeight,
                  child: TextField(
                    onChanged: (valor) {
                      setState(() => busqueda = valor);
                    },
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar sitio turístico...',
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: AppDimensions.searchIconSize,
                        color: AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: beigeBuscador,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingLg,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.searchRadius,
                        ),
                        borderSide: const BorderSide(
                          color: cafe,
                          width: 1.2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.searchRadius,
                        ),
                        borderSide: const BorderSide(
                          color: cafe,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.searchRadius,
                        ),
                        borderSide: const BorderSide(
                          color: cafe,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                if (cargando)
                  const Padding(
                    padding: EdgeInsets.all(
                      AppDimensions.spacingSection,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (error != null)
                  Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingXl,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          color: AppColors.error,
                          size: 42,
                        ),
                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),
                        OutlinedButton.icon(
                          onPressed: cargarSitios,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                else if (filtrados.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingSection,
                      horizontal: AppDimensions.spacingLg,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: colorCategoria.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            busqueda.trim().isEmpty
                                ? iconoCategoria
                                : Icons.search_off_rounded,
                            size: 34,
                            color: colorCategoria,
                          ),
                        ),
                        const SizedBox(
                          height: AppDimensions.spacingLg,
                        ),
                        Text(
                          busqueda.trim().isEmpty
                              ? 'Todavía no hay sitios en esta categoría.'
                              : 'No encontramos sitios que coincidan '
                                  'con tu búsqueda.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.spacingXs,
                      right: AppDimensions.spacingXs,
                      bottom: AppDimensions.spacingMd,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sitios turísticos',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingMd,
                            vertical: AppDimensions.spacingXs,
                          ),
                          decoration: BoxDecoration(
                            color: colorCategoria.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.chipRadius,
                            ),
                          ),
                          child: Text(
                            '${filtrados.length} '
                            '${filtrados.length == 1 ? 'sitio' : 'sitios'}',
                            style: TextStyle(
                              color: colorCategoria,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...filtrados.map((sitio) {
                    final descripcion = sitio.descripcion.trim().isNotEmpty
                        ? sitio.descripcion.trim()
                        : sitio.direccion.trim();

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: beigeTarjeta,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                        border: Border.all(
                          color: cafe,
                          width: 1.1,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _mostrarDetalle(sitio),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.spacingMd,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _miniaturaSitio(
                                  sitio,
                                  colorCategoria,
                                  iconoCategoria,
                                ),
                                const SizedBox(
                                  width: AppDimensions.spacingMd,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sitio.nombre,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                        ),
                                      ),
                                      if (descripcion.isNotEmpty) ...[
                                        const SizedBox(
                                          height: AppDimensions.spacingXs,
                                        ),
                                        Text(
                                          descripcion,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: cafe,
                                  size: 23,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniaturaSitio(
    SitioAdminModel sitio,
    Color color,
    IconData icono,
  ) {
    final url = sitio.imagen.trim().isNotEmpty
        ? sitio.imagen.trim()
        : sitio.imagenes
            .where((imagen) => imagen.trim().isNotEmpty)
            .firstOrNull;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: cafe,
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null
          ? _iconoSitio(color, icono)
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _iconoSitio(color, icono),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _iconoSitio(Color color, IconData icono) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      child: Icon(
        icono,
        color: color,
        size: AppDimensions.iconLg,
      ),
    );
  }
}
