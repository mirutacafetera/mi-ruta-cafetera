import 'package:flutter/material.dart';

import '../../../controllers/admin/estadistica/estadistica_controller.dart';
import '../../../models/admin/estadistica_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/estadistica/resumen_reportes.dart';
import '../../../widgets/admin/estadistica/tarjeta_estadistica.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';

class PantallaEstadistica extends StatefulWidget {
  const PantallaEstadistica({super.key});

  @override
  State<PantallaEstadistica> createState() =>
      _PantallaEstadisticaState();
}

class _PantallaEstadisticaState extends State<PantallaEstadistica> {
  late final EstadisticaController _controller;

  final TextEditingController _busquedaController =
      TextEditingController();

  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _controller = EstadisticaController();
    _controller.addListener(_actualizarPantalla);
    _controller.cargarEstadisticas();
  }

  void _actualizarPantalla() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_actualizarPantalla);
    _controller.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _actualizarEstadisticas() async {
    await _controller.actualizarEstadisticas();
  }

  void _limpiarBusqueda() {
    _busquedaController.clear();
    setState(() {
      _busqueda = '';
    });
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

    final tarjetasFiltradas = tarjetas.where((tarjeta) {
      final titulo = tarjeta['titulo'].toString().toLowerCase();
      final descripcion =
          tarjeta['descripcion'].toString().toLowerCase();
      final consulta = _busqueda.trim().toLowerCase();

      return titulo.contains(consulta) ||
          descripcion.contains(consulta);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            EncabezadoLista(
              titulo: 'Estadísticas',
              descripcion:
                  'Actividad y participación de los usuarios',
              textoNuevo: '',
              cantidad: tarjetas.length,
              cargando: _controller.cargando,
              mostrarBotonNuevo: false,
              onActualizar: _actualizarEstadisticas,
              onNuevo: () {},
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _actualizarEstadisticas,
                child: _construirContenido(
                  tarjetasFiltradas,
                  datos,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirContenido(
    List<Map<String, dynamic>> tarjetas,
    ResumenEstadisticasModel? datos,
  ) {
    if (_controller.cargando && datos == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_controller.error != null && datos == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(
          AppDimensions.pageHorizontal,
        ),
        children: [
          const SizedBox(height: 90),
          Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
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
      return const Center(
        child: Text('No hay estadísticas disponibles.'),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(
        AppDimensions.pageHorizontal,
      ),
      children: [
        _construirBienvenida(),
        const SizedBox(height: AppDimensions.spacingXl),
        _construirResumenGeneral(datos),
        const SizedBox(height: AppDimensions.spacingXl),
        BarraBusqueda(
          valor: _busqueda,
          textoAyuda: 'Buscar estadísticas...',
          onChanged: (valor) {
            setState(() {
              _busqueda = valor;
            });
          },
          onLimpiar: _limpiarBusqueda,
          controller: _busquedaController,
        ),
        const SizedBox(height: AppDimensions.spacingLg),
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
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas,
                  crossAxisSpacing: AppDimensions.spacingMd,
                  mainAxisSpacing: AppDimensions.spacingMd,
                  childAspectRatio: ancho >= 600 ? 1.15 : 0.88,
                ),
                itemBuilder: (context, index) {
                  final tarjeta = tarjetas[index];

                  return TarjetaEstadistica(
                    titulo: tarjeta['titulo'] as String,
                    cantidad:
                        (tarjeta['cantidad'] as int).toString(),
                    descripcion:
                        tarjeta['descripcion'] as String,
                    icono: tarjeta['icono'] as IconData,
                    color: tarjeta['color'] as Color,
                  );
                },
              );
            },
          ),
        const SizedBox(height: AppDimensions.spacingXxl),
        _construirTituloReportes(),
        const SizedBox(height: AppDimensions.spacingMd),
        ResumenReportes(
          total: datos.reportes,
          pendientes: datos.reportesPendientes,
          enRevision: datos.reportesEnRevision,
          resueltos: datos.reportesResueltos,
        ),
        if (_controller.error != null) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
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

  Widget _construirBienvenida() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.heroRadius,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Panel de actividad',
                  style: TextStyle(
                    color: AppColors.textOnDark,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  'Consulta los datos de participación '
                  'de Mi Ruta Cafetera.',
                  style: TextStyle(
                    color: AppColors.textOnDarkSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: AppColors.secondary,
              size: 32,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: AppColors.secondary,
              size: 27,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registros de actividad',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXs),
                Text(
                  'Suma de los cuatro indicadores',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
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

  Widget _construirTituloReportes() {
    return const Row(
      children: [
        Expanded(
          child: Text(
            'Estado de los reportes',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Icon(
          Icons.assignment_turned_in_rounded,
          color: AppColors.secondary,
          size: 24,
        ),
      ],
    );
  }

  Widget _construirSinResultados() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingXl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
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
            'Prueba con otro término de búsqueda.',
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