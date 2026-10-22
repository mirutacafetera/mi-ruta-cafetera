import 'package:flutter/material.dart';

import '../../models/ruta_model.dart';
import '../../services/ruta_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

// ============================================================
// RUTAS PREDEFINIDAS (API)
// ============================================================
//
// Las rutas predefinidas se administran en MongoDB y se consultan
// con RutaService (GET /api/rutas/predefinidas). Este widget solo
// las lista; seleccionar una abre su itinerario en el mapa.
// ============================================================
class MapaRutasPredefinidas extends StatefulWidget {
  final ValueChanged<RutaModel> onSeleccionar;

  /// Permite inyectar el servicio (pruebas).
  final RutaService? rutaService;

  const MapaRutasPredefinidas({
    super.key,
    required this.onSeleccionar,
    this.rutaService,
  });

  @override
  State<MapaRutasPredefinidas> createState() =>
      _MapaRutasPredefinidasState();
}

class _MapaRutasPredefinidasState
    extends State<MapaRutasPredefinidas> {
  late final RutaService _rutaService;

  List<RutaModel> _rutas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rutaService = widget.rutaService ?? RutaService();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final rutas = await _rutaService.obtenerRutasPredefinidas();

      if (!mounted) {
        return;
      }

      setState(() {
        _rutas = rutas
            .where(
              (ruta) =>
                  ruta.tipo == 'predefinida' && ruta.activa,
            )
            .toList();
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error = Textos.t('No fue posible cargar las rutas.');
      });
    }
  }

  // Texto de apoyo: paradas y tiempo planificado EN los sitios
  // (no incluye el tiempo de viaje por carretera).
  String _resumen(RutaModel ruta) {
    final paradas = ruta.paradas.isNotEmpty
        ? ruta.paradas.length
        : ruta.sitios.length;

    final partes = <String>[
      '$paradas ${paradas == 1 ? 'parada' : 'paradas'}',
    ];

    final minutos = ruta.duracionPlanificadaMin;

    if (minutos != null && minutos > 0) {
      partes.add(
        '${_formatoDuracion(minutos)} en los sitios',
      );
    }

    return partes.join(' · ');
  }

  static String _formatoDuracion(int minutos) {
    final horas = minutos ~/ 60;
    final resto = minutos % 60;

    if (horas == 0) {
      return Textos.t('{0} min', [resto]);
    }

    if (resto == 0) {
      return Textos.t('{0} h', [horas]);
    }

    return Textos.t('{0} h {1} min', [horas, resto]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: AppDimensions.sheetInitialSize,
        minChildSize: AppDimensions.sheetMinSize,
        maxChildSize: AppDimensions.sheetMaxSize,
        builder: (context, scrollController) {
          return Material(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXxl),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.spacingMd),
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSm,
                    ),
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingLg +
                      AppDimensions.spacingXs / 2,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXl,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Tr(
                      'Rutas predefinidas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: AppDimensions.spacingXs + 2,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingXl,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Tr(
                      'Elige una experiencia para explorar sus sitios.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Expanded(
                  child: _contenido(scrollController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _contenido(ScrollController scrollController) {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              OutlinedButton.icon(
                onPressed: _cargar,
                icon: const Icon(Icons.refresh),
                label: const Tr('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_rutas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingXl),
          child: Tr(
            'Por ahora no hay rutas predefinidas disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingSm,
        AppDimensions.spacingLg,
        AppDimensions.spacingXxl,
      ),
      itemCount: _rutas.length,
      itemBuilder: (context, index) {
        final ruta = _rutas[index];

        return Card(
          margin: const EdgeInsets.only(
            bottom: AppDimensions.spacingMd,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            leading: CircleAvatar(
              radius: AppDimensions.spacingXl +
                  AppDimensions.spacingXs +
                  1,
              backgroundColor: AppColors.secondary.withValues(
                alpha: 0.15,
              ),
              child: const Icon(
                Icons.route,
                color: AppColors.secondary,
                size: AppDimensions.iconMd,
              ),
            ),
            title: Text(
              ruta.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(
                top: AppDimensions.spacingXs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ruta.descripcion.trim().isNotEmpty)
                    Text(
                      ruta.descripcion,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    _resumen(ruta),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: AppDimensions.iconSm,
              color: AppColors.textSecondary,
            ),
            onTap: () {
              Navigator.pop(context);
              widget.onSeleccionar(ruta);
            },
          ),
        );
      },
    );
  }
}
