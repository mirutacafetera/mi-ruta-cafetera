import 'package:flutter/material.dart';

import '../../models/clima_model.dart';
import '../../models/ia_recomendacion_model.dart';
import '../../models/sitio_turistico_model.dart';
import '../../services/ia_recomendaciones_service.dart';
import '../../services/ubicacion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/categoria_utils.dart';

/// Panel inferior con las recomendaciones de "Mi Ruta Cafetera IA".
///
/// Todo lo que muestra proviene del backend (sitios, categorías y
/// actividades reales). Si algo falla, el panel muestra un mensaje
/// y un botón para reintentar; nunca queda en blanco.
class IaRecomendacionesSheet extends StatefulWidget {
  final String token;
  final UbicacionUsuario? ubicacion;
  final ClimaModel? clima;

  final void Function(SitioTuristicoModel sitio) onVerSitio;
  final void Function(SitioTuristicoModel sitio) onVerRuta;

  /// Si es null, el botón "Reservar" no se muestra.
  final void Function(IaRecomendacion recomendacion)? onReservar;

  final VoidCallback onSesionExpirada;

  const IaRecomendacionesSheet({
    super.key,
    required this.token,
    required this.ubicacion,
    required this.clima,
    required this.onVerSitio,
    required this.onVerRuta,
    required this.onSesionExpirada,
    this.onReservar,
  });

  static Future<void> mostrar({
    required BuildContext context,
    required String token,
    required UbicacionUsuario? ubicacion,
    required ClimaModel? clima,
    required void Function(SitioTuristicoModel sitio) onVerSitio,
    required void Function(SitioTuristicoModel sitio) onVerRuta,
    required VoidCallback onSesionExpirada,
    void Function(IaRecomendacion recomendacion)? onReservar,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return IaRecomendacionesSheet(
          token: token,
          ubicacion: ubicacion,
          clima: clima,
          onVerSitio: onVerSitio,
          onVerRuta: onVerRuta,
          onSesionExpirada: onSesionExpirada,
          onReservar: onReservar,
        );
      },
    );
  }

  @override
  State<IaRecomendacionesSheet> createState() =>
      _IaRecomendacionesSheetState();
}

