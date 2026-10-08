import 'package:flutter/material.dart';

import '../../models/sitio/sitio_dashboard_model.dart';
import '../../services/sitio/sitio_dashboard_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/acciones_dashboard_sitio.dart';
import '../../widgets/sitio/encabezado_dashboard_sitio.dart';
import '../../widgets/sitio/estado_dashboard_sitio.dart';
import '../../widgets/sitio/estadisticas_dashboard_sitio.dart';

class SitioDashboardScreen extends StatefulWidget {
  const SitioDashboardScreen({super.key});

  @override
  State<SitioDashboardScreen> createState() =>
      _SitioDashboardScreenState();
}

class _SitioDashboardScreenState
    extends State<SitioDashboardScreen> {
  final SitioDashboardService _dashboardService =
      SitioDashboardService();

  final SitioSesionService _sesionService =
      SitioSesionService();

  SitioDashboardModel? _dashboard;

  bool _cargando = true;

  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDashboard();
  }

  Future<void> _cargarDashboard() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception(
          'No hay una sesión de sitio disponible.',
        );
      }

      if (!sesion.activo) {
        throw Exception(
          'La cuenta del sitio está inactiva.',
        );
      }

      final dashboard =
          await _dashboardService.obtenerDashboard(
        sesion.token,
      );

      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString().replaceFirst(
              'Exception: ',
              '',
            );
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esEscritorio = ancho >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: esEscritorio
            ? AppDimensions.pageHorizontal
            : AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingLg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1400,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EncabezadoDashboardSitio(
                dashboard: _dashboard,
                esEscritorio: esEscritorio,
              ),
              SizedBox(
                height: esEscritorio
                    ? AppDimensions.spacingXl
                    : AppDimensions.spacingLg,
              ),
              _contenidoDashboard(escritorio: esEscritorio),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contenidoDashboard({
    required bool escritorio,
  }) {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(
            AppDimensions.spacingXl,
          ),
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_error != null) {
      return _estadoError();
    }

    if (_dashboard == null) {
      return _estadoVacio();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EstadisticasDashboardSitio(
          dashboard: _dashboard!,
          esEscritorio: escritorio,
        ),
        SizedBox(
          height: escritorio
              ? AppDimensions.spacingXl
              : AppDimensions.spacingLg,
        ),
        _contenidoPrincipal(escritorio: escritorio),
      ],
    );
  }

  Widget _contenidoPrincipal({
    required bool escritorio,
  }) {
    if (escritorio) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 3,
            child: AccionesDashboardSitio(
              esEscritorio: true,
            ),
          ),
          const SizedBox(
            width: AppDimensions.spacingLg,
          ),
          Expanded(
            flex: 2,
            child: EstadoDashboardSitio(
              dashboard: _dashboard!,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const AccionesDashboardSitio(
          esEscritorio: false,
        ),
        const SizedBox(
          height: AppDimensions.spacingLg,
        ),
        EstadoDashboardSitio(
          dashboard: _dashboard!,
        ),
      ],
    );
  }

  Widget _estadoError() {
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
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.55,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.coffeeDark,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            'No fue posible cargar el dashboard',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          Text(
            _error ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          ElevatedButton.icon(
            onPressed: _cargarDashboard,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'Intentar nuevamente',
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoVacio() {
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
        border: Border.all(
          color: AppColors.border.withValues(
            alpha: 0.55,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.coffee_outlined,
            color: AppColors.primary,
            size: AppDimensions.iconLg,
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          Text(
            'No hay información disponible.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}