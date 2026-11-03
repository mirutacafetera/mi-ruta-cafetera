import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../services/contenido_service.dart';
import '../../services/favorito_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';
import '../usuario/detalle_sitio/componentes_detalle.dart';

class MapaTarjetaSitio extends StatefulWidget {
  const MapaTarjetaSitio({
    super.key,
    required this.sitio,
    required this.onVerSitio,
    required this.onAgregarRuta,
  });

  final SitioTuristicoModel sitio;
  final VoidCallback onVerSitio;
  final VoidCallback onAgregarRuta;

  @override
  State<MapaTarjetaSitio> createState() =>
      _MapaTarjetaSitioState();
}

class _MapaTarjetaSitioState
    extends State<MapaTarjetaSitio> {
  late String _imagen;
  String? _favoritoId;
  bool _cargandoImagen = true;
  bool _cargandoFavorito = false;

  @override
  void initState() {
    super.initState();
    _imagen = widget.sitio.imagen.trim();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await Future.wait([
      _cargarImagen(),
      _cargarFavorito(),
    ]);
  }

  Future<void> _cargarImagen() async {
    try {
      if (_imagen.isNotEmpty) return;

      final contenidos =
          await ContenidoService.instance
              .obtenerContenidosPorSitio(
        widget.sitio.id,
      );

      for (final contenido in contenidos) {
        if (!contenido.activo) continue;

        final principal =
            contenido.imagenPrincipal.trim();

        if (principal.isNotEmpty) {
          if (mounted) {
            setState(() {
              _imagen = principal;
            });
          }
          break;
        }

        for (final adicional in contenido.imagenes) {
          if (adicional.trim().isEmpty) continue;

          if (mounted) {
            setState(() {
              _imagen = adicional;
            });
          }
          break;
        }

        if (_imagen.isNotEmpty) break;
      }
    } catch (_) {
      // La tarjeta conserva el marcador de imagen.
    } finally {
      if (mounted) {
        setState(() {
          _cargandoImagen = false;
        });
      }
    }
  }

  Future<void> _cargarFavorito() async {
    final sesion =
        UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null) return;

    try {
      final favoritos =
          await FavoritoService.instance.obtenerFavoritos(
        sesion.id,
        token: sesion.token,
      );

      final favorito = favoritos.where(
        (item) => item.sitio.id == widget.sitio.id,
      );

      if (!mounted) return;

      setState(() {
        _favoritoId =
            favorito.isEmpty ? null : favorito.first.id;
      });
    } catch (_) {
      // Si falla la consulta, la tarjeta sigue disponible.
    }
  }

  Future<void> _alternarFavorito() async {
    final sesion =
        UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Tr(
            'Inicia sesión para guardar sitios favoritos.',
          ),
        ),
      );
      return;
    }

    if (_cargandoFavorito) return;

    setState(() {
      _cargandoFavorito = true;
    });

    try {
      if (_favoritoId == null) {
        final favorito =
            await FavoritoService.instance.agregarFavorito(
          usuarioId: sesion.id,
          sitioId: widget.sitio.id,
          token: sesion.token,
        );

        if (mounted) {
          setState(() {
            _favoritoId = favorito?.id;
          });
        }
      } else {
        await FavoritoService.instance.eliminarFavorito(
          _favoritoId!,
          token: sesion.token,
        );

        if (mounted) {
          setState(() {
            _favoritoId = null;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceFirst(
                    'Exception: ',
                    '',
                  ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargandoFavorito = false;
        });
      }
    }
  }

  Widget _construirImagen() {
    if (_cargandoImagen && _imagen.isEmpty) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_imagen.isEmpty) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: PlaceholderImagenDetalle(
          mensaje: 'Este sitio aún no tiene imágenes',
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        _imagen,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox.shrink();
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoria = widget.sitio.categoriaNombre.trim();
    final descripcion = widget.sitio.descripcion.trim();

    return SafeArea(
      child: Material(
        color: AppColors.sitioBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(
            AppDimensions.detalleContentRadius,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingLg,
            AppDimensions.spacingMd,
            AppDimensions.spacingLg,
            AppDimensions.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.sitioBorder,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: Textos.t('Cerrar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppDimensions.radiusLg,
                ),
                child: _construirImagen(),
              ),

              const SizedBox(
                height: AppDimensions.spacingMd,
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.sitio.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.sitioTextPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _favoritoId == null
                        ? Textos.t('Agregar a favoritos')
                        : Textos.t('Quitar de favoritos'),
                    onPressed: _cargandoFavorito
                        ? null
                        : _alternarFavorito,
                    icon: _cargandoFavorito
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            _favoritoId == null
                                ? Icons.favorite_border
                                : Icons.favorite,
                            color: AppColors.sitioPrimary,
                          ),
                  ),
                ],
              ),

              if (categoria.isNotEmpty) ...[
                const SizedBox(
                  height: AppDimensions.spacingXs,
                ),
                EtiquetaDetalle(
                  texto: categoria,
                  icono: Icons.category_outlined,
                ),
              ],

              if (descripcion.isNotEmpty) ...[
                const SizedBox(
                  height: AppDimensions.spacingMd,
                ),
                Text(
                  descripcion,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.sitioTextSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],

              const SizedBox(
                height: AppDimensions.spacingLg,
              ),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.detalleActionHeight,
                child: ElevatedButton.icon(
                  onPressed: widget.onVerSitio,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Tr('Ver sitio completo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sitioPrimary,
                    foregroundColor: AppColors.sitioTextOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXxl,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: AppDimensions.spacingSm,
              ),

              SizedBox(
                width: double.infinity,
                height: AppDimensions.detalleActionHeight,
                child: OutlinedButton.icon(
                  onPressed: widget.onAgregarRuta,
                  icon: const Icon(Icons.add_road),
                  label: const Tr('Agregar a mi ruta'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.sitioPrimary,
                    side: BorderSide(
                      color: AppColors.sitioPrimary.withValues(
                        alpha: 0.55,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXxl,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}