class _IaRecomendacionesSheetState
    extends State<IaRecomendacionesSheet> {
  bool _cargando = true;
  String? _error;
  IaRespuesta? _respuesta;

  /// Categorías reales; se conservan de la primera respuesta
  /// para que los chips no desaparezcan al filtrar.
  List<IaCategoria> _categorias = [];

  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  // ============================================================
  // CARGAR RECOMENDACIONES
  // ============================================================

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final respuesta = await IaRecomendacionesService.obtener(
        token: widget.token,
        ubicacion: widget.ubicacion,
        clima: widget.clima,
        categoria: _categoriaSeleccionada,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _respuesta = respuesta;

        if (_categorias.isEmpty) {
          _categorias = respuesta.categorias;
        }

        _cargando = false;
      });
    } on IaException catch (error) {
      if (!mounted) {
        return;
      }

      if (error.sesionInvalida) {
        Navigator.of(context).pop();
        widget.onSesionExpirada();
        return;
      }

      setState(() {
        _error = error.mensaje;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'No fue posible obtener recomendaciones.';
        _cargando = false;
      });
    }
  }

  void _seleccionarCategoria(String? nombre) {
    if (_categoriaSeleccionada == nombre || _cargando) {
      return;
    }

    _categoriaSeleccionada = nombre;
    _cargar();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: AppDimensions.sheetMaxSize - 0.1,
      minChildSize: AppDimensions.sheetMinSize,
      maxChildSize: AppDimensions.sheetMaxSize,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.sheetRadius),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingLg,
              AppDimensions.spacingMd,
              AppDimensions.spacingLg,
              AppDimensions.spacingSection,
            ),
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSm,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              _construirEncabezado(),
              const SizedBox(height: AppDimensions.spacingMd),
              if (_categorias.isNotEmpty) ...[
                _construirChips(),
                const SizedBox(height: AppDimensions.spacingMd),
              ],
              _construirCuerpo(),
            ],
          ),
        );
      },
    );
  }

  Widget _construirEncabezado() {
    final saludo = _respuesta?.saludo ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.secondary,
              size: AppDimensions.iconLg,
            ),
            SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Text(
                'Mi Ruta Cafetera IA',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        if (!_cargando && _error == null && saludo.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            saludo,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================
  // CHIPS DE CATEGORÍAS REALES
  // ============================================================

  Widget _construirChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            etiqueta: 'Todas',
            seleccionado: _categoriaSeleccionada == null,
            onTap: () => _seleccionarCategoria(null),
          ),
          for (final categoria in _categorias)
            _chip(
              etiqueta: categoria.nombre,
              seleccionado:
                  _categoriaSeleccionada == categoria.nombre,
              onTap: () =>
                  _seleccionarCategoria(categoria.nombre),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String etiqueta,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        right: AppDimensions.spacingSm,
      ),
      child: ChoiceChip(
        label: Text(etiqueta),
        selected: seleccionado,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
        labelStyle: TextStyle(
          color: seleccionado
              ? AppColors.white
              : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }

  // ============================================================
  // CUERPO
  // ============================================================

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppDimensions.spacingSection,
        ),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppDimensions.spacingLg),
            Text(
              '☕ Preparando recomendaciones...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _construirEstado(
        icono: Icons.cloud_off_rounded,
        mensaje: _error!,
        reintentar: true,
      );
    }

    final respuesta = _respuesta;

    if (respuesta == null || respuesta.recomendaciones.isEmpty) {
      return _construirEstado(
        icono: Icons.travel_explore_rounded,
        mensaje:
            'Todavía no hay lugares para recomendarte con '
            'este filtro.',
        reintentar: _categoriaSeleccionada != null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (respuesta.esRespaldo)
          Container(
            margin: const EdgeInsets.only(
              bottom: AppDimensions.spacingMd,
            ),
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AppColors.orangeSoft,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: const Text(
              'El asistente no estuvo disponible; estas son '
              'sugerencias del catálogo según el clima y tu '
              'ubicación.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        for (final recomendacion in respuesta.recomendaciones) ...[
          _construirTarjeta(recomendacion),
          const SizedBox(height: AppDimensions.spacingMd),
        ],
      ],
    );
  }

  Widget _construirEstado({
    required IconData icono,
    required String mensaje,
    required bool reintentar,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            icono,
            color: AppColors.textSecondary,
            size: 38,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (reintentar)
            TextButton(
              onPressed: _cargar,
              child: const Text('Intentar nuevamente'),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TARJETA DE RECOMENDACIÓN
  // ============================================================

  Widget _construirTarjeta(IaRecomendacion recomendacion) {
    final sitio = recomendacion.sitio;
    final colorCategoria = AppColors.getColorForCategory(
      sitio.categoriaNombre,
    );

    final datos = <String>[
      if (recomendacion.distanciaKm != null)
        '${recomendacion.distanciaKm!.toStringAsFixed(1)} km',
      if (recomendacion.horario.isNotEmpty)
        recomendacion.horario,
      if (recomendacion.precioDesde > 0)
        'Desde ${_precio(recomendacion.precioDesde)}',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppDimensions.smallCardImageHeight,
            width: double.infinity,
            child: Image.asset(
              CategoriaUtils.imagen(sitio.categoriaNombre),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppColors.surfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sitio.categoriaNombre.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingMd,
                      vertical: AppDimensions.spacingXs,
                    ),
                    decoration: BoxDecoration(
                      color: colorCategoria.withValues(
                        alpha: 0.14,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.chipRadius,
                      ),
                    ),
                    child: Text(
                      sitio.categoriaNombre,
                      style: TextStyle(
                        color: colorCategoria,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  sitio.nombre,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (datos.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    datos.join(' · '),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (recomendacion.motivo.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    recomendacion.motivo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                if (recomendacion.momentoSugerido.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    recomendacion.momentoSugerido,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (recomendacion.actividad != null) ...[
                  const SizedBox(height: AppDimensions.spacingSm),
                  _construirActividad(recomendacion.actividad!),
                ],
                const SizedBox(height: AppDimensions.spacingMd),
                _construirAcciones(recomendacion),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirActividad(IaActividad actividad) {
    final detalle = <String>[
      if (actividad.precio > 0) _precio(actividad.precio),
      if (actividad.duracion.isNotEmpty) actividad.duracion,
      if (actividad.horario.isNotEmpty) actividad.horario,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad: ${actividad.nombre}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (detalle.isNotEmpty)
            Text(
              detalle.join(' · '),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _construirAcciones(IaRecomendacion recomendacion) {
    final puedeReservar =
        recomendacion.reservable && widget.onReservar != null;

    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: [
        OutlinedButton.icon(
          onPressed: () =>
              widget.onVerSitio(recomendacion.sitio),
          icon: const Icon(
            Icons.place_outlined,
            size: AppDimensions.iconSm,
          ),
          label: const Text('Ver sitio'),
        ),
        OutlinedButton.icon(
          onPressed: recomendacion.sitio.tieneCoordenadas
              ? () => widget.onVerRuta(recomendacion.sitio)
              : null,
          icon: const Icon(
            Icons.route_rounded,
            size: AppDimensions.iconSm,
          ),
          label: const Text('Ver ruta'),
        ),
        if (puedeReservar)
          ElevatedButton.icon(
            onPressed: () =>
                widget.onReservar!(recomendacion),
            icon: const Icon(
              Icons.event_available_rounded,
              size: AppDimensions.iconSm,
            ),
            label: const Text('Reservar'),
          ),
      ],
    );
  }

  // ============================================================
  // FORMATO DE PRECIO
  // ============================================================

  String _precio(double valor) {
    final texto = valor.round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < texto.length; i++) {
      if (i > 0 && (texto.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(texto[i]);
    }

    return '\$$buffer';
  }
}