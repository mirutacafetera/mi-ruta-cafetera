import 'package:flutter/material.dart';

import '../../services/sitio/sitio_dashboard_service.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

import '../../widgets/sitio/tarjeta_estadistica_sitio.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

import '../../models/sitio/sitio_dashboard_model.dart';

class SitioDashboardScreen extends StatefulWidget {
  const SitioDashboardScreen({super.key});

  @override
  State<SitioDashboardScreen> createState() =>
      _SitioDashboardScreenState();
}

class _SitioDashboardScreenState
    extends State<SitioDashboardScreen> {

  // =====================================================
  // SERVICIO
  // =====================================================

  final SitioDashboardService _dashboardService =
      SitioDashboardService();

  // =====================================================
  // ESTADO
  // =====================================================

  SitioDashboardModel? _dashboard;

  bool _cargando = true;

  String? _error;

  // =====================================================
  // TOKEN
  // =====================================================

  /*
   * Temporalmente dejaremos el token definido aquÃ­
   * hasta conectar el servicio de autenticaciÃ³n del sitio.
   *
   * En el siguiente paso lo obtendremos desde la sesiÃ³n
   * real de la cuenta.
   */

  final String _token = '';

  // =====================================================
  // CICLO DE VIDA
  // =====================================================

  @override
  void initState() {
    super.initState();

    _cargarDashboard();
  }

  // =====================================================
  // CARGAR DASHBOARD
  // =====================================================

  Future<void> _cargarDashboard() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {

      /*
       * TodavÃ­a necesitamos conectar aquÃ­ el token real
       * de la sesiÃ³n del sitio.
       */

      if (_token.isEmpty) {
        throw Exception(
          'No hay una sesiÃ³n de sitio disponible.',
        );
      }

      final dashboard =
          await _dashboardService.obtenerDashboard(
        _token,
      );

      if (!mounted) return;

      setState(() {
        _dashboard = dashboard;
        _cargando = false;
      });

    } catch (error) {

      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _cargando = false;
      });
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;

    final esEscritorio = ancho >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.all(
        esEscritorio
            ? AppDimensions.spacingXl
            : AppDimensions.spacingMd,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1400,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              _encabezadoDashboard(
                context,
                esEscritorio,
              ),

              SizedBox(
                height: esEscritorio
                    ? AppDimensions.spacingXl
                    : AppDimensions.spacingLg,
              ),

              _contenidoDashboard(
                esEscritorio,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // CONTENIDO DEL DASHBOARD
  // =====================================================

  Widget _contenidoDashboard(
    bool esEscritorio,
  ) {
    if (_cargando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(
            AppDimensions.spacingXl,
          ),
          child: CircularProgressIndicator(),
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        _seccionEstadisticas(
          esEscritorio,
        ),

        SizedBox(
          height: esEscritorio
              ? AppDimensions.spacingXl
              : AppDimensions.spacingLg,
        ),

        _contenidoPrincipal(
          context,
          esEscritorio,
        ),
      ],
    );
  }

  // =====================================================
  // ENCABEZADO
  // =====================================================

  Widget _encabezadoDashboard(
    BuildContext context,
    bool esEscritorio,
  ) {
    final nombreSitio =
        _dashboard?.nombreSitio;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        esEscritorio
            ? AppDimensions.spacingXl
            : AppDimensions.spacingLg,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  nombreSitio == null ||
                          nombreSitio.isEmpty
                      ? 'Â¡Bienvenido a tu panel! â˜•'
                      : 'Â¡Bienvenido a $nombreSitio! â˜•',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Administra la informaciÃ³n de tu sitio turÃ­stico y '
                  'mantÃ©n actualizada tu experiencia en Mi Ruta Cafetera.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(
                        color: Colors.white.withValues(
                          alpha: 0.88,
                        ),
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),

          if (esEscritorio) ...[
            const SizedBox(
              width: AppDimensions.spacingLg,
            ),

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.14,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.coffee_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // ESTADÃSTICAS
  // =====================================================

  Widget _seccionEstadisticas(
    bool esEscritorio,
  ) {
    final dashboard = _dashboard!;

    final tarjetas = [
      const TarjetaEstadisticaSitio(
        titulo: 'Visitas',
        valor: '0',
        descripcion: 'Visitas a tu sitio',
        icono: Icons.visibility_rounded,
      ),

      TarjetaEstadisticaSitio(
        titulo: 'Reservas',
        valor: dashboard.totalReservas.toString(),
        descripcion: 'Reservas recibidas',
        icono: Icons.calendar_month_rounded,
      ),

      TarjetaEstadisticaSitio(
        titulo: 'ReseÃ±as',
        valor: dashboard.totalResenas.toString(),
        descripcion:
            'Promedio ${dashboard.promedioCalificacion.toStringAsFixed(1)} â­',
        icono: Icons.star_rounded,
      ),

      TarjetaEstadisticaSitio(
        titulo: 'Actividades',
        valor: dashboard.totalActividades.toString(),
        descripcion: 'Actividades publicadas',
        icono: Icons.local_activity_rounded,
      ),
    ];

    if (esEscritorio) {
      return GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: tarjetas.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing:
              AppDimensions.spacingMd,
          mainAxisSpacing:
              AppDimensions.spacingMd,
          childAspectRatio: 1.55,
        ),
        itemBuilder: (
          context,
          index,
        ) {
          return tarjetas[index];
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: tarjetas.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing:
            AppDimensions.spacingSm,
        mainAxisSpacing:
            AppDimensions.spacingSm,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (
        context,
        index,
      ) {
        return tarjetas[index];
      },
    );
  }

  // =====================================================
  // CONTENIDO PRINCIPAL
  // =====================================================

  Widget _contenidoPrincipal(
    BuildContext context,
    bool esEscritorio,
  ) {
    if (esEscritorio) {
      return Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Expanded(
            flex: 3,
            child: _seccionAcciones(context),
          ),

          const SizedBox(
            width: AppDimensions.spacingLg,
          ),

          Expanded(
            flex: 2,
            child: _estadoSitio(context),
          ),
        ],
      );
    }

    return Column(
      children: [

        _seccionAcciones(context),

        const SizedBox(
          height: AppDimensions.spacingLg,
        ),

        _estadoSitio(context),
      ],
    );
  }

  // =====================================================
  // ACCIONES RÃPIDAS
  // =====================================================

  Widget _seccionAcciones(
    BuildContext context,
  ) {
    return TarjetaSeccionSitio(
      titulo: 'Acciones rÃ¡pidas',
      subtitulo:
          'Gestiona rÃ¡pidamente la informaciÃ³n de tu sitio.',
      icono: Icons.bolt_rounded,
      child: Column(
        children: [

          _accionRapida(
            icono: Icons.storefront_rounded,
            titulo: 'Mi sitio',
            descripcion:
                'Consulta y actualiza la informaciÃ³n principal.',
            onTap: () {},
          ),

          const Divider(),

          _accionRapida(
            icono: Icons.article_rounded,
            titulo: 'Contenido',
            descripcion:
                'Administra la descripciÃ³n y la informaciÃ³n turÃ­stica.',
            onTap: () {},
          ),

          const Divider(),

          _accionRapida(
            icono: Icons.photo_library_rounded,
            titulo: 'Multimedia',
            descripcion:
                'Gestiona fotografÃ­as y material visual.',
            onTap: () {},
          ),

          const Divider(),

          _accionRapida(
            icono: Icons.local_activity_rounded,
            titulo: 'Actividades',
            descripcion:
                'Agrega y administra las actividades de tu sitio.',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ACCIÃ“N RÃPIDA
  // =====================================================

  Widget _accionRapida({
    required IconData icono,
    required String titulo,
    required String descripcion,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          children: [

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  AppDimensions.radiusMd,
                ),
              ),
              child: Icon(
                icono,
                color: AppColors.primary,
              ),
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
                    titulo,
                    style: const TextStyle(
                      color:
                          AppColors.textPrimary,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    descripcion,
                    style: const TextStyle(
                      color:
                          AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color:
                  AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ESTADO DEL SITIO
  // =====================================================

  Widget _estadoSitio(
    BuildContext context,
  ) {
    final dashboard = _dashboard!;

    return TarjetaSeccionSitio(
      titulo: 'Estado del sitio',
      subtitulo:
          'InformaciÃ³n general de tu cuenta.',
      icono: Icons.verified_rounded,
      child: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                AppDimensions.radiusMd,
              ),
            ),
            child: Row(
              children: [

                Icon(
                  dashboard.activo
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),

                const SizedBox(
                  width: AppDimensions.spacingSm,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        dashboard.activo
                            ? 'Sitio activo'
                            : 'Sitio inactivo',
                        style: const TextStyle(
                          color:
                              AppColors.textPrimary,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        dashboard.activo
                            ? 'Tu sitio estÃ¡ disponible en la plataforma.'
                            : 'Tu sitio no estÃ¡ disponible actualmente.',
                        style: const TextStyle(
                          color:
                              AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: AppDimensions.spacingMd,
          ),

          _filaEstado(
            icono: Icons.person_rounded,
            titulo: 'Cuenta',
            valor: 'Activa',
          ),

          const Divider(),

          _filaEstado(
            icono:
                Icons.calendar_month_rounded,
            titulo: 'Reservas pendientes',
            valor: dashboard
                .reservasPendientes
                .toString(),
          ),

          const Divider(),

          _filaEstado(
            icono:
                Icons.check_circle_outline_rounded,
            titulo: 'Reservas confirmadas',
            valor: dashboard
                .reservasConfirmadas
                .toString(),
          ),

          const Divider(),

          _filaEstado(
            icono:
                Icons.description_rounded,
            titulo: 'Contenido',
            valor:
                dashboard.totalContenidos
                    .toString(),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // FILA DE ESTADO
  // =====================================================

  Widget _filaEstado({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [

          Icon(
            icono,
            size: 21,
            color: AppColors.textSecondary,
          ),

          const SizedBox(
            width: AppDimensions.spacingSm,
          ),

          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            valor,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ESTADO DE ERROR
  // =====================================================

  Widget _estadoError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingXl,
        ),
        child: Column(
          children: [

            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),

            const SizedBox(
              height: AppDimensions.spacingMd,
            ),

            const Text(
              'No fue posible cargar el dashboard',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),

            const SizedBox(
              height: AppDimensions.spacingSm,
            ),

            Text(
              _error ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(
              height: AppDimensions.spacingMd,
            ),

            ElevatedButton(
              onPressed: _cargarDashboard,
              child: const Text(
                'Intentar nuevamente',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ESTADO VACÃO
  // =====================================================

  Widget _estadoVacio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(
          AppDimensions.spacingXl,
        ),
        child: Text(
          'No hay informaciÃ³n disponible.',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
