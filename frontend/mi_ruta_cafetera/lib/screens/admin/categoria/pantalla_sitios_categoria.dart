
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../models/categoria_model.dart';
import '../../../models/admin/sitio_admin_model.dart';
import '../../../services/admin/sitio/servicio_admin_sitio.dart';

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

class _PantallaSitiosCategoriaState
    extends State<PantallaSitiosCategoria> {
  List<SitioAdminModel> sitios = [];

  bool cargando = true;
  String? error;
  String busqueda = '';

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
            .where(
              (sitio) => sitio.categoria?.id == widget.categoria.id,
            )
            .toList();

        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'No se pudieron cargar los sitios turísticos.';
        cargando = false;
      });
    }
  }

  List<SitioAdminModel> get sitiosFiltrados {
    final texto = busqueda.trim().toLowerCase();

    if (texto.isEmpty) {
      return sitios;
    }

    return sitios.where((sitio) {
      return sitio.nombre.toLowerCase().contains(texto) ||
          sitio.descripcion.toLowerCase().contains(texto) ||
          sitio.direccion.toLowerCase().contains(texto);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = sitiosFiltrados;

    final colorCategoria = AppColors.getColorForCategory(
      widget.categoria.nombre,
    );

    final iconoCategoria = AppColors.getIconForCategory(
      widget.categoria.nombre,
    );

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
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
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
        ],
      ),

      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: cargarSitios,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(
              AppDimensions.pageHorizontalSmall,
            ),
            children: [
              // BUSCADOR
              SizedBox(
                height: AppDimensions.searchHeight,
                child: TextField(
                  onChanged: (valor) {
                    setState(() {
                      busqueda = valor;
                    });
                  },
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar sitio turístico...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: AppDimensions.searchIconSize,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingLg,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.searchRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.searchRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.searchRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingLg,
              ),

              // CONTENIDO
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
                          color: colorCategoria.withValues(
                            alpha: 0.12,
                          ),
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
                // TÍTULO Y CANTIDAD
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
                          color: colorCategoria.withValues(
                            alpha: 0.12,
                          ),
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

                // TARJETAS DE SITIOS
                ...filtrados.map((sitio) {
                  final descripcion =
                      sitio.descripcion.trim().isNotEmpty
                          ? sitio.descripcion.trim()
                          : sitio.direccion.trim();

                  return Container(
                    margin: const EdgeInsets.only(
                      bottom: AppDimensions.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius,
                      ),
                      border: Border.all(
                        color: AppColors.border,
                        width: 0.7,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppDimensions.spacingMd,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // IMAGEN O ICONO DEL SITIO
                          if (sitio.imagen.trim().isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                              child: Image.network(
                                sitio.imagen,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) {
                                  return _iconoSitio(
                                    colorCategoria,
                                    iconoCategoria,
                                  );
                                },
                              ),
                            )
                          else
                            _iconoSitio(
                              colorCategoria,
                              iconoCategoria,
                            ),

                          const SizedBox(
                            width: AppDimensions.spacingMd,
                          ),

                          // INFORMACIÓN
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
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ICONO DEL SITIO CON EL COLOR DE SU CATEGORÍA.
  // Se define dentro de esta pantalla: no crea otro archivo.
  Widget _iconoSitio(Color color, IconData icono) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icono,
        color: color,
        size: AppDimensions.iconLg,
      ),
    );
  }
}
