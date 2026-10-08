import 'package:flutter/material.dart';

import '../../models/ruta_model.dart';
import '../../services/ruta_service.dart';
import '../../services/sitio_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/navegacion/boton_regresar.dart';
import '../../widgets/publico/ruta_card.dart';
import '../../controllers/mapa_ruta_controller.dart';
import '../mapa_screen_2.dart';
import 'crear_ruta_usuario_screen.dart';

class RutasUsuarioScreen extends StatefulWidget {
  const RutasUsuarioScreen({
    super.key,
    required this.usuarioId,
    required this.token,
  });

  final String usuarioId;
  final String token;

  @override
  State<RutasUsuarioScreen> createState() =>
      _RutasUsuarioScreenState();
}

class _RutasUsuarioScreenState
    extends State<RutasUsuarioScreen> {
  final RutaService _rutaService = RutaService();
  final SitioService _sitioService = SitioService();

  List<RutaModel> _rutasPersonalizadas = [];
  List<RutaModel> _rutasPredefinidas = [];

  bool _cargando = true;
  String? _error;

  String? _rutaCargandoId;
  String? _rutaEliminandoId;

  static const int _maximoRutasPersonalizadas = 2;

  @override
  void initState() {
    super.initState();
    _cargarRutas();
  }

  // ==========================================================
  // CARGAR RUTAS
  // ==========================================================

  Future<void> _cargarRutas() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultados = await Future.wait([
        _rutaService.obtenerRutasPorUsuario(
          widget.usuarioId,
          token: widget.token,
        ),
        _rutaService.obtenerRutasPredefinidas(),
      ]);

      final rutasUsuario =
          resultados[0];

      final rutasDisponibles =
          resultados[1];

      final rutasPersonalizadas = rutasUsuario
          .where(
            (ruta) =>
                ruta.tipo == 'personalizada' &&
                ruta.activa,
          )
          .toList();

      final rutasPredefinidas = rutasDisponibles
          .where(
            (ruta) =>
                ruta.tipo == 'predefinida' &&
                ruta.activa,
          )
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _rutasPersonalizadas =
            rutasPersonalizadas;

        _rutasPredefinidas =
            rutasPredefinidas;

        _cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error =
            'No fue posible cargar las rutas.';
      });
    }
  }

  // ==========================================================
  // CONTADOR
  // ==========================================================

  int get _cantidadRutas =>
      _rutasPersonalizadas.length >
              _maximoRutasPersonalizadas
          ? _maximoRutasPersonalizadas
          : _rutasPersonalizadas.length;

  bool get _puedeCrearRuta =>
      _cantidadRutas <
      _maximoRutasPersonalizadas;

  // ==========================================================
  // ABRIR RUTA
  // ==========================================================

  Future<void> _abrirRuta(
    RutaModel ruta,
  ) async {
    if (_rutaCargandoId != null) {
      return;
    }

    setState(() {
      _rutaCargandoId = ruta.id;
    });

    try {
      final sitios =
          await _sitioService.obtenerSitios();

      final idsRuta =
          ruta.sitios.toSet();

      final sitiosRuta = sitios
          .where(
            (sitio) =>
                idsRuta.contains(sitio.id),
          )
          .toList();

      if (sitiosRuta.length < 2) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'No fue posible recuperar '
              'los sitios de esta ruta.',
            ),
          ),
        );

        return;
      }

      final rutaController =
          MapaRutaController();

      final cargada =
          await rutaController.cargarRutaGuardada(
        nombre: ruta.nombre,
        sitios: sitiosRuta,
      );

      if (!cargada) {
        final mensaje =
            rutaController.mensaje ??
                'No fue posible cargar la ruta.';

        rutaController.dispose();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(mensaje),
          ),
        );

        return;
      }

      if (!mounted) {
        rutaController.dispose();
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapaScreen2(
            rutaController:
                rutaController,
          ),
        ),
      );

      rutaController.dispose();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No fue posible abrir la ruta: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _rutaCargandoId = null;
        });
      }
    }
  }

  // ==========================================================
  // CONFIRMAR ELIMINACIÓN
  // ==========================================================

  Future<void> _confirmarEliminarRuta(
    RutaModel ruta,
  ) async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Eliminar ruta',
          ),
          content: Text(
            '¿Deseas eliminar la ruta '
            '"${ruta.nombre}"?\n\n'
            'Esta acción liberará uno de tus '
            '2 espacios disponibles para crear '
            'otra ruta personalizada.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    await _eliminarRuta(ruta);
  }

  // ==========================================================
  // ELIMINAR RUTA
  // ==========================================================

  Future<void> _eliminarRuta(
    RutaModel ruta,
  ) async {
    if (_rutaEliminandoId != null) {
      return;
    }

    setState(() {
      _rutaEliminandoId = ruta.id;
    });

    try {
      await _rutaService.eliminarRuta(
        ruta.id,
        token: widget.token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _rutasPersonalizadas.removeWhere(
          (item) => item.id == ruta.id,
        );
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Ruta eliminada correctamente.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No fue posible eliminar la ruta: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _rutaEliminandoId = null;
        });
      }
    }
  }

  // ==========================================================
  // CREAR NUEVA RUTA
  // ==========================================================

  Future<void> _crearRuta() async {
    if (!_puedeCrearRuta) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Ya tienes 2 rutas personalizadas. '
            'Elimina una o espera a que expire '
            'para crear otra.',
          ),
        ),
      );

      return;
    }

    final resultado =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CrearRutaUsuarioScreen(
          usuarioId: widget.usuarioId,
          token: widget.token,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (resultado == true) {
      await _cargarRutas();
    }
  }

  // ==========================================================
  // INFORMACIÓN DE EXPIRACIÓN
  // ==========================================================

  String _textoExpiracion(
    DateTime? venceEn,
  ) {
    if (venceEn == null) {
      return 'Sin fecha de expiración';
    }

    final ahora = DateTime.now();

    final diferencia =
        venceEn.difference(ahora);

    if (diferencia.isNegative ||
        diferencia.inSeconds <= 0) {
      return 'Expirada';
    }

    if (diferencia.inHours < 1) {
      final minutos =
          diferencia.inMinutes;

      if (minutos <= 0) {
        return 'Expira en menos de 1 min';
      }

      return 'Expira en $minutos min';
    }

    if (diferencia.inHours < 24) {
      return 'Expira en '
          '${diferencia.inHours} h';
    }

    return 'Expira el '
        '${venceEn.day.toString().padLeft(2, '0')}/'
        '${venceEn.month.toString().padLeft(2, '0')} '
        '${venceEn.hour.toString().padLeft(2, '0')}:'
        '${venceEn.minute.toString().padLeft(2, '0')}';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        leading:
            const BotonRegresar(),

        title: const Text(
          'Mis rutas',
        ),

        backgroundColor:
            AppColors.background,

        elevation: 0,
      ),

      body: RefreshIndicator(
        onRefresh: _cargarRutas,
        child:
            _construirContenido(),
      ),
    );
  }

  // ==========================================================
  // CONTENIDO
  // ==========================================================

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _construirError();
    }

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.all(
        AppDimensions.pageHorizontal,
      ),

      children: [
        _construirEncabezado(),

        const SizedBox(
          height:
              AppDimensions.spacingLg,
        ),

        _construirSeccionPersonalizadas(),

        const SizedBox(
          height:
              AppDimensions.spacingXl,
        ),

        _construirSeccionPredefinidas(),

        const SizedBox(
          height:
              AppDimensions.spacingXl,
        ),
      ],
    );
  }

  // ==========================================================
  // SECCIÓN RUTAS PERSONALIZADAS
  // ==========================================================

  Widget _construirSeccionPersonalizadas() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,

      children: [
        const Text(
          'Mis rutas personalizadas',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height:
              AppDimensions.spacingSm,
        ),

        if (_rutasPersonalizadas.isEmpty)
          _construirEstadoVacio()
        else
          ..._rutasPersonalizadas.map(
            (ruta) =>
                _construirRuta(
              ruta,
              personalizada: true,
            ),
          ),

        const SizedBox(
          height:
              AppDimensions.spacingSm,
        ),

        _construirBotonCrear(),
      ],
    );
  }

  // ==========================================================
  // SECCIÓN RUTAS PREDEFINIDAS
  // ==========================================================

  Widget _construirSeccionPredefinidas() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,

      children: [
        const Text(
          'Rutas predefinidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height:
              AppDimensions.spacingSm,
        ),

        if (_rutasPredefinidas.isEmpty)
          Container(
            padding:
                const EdgeInsets.all(
              AppDimensions.spacingLg,
            ),

            decoration:
                BoxDecoration(
              color:
                  AppColors.surface,

              borderRadius:
                  BorderRadius.circular(
                AppDimensions
                    .rutaCardRadius,
              ),
            ),

            child: const Text(
              'No hay rutas predefinidas '
              'disponibles en este momento.',
              textAlign:
                  TextAlign.center,
            ),
          )
        else
          ..._rutasPredefinidas.map(
            (ruta) =>
                _construirRuta(
              ruta,
              personalizada: false,
            ),
          ),
      ],
    );
  }

  // ==========================================================
  // ENCABEZADO
  // ==========================================================

  Widget _construirEncabezado() {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors.surface,

        borderRadius:
            BorderRadius.circular(
          AppDimensions
              .rutaCardRadius,
        ),
      ),

      child: Row(
        children: [
          Container(
            width:
                AppDimensions
                    .rutaIconContainer,

            height:
                AppDimensions
                    .rutaIconContainer,

            decoration:
                BoxDecoration(
              color:
                  AppColors.primary
                      .withValues(
                alpha: 0.12,
              ),

              borderRadius:
                  BorderRadius.circular(
                AppDimensions
                    .rutaCardRadius,
              ),
            ),

            child: const Icon(
              Icons.alt_route,
              color:
                  AppColors.primary,
            ),
          ),

          const SizedBox(
            width:
                AppDimensions.spacingMd,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                const Text(
                  'Rutas personalizadas',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(
                  height:
                      AppDimensions
                          .spacingXs,
                ),

                Text(
                  'Puedes tener hasta '
                  '$_maximoRutasPersonalizadas '
                  'rutas guardadas.',
                ),
              ],
            ),
          ),

          Text(
            '$_cantidadRutas/'
            '$_maximoRutasPersonalizadas',

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,

              fontSize: 20,

              color:
                  AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RUTA
  // ==========================================================

  Widget _construirRuta(
    RutaModel ruta, {
    required bool personalizada,
  }) {
    final cargando =
        _rutaCargandoId ==
            ruta.id;

    final eliminando =
        _rutaEliminandoId ==
            ruta.id;

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom:
            AppDimensions.spacingMd,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          Stack(
            children: [
              RutaCard(
                ruta: ruta,

                onTap:
                    cargando ||
                            eliminando
                        ? () {}
                        : () =>
                            _abrirRuta(
                              ruta,
                            ),
              ),

              if (personalizada)
                Positioned(
                  top:
                      AppDimensions
                          .spacingSm,

                  right:
                      AppDimensions
                          .spacingSm,

                  child: Material(
                    color:
                        Colors.transparent,

                    child:
                        IconButton(
                      tooltip:
                          'Eliminar ruta',

                      onPressed:
                          cargando ||
                                  eliminando
                              ? null
                              : () =>
                                  _confirmarEliminarRuta(
                                    ruta,
                                  ),

                      icon:
                          eliminando
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .delete_outline,
                                ),

                      color:
                          AppColors
                              .primary,
                    ),
                  ),
                ),

              if (cargando)
                Positioned.fill(
                  child:
                      Container(
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.black
                              .withValues(
                        alpha: 0.08,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        AppDimensions
                            .rutaCardRadius,
                      ),
                    ),

                    child:
                        const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal:
                  AppDimensions
                      .spacingSm,
            ),

            child: Row(
              children: [
                const Icon(
                  Icons
                      .schedule_outlined,

                  size: 16,

                  color:
                      AppColors.primary,
                ),

                const SizedBox(
                  width:
                      AppDimensions
                          .spacingXs,
                ),

                Expanded(
                  child: Text(
                    personalizada
                        ? _textoExpiracion(
                            ruta.venceEn,
                          )
                        : 'Ruta predefinida · '
                          'disponible siempre',

                    style:
                        const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),

                Text(
                  '${ruta.sitios.length} '
                  '${ruta.sitios.length == 1 ? 'sitio' : 'sitios'}',

                  style:
                      const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BOTÓN CREAR
  // ==========================================================

  Widget _construirBotonCrear() {
    return SizedBox(
      width:
          double.infinity,

      child:
          FilledButton.icon(
        onPressed:
            _crearRuta,

        icon:
            const Icon(
          Icons.add,
        ),

        label:
            Text(
          _puedeCrearRuta
              ? 'Crear nueva ruta'
              : 'Límite de 2 rutas alcanzado',
        ),
      ),
    );
  }

  // ==========================================================
  // ESTADO VACÍO
  // ==========================================================

  Widget _construirEstadoVacio() {
    return Container(
      padding:
          const EdgeInsets.all(
        AppDimensions
            .spacingXl,
      ),

      decoration:
          BoxDecoration(
        color:
            AppColors.surface,

        borderRadius:
            BorderRadius.circular(
          AppDimensions
              .rutaCardRadius,
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.route_outlined,

            size: 64,

            color:
                AppColors.primary,
          ),

          const SizedBox(
            height:
                AppDimensions.spacingLg,
          ),

          const Text(
            'Todavía no tienes '
            'rutas personalizadas',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,

              fontSize: 18,
            ),
          ),

          const SizedBox(
            height:
                AppDimensions.spacingSm,
          ),

          const Text(
            'Crea una ruta personalizada '
            'para organizar tus sitios turísticos.',

            textAlign:
                TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  Widget _construirError() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.all(
        AppDimensions
            .pageHorizontal,
      ),

      children: [
        const SizedBox(
          height: 80,
        ),

        const Icon(
          Icons.error_outline,

          size: 64,

          color:
              AppColors.primary,
        ),

        const SizedBox(
          height:
              AppDimensions.spacingLg,
        ),

        Text(
          _error ??
              'Ocurrió un error.',

          textAlign:
              TextAlign.center,
        ),

        const SizedBox(
          height:
              AppDimensions.spacingLg,
        ),

        FilledButton.icon(
          onPressed:
              _cargarRutas,

          icon:
              const Icon(
            Icons.refresh,
          ),

          label:
              const Text(
            'Intentar nuevamente',
          ),
        ),
      ],
    );
  }
}