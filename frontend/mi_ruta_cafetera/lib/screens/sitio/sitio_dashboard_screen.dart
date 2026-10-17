
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

class _SitioDashboardScreenState extends State<SitioDashboardScreen> {
  final SitioDashboardService _dashboardService =
      SitioDashboardService();

  final SitioSesionService _sesionService = SitioSesionService();

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
        throw Exception('No hay una sesión de sitio disponible.');
      }

      if (!sesion.activo) {
        throw Exception('La cuenta del sitio está inactiva.');
      }

      final dashboard = await _dashboardService.obtenerDashboard(
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
        _error = error.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esEscritorio = constraints.maxWidth >= 900;

        return ColoredBox(
          color: AppColors.sitioBackground,
          child: RefreshIndicator(
            color: AppColors.sitioPrimary,
            backgroundColor: AppColors.sitioSurface,
            onRefresh: _cargarDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                esEscritorio
                    ? AppDimensions.pageHorizontal
                    : AppDimensions.sitioPagePadding,
                AppDimensions.sitioSectionGapCompact,
                esEscritorio
                    ? AppDimensions.pageHorizontal
                    : AppDimensions.sitioPagePadding,
                AppDimensions.sitioSectionGap,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EncabezadoDashboardSitio(
                        dashboard: _dashboard,
                        esEscritorio: esEscritorio,
                      ),
                      SizedBox(
                        height: esEscritorio
                            ? AppDimensions.sitioSectionGap
                            : AppDimensions.sitioSectionGapCompact,
                      ),
                      _contenidoDashboard(escritorio: esEscritorio),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _contenidoDashboard({required bool escritorio}) {
    if (_cargando) {
      return _estadoCarga();
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
              ? AppDimensions.sitioSectionGap
              : AppDimensions.sitioSectionGapCompact,
        ),
        _contenidoPrincipal(escritorio: escritorio),
      ],
    );
  }

  Widget _contenidoPrincipal({required bool escritorio}) {
    if (escritorio) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 3,
            child: AccionesDashboardSitio(esEscritorio: true),
          ),
          const SizedBox(width: AppDimensions.sitioPanelCardGap),
          Expanded(
            flex: 2,
            child: EstadoDashboardSitio(dashboard: _dashboard!),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AccionesDashboardSitio(esEscritorio: false),
        const SizedBox(height: AppDimensions.sitioSectionGapCompact),
        EstadoDashboardSitio(dashboard: _dashboard!),
      ],
    );
  }

  Widget _estadoCarga() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sitioPanelCardPadding,
        vertical: AppDimensions.sitioSectionGap,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(color: AppColors.sitioBorder),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.sitioPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Preparando tu panel...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.sitioTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppDimensions.spacingXs),
          Text(
            'Estamos consultando la información de tu sitio.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _estadoError() {
    return _tarjetaMensaje(
      icono: Icons.cloud_off_rounded,
      color: AppColors.sitioError,
      fondoIcono: AppColors.sitioErrorSoft,
      titulo: 'No pudimos cargar tu panel',
      mensaje: _error ?? 'Ocurrió un error inesperado.',
      accion: OutlinedButton.icon(
        onPressed: _cargarDashboard,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.sitioPrimary,
          side: const BorderSide(color: AppColors.sitioPrimary),
          minimumSize: const Size(
            0,
            AppDimensions.sitioButtonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Intentar nuevamente'),
      ),
    );
  }

  Widget _estadoVacio() {
    return _tarjetaMensaje(
      icono: Icons.coffee_outlined,
      color: AppColors.sitioPrimary,
      fondoIcono: AppColors.sitioSurfaceGreen,
      titulo: 'Tu panel está listo para comenzar',
      mensaje: 'Por ahora no hay información disponible para mostrar.',
    );
  }

  Widget _tarjetaMensaje({
    required IconData icono,
    required Color color,
    required Color fondoIcono,
    required String titulo,
    required String mensaje,
    Widget? accion,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(color: AppColors.sitioBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: fondoIcono,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusLg,
              ),
            ),
            child: Icon(icono, color: color, size: 28),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              height: 1.5,
            ),
          ),
          if (accion != null) ...[
            const SizedBox(height: AppDimensions.spacingLg),
            accion,
          ],
        ],
      ),
    );
  }
}
