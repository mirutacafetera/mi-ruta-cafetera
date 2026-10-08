import 'package:flutter/material.dart';

import '../../models/contenido_model.dart';
import '../../models/sitio_turistico_model.dart';
import '../../services/contenido_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/mapa/mapa_detalle_sitio.dart';
import '../../widgets/navegacion/boton_regresar.dart';
import '../../widgets/usuario/seccion_contenido_sitio.dart';
import '../mapa_screen_2.dart';

class DetalleSitioUsuarioScreen extends StatefulWidget {
  const DetalleSitioUsuarioScreen({
    super.key,
    required this.sitio,
    this.imagen,
    this.esFavorito = false,
    this.onFavorite,
  });

  final SitioTuristicoModel sitio;
  final String? imagen;
  final bool esFavorito;
  final VoidCallback? onFavorite;

  @override
  State<DetalleSitioUsuarioScreen> createState() =>
      _DetalleSitioUsuarioScreenState();
}

class _DetalleSitioUsuarioScreenState
    extends State<DetalleSitioUsuarioScreen> {
  final ContenidoService _contenidoService =
      ContenidoService.instance;

  late bool _esFavorito;

  List<ContenidoModel> _contenidos = [];

  bool _cargandoContenido = true;

  @override
  void initState() {
    super.initState();

    _esFavorito = widget.esFavorito;

    _cargarContenido();
  }

  Future<void> _cargarContenido() async {
    final sitioId = widget.sitio.id.trim();

    if (sitioId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _cargandoContenido = false;
        _contenidos = [];
      });

      return;
    }

    try {
      final contenidos =
          await _contenidoService.obtenerContenidosPorSitio(
        sitioId,
      );

      if (!mounted) return;

      setState(() {
        _contenidos = contenidos;
        _cargandoContenido = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _contenidos = [];
        _cargandoContenido = false;
      });
    }
  }

  void _cambiarFavorito() {
    setState(() {
      _esFavorito = !_esFavorito;
    });

    widget.onFavorite?.call();
  }

  void _verMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapaScreen2(),
      ),
    );
  }

  void _agregarRuta() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La selección de sitios para tu ruta estará disponible aquí.',
        ),
      ),
    );
  }

  void _mostrarDetalleMapa() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MapaDetalleSitio(
          sitio: widget.sitio,
          onVerMapa: _verMapa,
          onAgregarRuta: _agregarRuta,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: const BotonRegresar(),
        title: const Text('Detalle del sitio'),
        actions: [
          IconButton(
            onPressed: _cambiarFavorito,
            tooltip: _esFavorito
                ? 'Quitar de favoritos'
                : 'Agregar a favoritos',
            icon: Icon(
              _esFavorito
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _construirImagen(theme),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal:
                      AppDimensions.pageHorizontal,
                  vertical:
                      AppDimensions.spacingXl,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _construirCabecera(theme),

                    const SizedBox(
                      height: AppDimensions.spacingXl,
                    ),

                    _construirUbicacion(theme),

                    const SizedBox(
                      height: AppDimensions.spacingXl,
                    ),

                    _construirDescripcion(theme),

                    if (widget.sitio.etiquetas.isNotEmpty) ...[
                      const SizedBox(
                        height: AppDimensions.spacingXl,
                      ),
                      _construirEtiquetas(theme),
                    ],

                    if (_cargandoContenido) ...[
                      const SizedBox(
                        height: AppDimensions.spacingXxl,
                      ),
                      const Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    ],

                    if (!_cargandoContenido &&
                        _contenidos.isNotEmpty) ...[
                      const SizedBox(
                        height: AppDimensions.spacingXxl,
                      ),
                      SeccionContenidoSitio(
                        contenidos: _contenidos,
                      ),
                    ],

                    const SizedBox(
                      height: AppDimensions.spacingXxl,
                    ),

                    _construirAcciones(theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirImagen(ThemeData theme) {
    final imagen = widget.imagen;

    if (imagen == null ||
        imagen.trim().isEmpty) {
      return Container(
        width: double.infinity,
        height: 240,
        color:
            theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.landscape,
          size: 72,
          color: AppColors.primary,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 240,
      child: Image.asset(
        imagen,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            color:
                theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.landscape,
              size: 72,
              color: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _construirCabecera(ThemeData theme) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        if (widget.sitio.categoriaNombre.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal:
                  AppDimensions.spacingMd,
              vertical:
                  AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.spacingMd,
              ),
            ),
            child: Text(
              widget.sitio.categoriaNombre,
              style: theme.textTheme.labelLarge
                  ?.copyWith(
                color: AppColors.primary,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        Text(
          widget.sitio.nombre,
          style: theme.textTheme.headlineSmall
              ?.copyWith(
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _construirUbicacion(ThemeData theme) {
    final partes = <String>[
      if (widget.sitio.direccion
          .trim()
          .isNotEmpty)
        widget.sitio.direccion.trim(),
      if (widget.sitio.ciudad
          .trim()
          .isNotEmpty)
        widget.sitio.ciudad.trim(),
      if (widget.sitio.departamento
          .trim()
          .isNotEmpty)
        widget.sitio.departamento.trim(),
    ];

    final ubicacion =
        partes.join(', ');

    return _InfoSection(
      icono:
          Icons.location_on_outlined,
      titulo: 'Ubicación',
      contenido: ubicacion.isEmpty
          ? 'Ubicación no disponible.'
          : ubicacion,
    );
  }

  Widget _construirDescripcion(
    ThemeData theme,
  ) {
    return _InfoSection(
      icono: Icons.info_outline,
      titulo: 'Acerca de este sitio',
      contenido: widget.sitio.descripcion
              .trim()
              .isEmpty
          ? 'No hay una descripción disponible.'
          : widget.sitio.descripcion
              .trim(),
    );
  }

  Widget _construirEtiquetas(
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Experiencias',
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight:
                FontWeight.w700,
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        Wrap(
          spacing: AppDimensions.spacingSm,
          runSpacing: AppDimensions.spacingSm,
          children: widget.sitio.etiquetas
              .where(
                (etiqueta) =>
                    etiqueta.trim().isNotEmpty,
              )
              .map(
                (etiqueta) => Chip(
                  label:
                      Text(etiqueta.trim()),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _construirAcciones(
    ThemeData theme,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _verMapa,
            icon: const Icon(
              Icons.map_outlined,
            ),
            label: const Text(
              'Ver en el mapa',
            ),
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _agregarRuta,
            icon: const Icon(
              Icons.route_outlined,
            ),
            label: const Text(
              'Agregar a mi ruta',
            ),
          ),
        ),
        const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                _mostrarDetalleMapa,
            icon: const Icon(
              Icons.place_outlined,
            ),
            label: const Text(
              'Ver ubicación del sitio',
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoSection
    extends StatelessWidget {
  const _InfoSection({
    required this.icono,
    required this.titulo,
    required this.contenido,
  });

  final IconData icono;
  final String titulo;
  final String contenido;

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icono,
              color: AppColors.primary,
            ),
            const SizedBox(
              width: AppDimensions.spacingSm,
            ),
            Text(
              titulo,
              style:
                  theme.textTheme.titleMedium
                      ?.copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: AppDimensions.spacingSm,
        ),
        Text(
          contenido,
          style:
              theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}