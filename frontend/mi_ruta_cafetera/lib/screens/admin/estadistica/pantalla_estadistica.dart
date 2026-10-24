import 'package:flutter/material.dart';

import '../../../controllers/admin/estadistica/estadistica_controller.dart';
import '../../../models/admin/estadistica_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/estadistica/grafica_estadisticas_mensuales.dart';
import '../../../widgets/admin/estadistica/tarjeta_estadistica.dart';

class PantallaEstadistica extends StatefulWidget {
  const PantallaEstadistica({super.key});

  @override
  State<PantallaEstadistica> createState() => _PantallaEstadisticaState();
}

class _PantallaEstadisticaState extends State<PantallaEstadistica> {
  late final EstadisticaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EstadisticaController();
    _controller.addListener(_actualizarPantalla);
    _controller.cargarEstadisticas();
  }

  void _actualizarPantalla() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_actualizarPantalla);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _actualizarEstadisticas() async {
    await _controller.actualizarEstadisticas();
  }

  List<Map<String, dynamic>> _crearTarjetas(
    ResumenEstadisticasModel datos,
  ) {
    return [
      {
        'titulo': 'Usuarios',
        'cantidad': datos.usuarios,
        'descripcion': 'Usuarios registrados',
        'icono': Icons.people_alt_rounded,
        'color': AppColors.primary,
      },
      {
        'titulo': 'Reseñas',
        'cantidad': datos.resenas,
        'descripcion': 'Reseñas registradas',
        'icono': Icons.rate_review_rounded,
        'color': AppColors.secondary,
      },
      {
        'titulo': 'Reservas',
        'cantidad': datos.reservas,
        'descripcion': 'Reservas registradas',
        'icono': Icons.event_available_rounded,
        'color': AppColors.info,
      },
      {
        'titulo': 'Reportes',
        'cantidad': datos.reportes,
        'descripcion': 'Solicitudes recibidas',
        'icono': Icons.assignment_rounded,
        'color': AppColors.tertiary,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final datos = _controller.estadisticas;
    final tarjetas = datos == null
        ? <Map<String, dynamic>>[]
        : _crearTarjetas(datos);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _actualizarEstadisticas,
          child: _construirContenido(tarjetas, datos),
        ),
      ),
    );
  }

  Widget _construirContenido(
    List<Map<String, dynamic>> tarjetas,
    ResumenEstadisticasModel? datos,
  ) {
    if (datos == null && _controller.cargando) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
        children: const [
          SizedBox(height: 12),
          Align(
            alignment: Alignment.topCenter,
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }

    if (datos == null && _controller.error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.cloud_off_rounded,
            size: 58,
            color: AppColors.secondary,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          const Text(
            'No se pudieron cargar las estadísticas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            _controller.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Center(
            child: ElevatedButton.icon(
              onPressed: _actualizarEstadisticas,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Intentar nuevamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnDark,
              ),
            ),
          ),
        ],
      );
    }

    if (datos == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 30),
          Center(
            child: Text('No hay estadísticas disponibles.'),
          ),
        ],
      );
    }

    // Durante la actualización se conserva el resumen superior
    // y se reemplaza todo lo demás por el indicador de carga.
    if (_controller.cargando) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
        children: [
          _construirResumenGeneral(datos),
          const SizedBox(height: AppDimensions.spacingLg),
          const Align(
            alignment: Alignment.topCenter,
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
      children: [
        _construirResumenGeneral(datos),
        const SizedBox(height: AppDimensions.spacingXl),
        _construirTituloSeccion(),
        const SizedBox(height: AppDimensions.spacingMd),
        if (tarjetas.isEmpty)
          _construirSinResultados()
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final ancho = constraints.maxWidth;
              final columnas = ancho >= 900
                  ? 4
                  : ancho >= 600
                      ? 3
                      : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tarjetas.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas,
                  crossAxisSpacing: AppDimensions.spacingMd,
                  mainAxisSpacing: AppDimensions.spacingMd,
                  childAspectRatio: ancho >= 600 ? 1.8 : 1.35,
                ),
                itemBuilder: (context, index) {
                  final tarjeta = tarjetas[index];

                  return TarjetaEstadistica(
                    titulo: tarjeta['titulo'] as String,
                    cantidad: (tarjeta['cantidad'] as int).toString(),
                    descripcion: tarjeta['descripcion'] as String,
                    icono: tarjeta['icono'] as IconData,
                    color: tarjeta['color'] as Color,
                  );
                },
              );
            },
          ),
        const SizedBox(height: AppDimensions.spacingXl),
        GraficaEstadisticasMensuales(
          anio: _controller.anioSeleccionado,
          aniosDisponibles: _controller.aniosDisponibles,
          datos: _controller.estadisticasMensuales,
          onCambiarAnio: _controller.seleccionarAnio,
        ),
        if (_controller.error != null) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          const Text(
            'No se pudo actualizar la información. '
            'Se muestran los últimos datos disponibles.',
            style: TextStyle(
              color: AppColors.warning,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.spacingXxl),
      ],
    );
  }

  Widget _construirResumenGeneral(
    ResumenEstadisticasModel datos,
  ) {
    final total = datos.usuarios +
        datos.resenas +
        datos.reservas +
        datos.reportes;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: const Color(0xFFB58A70),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: AppColors.secondary,
              size: 27,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registros de actividad',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                const Text(
                  'Suma de los cuatro indicadores',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  total.toString(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          IconButton(
            tooltip: 'Actualizar estadísticas',
            onPressed: _controller.cargando
                ? null
                : _actualizarEstadisticas,
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.primary,
            iconSize: 27,
            style: IconButton.styleFrom(
              backgroundColor:
                  AppColors.primary.withValues(alpha: 0.09),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTituloSeccion() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Indicadores principales',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(
          Icons.bar_chart_rounded,
          color: AppColors.secondary,
          size: 24,
        ),
      ],
    );
  }

  Widget _construirSinResultados() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: const Color(0xFFB58A70)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 42,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppDimensions.spacingMd),
          Text(
            'No se encontraron estadísticas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppDimensions.spacingXs),
          Text(
            'No hay estadísticas para mostrar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}