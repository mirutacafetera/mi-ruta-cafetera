import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../services/ruta_service.dart';
import '../../services/sitio_service.dart';
import '../../services/ubicacion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/navegacion/boton_regresar.dart';
import '../../controllers/mapa_ruta_controller.dart';
import '../mapa_screen_2.dart';
import '../../l10n/textos.dart';

class CrearRutaUsuarioScreen extends StatefulWidget {
  const CrearRutaUsuarioScreen({
    super.key,
    required this.usuarioId,
    required this.token,
  });

  final String usuarioId;
  final String token;

  @override
  State<CrearRutaUsuarioScreen> createState() =>
      _CrearRutaUsuarioScreenState();
}

class _CrearRutaUsuarioScreenState
    extends State<CrearRutaUsuarioScreen> {
  final SitioService _sitioService = SitioService();
  final RutaService _rutaService = RutaService();

  late final MapaRutaController _rutaController;

  final TextEditingController _nombreController =
      TextEditingController(
    text: 'Mi ruta personalizada',
  );

  List<SitioTuristicoModel> _sitios = [];

  bool _cargando = true;
  bool _calculando = false;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _rutaController = MapaRutaController();

    _rutaController.iniciar();

    _cargarSitios();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _rutaController.dispose();

    super.dispose();
  }

  // ============================================================
  // CARGAR SITIOS
  // ============================================================

  Future<void> _cargarSitios() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final sitios = await _sitioService.obtenerSitios();

      if (!mounted) {
        return;
      }

      setState(() {
        _sitios = sitios
            .where(
              (sitio) =>
                  sitio.activo &&
                  sitio.enAreaTuristica,
            )
            .toList();

        _cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error =
            Textos.t('No fue posible cargar los sitios turísticos.');
      });
    }
  }

  // ============================================================
  // SELECCIONAR SITIO
  // ============================================================

  void _alternarSitio(
    SitioTuristicoModel sitio,
  ) {
    final seleccionado =
        _rutaController.estado.estaSeleccionado(sitio);

    final resultado =
        _rutaController.alternarSitio(sitio);

    if (!resultado && !seleccionado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Tr(
            'Ya alcanzaste el máximo de sitios para la ruta.',
          ),
        ),
      );

      return;
    }

    setState(() {});
  }

  // ============================================================
  // CALCULAR RUTA
  // ============================================================

  Future<void> _calcularRuta() async {
    final seleccionados =
        _rutaController.sitiosSeleccionados;

    if (seleccionados.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Tr(
            'Selecciona mínimo 2 sitios para calcular la ruta.',
          ),
        ),
      );

      return;
    }

    final nombre =
        _nombreController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Tr(
            'Escribe un nombre para tu ruta.',
          ),
        ),
      );

      return;
    }

    if (widget.usuarioId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Tr(
            'No se encontró el usuario actual.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _calculando = true;
    });

    // ------------------------------------------------------------
    // 1. CALCULAR RECORRIDO REAL
    // ------------------------------------------------------------

    // Punto de partida: ubicación real del usuario. Si no se
    // puede usar (GPS desactivado, permiso denegado, fuera del
    // corredor) la ruta empieza en el primer sitio y el resumen
    // lo explica.
    final origen =
        await UbicacionService.obtenerOrigenRuta();

    if (!mounted) {
      return;
    }

    final correcto =
        await _rutaController.calcularRuta(
      origen: origen.punto,
      avisoOrigen: origen.aviso,
    );

    if (!mounted) {
      return;
    }

    if (!correcto) {
      setState(() {
        _calculando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _rutaController.mensaje ??
                Textos.t('No fue posible calcular la ruta.'),
          ),
        ),
      );

      return;
    }

    setState(() {
      _calculando = false;
    });

    // ------------------------------------------------------------
    // 2. MOSTRAR RESUMEN
    // ------------------------------------------------------------

    final confirmar =
        await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RutaResumenUsuarioScreen(
          rutaController: _rutaController,
          nombreRuta: nombre,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    // El usuario decidió cambiar la selección.
    if (confirmar != true) {
      _rutaController.iniciar();

      setState(() {});

      return;
    }

    // ------------------------------------------------------------
    // 3. CONFIRMAR Y GUARDAR
    // ------------------------------------------------------------

    await _guardarRuta(nombre);
  }

  // ============================================================
  // GUARDAR RUTA CONFIRMADA
  // ============================================================

  Future<void> _guardarRuta(
    String nombre,
  ) async {
    final sitiosIds = _rutaController.rutaGuardadaSitios
        .map((sitio) => sitio.id)
        .where(
          (id) => id.trim().isNotEmpty,
        )
        .toList();

    if (sitiosIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Tr(
            'No fue posible identificar los sitios de la ruta.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final creada = await _rutaService.crearRuta(
        usuarioId: widget.usuarioId,
        nombre: nombre,
        sitios: sitiosIds,
        descripcion:
            'Ruta personalizada creada desde la aplicación.',
        tipo: 'personalizada',
        activa: true,
        token: widget.token,
      );

      // Recuerda que esta ruta ya está guardada para que el mapa
      // no vuelva a ofrecer guardarla.
      _rutaController.marcarRutaPersistida(
        id: creada.id,
        nombre: nombre,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Tr(
            'La ruta se calculó, pero no pudo guardarse: {0}', args: [e],
          ),
        ),
      );

      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _guardando = false;
    });

    // ------------------------------------------------------------
    // 4. ABRIR MAPA
    // ------------------------------------------------------------
    //
    // La ruta ya fue revisada y confirmada: se marca como
    // confirmada para que el mapa dibuje la geometría de la
    // carretera y salga del modo de creación.
    // ------------------------------------------------------------

    _rutaController.confirmarRuta();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapaScreen2(
          rutaController: _rutaController,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  // ============================================================
  // TARJETA DE SITIO
  // ============================================================

  Widget _construirSitioCard(
    SitioTuristicoModel sitio,
  ) {
    final seleccionado =
        _rutaController.estado.estaSeleccionado(sitio);

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusXl,
        ),
        border: Border.all(
          color: seleccionado
              ? AppColors.primary
              : AppColors.border,
          width: seleccionado ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusXl,
          ),
          onTap: () => _alternarSitio(sitio),
          child: Padding(
            padding: const EdgeInsets.all(
              AppDimensions.spacingMd,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? AppColors.primary
                        : AppColors.getSoftColorForCategory(
                            sitio.categoriaNombre,
                          ),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                  child: Icon(
                    Icons.place_rounded,
                    color: seleccionado
                        ? AppColors.textOnDark
                        : AppColors.primary,
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
                        sitio.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: AppDimensions.spacingXs,
                      ),
                      Text(
                        sitio.categoriaNombre.isEmpty
                            ? Textos.t('Sitio turístico')
                            : sitio.categoriaNombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (sitio.ciudad.isNotEmpty) ...[
                        const SizedBox(
                          height: AppDimensions.spacingXs,
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color:
                                  AppColors.textSecondary,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Expanded(
                              child: Text(
                                sitio.ciudad,
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color:
                                      AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(
                  width: AppDimensions.spacingSm,
                ),
                AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 180),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: seleccionado
                        ? AppColors.primary
                        : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    seleccionado
                        ? Icons.check_rounded
                        : Icons.add_rounded,
                    size: 20,
                    color: seleccionado
                        ? AppColors.textOnDark
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESUMEN DE SELECCIÓN
  // ============================================================

  Widget _construirResumen() {
    final seleccionados =
        _rutaController.sitiosSeleccionados;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSoftColorForCategory(
          'naturaleza',
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.route_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(
            width: AppDimensions.spacingSm,
          ),
          Expanded(
            child: Tr(
              '{0} sitios seleccionados', args: [seleccionados.length],
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Tr(
            'Máx. 4',
            style: TextStyle(
              color: AppColors.primary.withValues(
                alpha: 0.75,
              ),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTÓN CALCULAR
  // ============================================================

  Widget _construirBotonCalcular() {
    final cantidad =
        _rutaController.sitiosSeleccionados.length;

    final habilitado =
        cantidad >= 2 &&
        !_calculando &&
        !_guardando;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed:
            habilitado ? _calcularRuta : null,
        icon: _calculando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textOnDark,
                ),
              )
            : const Icon(
                Icons.alt_route_rounded,
              ),
        label: Text(
          _calculando
              ? Textos.t('Calculando ruta...')
              : Textos.t('Calcular mi ruta'),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor:
              AppColors.primary.withValues(
            alpha: 0.35,
          ),
          disabledForegroundColor:
              AppColors.textOnDark.withValues(
            alpha: 0.75,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusLg,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO DE CARGA
  // ============================================================

  Widget _construirCarga() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(
          AppDimensions.spacingSection,
        ),
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO DE ERROR
  // ============================================================

  Widget _construirError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            Text(
              _error ??
                  Textos.t('No fue posible cargar los sitios.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            OutlinedButton.icon(
              onPressed: _cargarSitios,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Tr(
                'Intentar nuevamente',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BotonRegresar(),
        title: const Tr(
          'Crear mi ruta',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: _cargando
            ? _construirCarga()
            : _error != null
                ? _construirError()
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding:
                              const EdgeInsets.fromLTRB(
                            AppDimensions.pageHorizontal,
                            AppDimensions.spacingMd,
                            AppDimensions.pageHorizontal,
                            AppDimensions.spacingXl,
                          ),
                          children: [
                            const Tr(
                              'Diseña tu recorrido',
                              style: TextStyle(
                                color:
                                    AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(
                              height: AppDimensions.spacingXs,
                            ),
                            const Tr(
                              'Elige los lugares que quieres visitar y calcularemos el recorrido por carretera.',
                              style: TextStyle(
                                color:
                                    AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(
                              height: AppDimensions.spacingLg,
                            ),
                            TextField(
                              controller:
                                  _nombreController,
                              textInputAction:
                                  TextInputAction.done,
                              decoration:
                                  InputDecoration(
                                labelText:
                                    Textos.t('Nombre de tu ruta'),
                                hintText:
                                    Textos.t('Ej. Mi día cafetero'),
                                prefixIcon:
                                    const Icon(
                                  Icons.edit_rounded,
                                ),
                                filled: true,
                                fillColor:
                                    AppColors.surface,
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    AppDimensions.radiusLg,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: AppDimensions.spacingLg,
                            ),
                            _construirResumen(),
                            const SizedBox(
                              height: AppDimensions.spacingLg,
                            ),
                            const Tr(
                              'Selecciona los lugares',
                              style: TextStyle(
                                color:
                                    AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(
                              height: AppDimensions.spacingMd,
                            ),
                            ..._sitios.map(
                              _construirSitioCard,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(
                          AppDimensions.pageHorizontal,
                          AppDimensions.spacingMd,
                          AppDimensions.pageHorizontal,
                          AppDimensions.spacingLg,
                        ),
                        decoration:
                            BoxDecoration(
                          color: AppColors.surface,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.black.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 12,
                              offset:
                                  const Offset(0, -4),
                            ),
                          ],
                        ),
                        child:
                            _construirBotonCalcular(),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// ============================================================================
// PANTALLA DE RESUMEN Y CONFIRMACIÓN
// ============================================================================

class RutaResumenUsuarioScreen extends StatelessWidget {
  const RutaResumenUsuarioScreen({
    super.key,
    required this.rutaController,
    required this.nombreRuta,
  });

  final MapaRutaController rutaController;
  final String nombreRuta;

  // ============================================================
  // FORMATO DE DISTANCIA
  // ============================================================

  String _formatearDistancia(double kilometros) {
    if (kilometros < 1) {
      final metros = kilometros * 1000;
      return Textos.t('{0} m', [metros.round()]);
    }

    return Textos.t('{0} km', [kilometros.toStringAsFixed(1)]);
  }

  // ============================================================
  // FORMATO DE DURACIÓN
  // ============================================================

  String _formatearDuracion(double minutos) {
    final totalMinutos = minutos.round();

    if (totalMinutos < 60) {
      return Textos.t('{0} min', [totalMinutos]);
    }

    final horas = totalMinutos ~/ 60;
    final minutosRestantes = totalMinutos % 60;

    if (minutosRestantes == 0) {
      return Textos.t('{0} h', [horas]);
    }

    return Textos.t('{0} h {1} min', [horas, minutosRestantes]);
  }

  // ============================================================
  // TARJETA DE INFORMACIÓN GENERAL
  // ============================================================

  Widget _construirDatoGeneral({
    required IconData icono,
    required String titulo,
    required String valor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(
          AppDimensions.spacingMd,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icono,
              color: AppColors.primary,
              size: 26,
            ),
            const SizedBox(
              height: AppDimensions.spacingXs,
            ),
            Text(
              valor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ORIGEN DE LA RUTA
  // ============================================================
  //
  // Tramo desde la ubicación real del usuario hasta el primer
  // sitio, o el motivo por el que la ruta empieza en el primer
  // sitio.
  // ============================================================

  Widget _construirOrigen() {
    final tramo = rutaController.tramoOrigen;
    final aviso = rutaController.avisoOrigen;

    if (tramo == null && aviso == null) {
      return const SizedBox.shrink();
    }

    final texto = tramo != null
        ? Textos.t('Tu ubicación actual · {0} · {1} hasta el primer sitio', [_formatearDistancia(tramo.distanciaKm), _formatearDuracion(tramo.duracionMinutos)])
        : aviso!;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            tramo != null
                ? Icons.my_location
                : Icons.location_off_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(
            width: AppDimensions.spacingSm,
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TARJETA DE SITIO
  // ============================================================

  Widget _construirSitio(
    BuildContext context,
    int indice,
    SitioTuristicoModel sitio,
  ) {
    final esUltimo =
        indice ==
            rutaController.rutaGuardadaSitios.length -
                1;

    return Column(
      children: [
        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${indice + 1}',
                style: const TextStyle(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(
              width: AppDimensions.spacingMd,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(
                  AppDimensions.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(
                    AppDimensions.radiusLg,
                  ),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      sitio.nombre,
                      style: const TextStyle(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (sitio.categoriaNombre
                        .isNotEmpty) ...[
                      const SizedBox(
                        height:
                            AppDimensions.spacingXs,
                      ),
                      Text(
                        sitio.categoriaNombre,
                        style: const TextStyle(
                          color:
                              AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (sitio.ciudad.isNotEmpty) ...[
                      const SizedBox(
                        height:
                            AppDimensions.spacingXs,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color:
                                AppColors.textSecondary,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Text(
                              sitio.ciudad,
                              style:
                                  const TextStyle(
                                color: AppColors
                                    .textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),

        // --------------------------------------------------------
        // TRAMO HACIA EL SIGUIENTE SITIO
        // --------------------------------------------------------

        if (!esUltimo)
          _construirTramo(
            indice,
          ),
      ],
    );
  }

  // ============================================================
  // TRAMO ENTRE SITIOS
  // ============================================================

  Widget _construirTramo(
    int indice,
  ) {
    final tramos =
        rutaController.tramosRuta;

    if (indice >= tramos.length) {
      return const SizedBox(
        height: AppDimensions.spacingLg,
      );
    }

    final tramo = tramos[indice];

    return Padding(
      padding: const EdgeInsets.only(
        left: 17,
      ),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 48,
            color: AppColors.border,
          ),
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.directions_car_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(
                  width: AppDimensions.spacingXs,
                ),
                Text(
                  _formatearDistancia(
                    tramo.distanciaKm,
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                const Icon(
                  Icons.schedule_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
                const SizedBox(
                  width: AppDimensions.spacingXs,
                ),
                Text(
                  _formatearDuracion(
                    tramo.duracionMinutos,
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final sitios =
        rutaController.rutaGuardadaSitios;

    final distanciaTotal =
        rutaController.distanciaTotalKm;

    final duracionTotal =
        rutaController.duracionTotalMinutos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BotonRegresar(),
        title: const Tr(
          'Resumen de tu ruta',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.fromLTRB(
                  AppDimensions.pageHorizontal,
                  AppDimensions.spacingMd,
                  AppDimensions.pageHorizontal,
                  AppDimensions.spacingXl,
                ),
                children: [
                  Text(
                    nombreRuta,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingXs,
                  ),
                  const Tr(
                    'Revisa tu recorrido antes de guardarlo.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(
                    height: AppDimensions.spacingLg,
                  ),

                  // ------------------------------------------------
                  // DATOS GENERALES
                  // ------------------------------------------------

                  Row(
                    children: [
                      _construirDatoGeneral(
                        icono:
                            Icons.route_rounded,
                        titulo:
                            Textos.t('Distancia total'),
                        valor:
                            _formatearDistancia(
                          distanciaTotal,
                        ),
                      ),
                      const SizedBox(
                        width:
                            AppDimensions.spacingSm,
                      ),
                      _construirDatoGeneral(
                        icono:
                            Icons.schedule_rounded,
                        titulo:
                            Textos.t('Tiempo estimado'),
                        valor:
                            _formatearDuracion(
                          duracionTotal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingSm,
                  ),

                  Container(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingMd,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppColors.getSoftColorForCategory(
                        'naturaleza',
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(
                          width:
                              AppDimensions.spacingSm,
                        ),
                        Expanded(
                          child: Tr(
                            '{0} sitios en tu recorrido', args: [sitios.length],
                            style:
                                const TextStyle(
                              color:
                                  AppColors.primary,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingXl,
                  ),

                  const Tr(
                    'Orden del recorrido',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingMd,
                  ),

                  // ------------------------------------------------
                  // ORIGEN (UBICACIÓN REAL DEL USUARIO)
                  // ------------------------------------------------
                  _construirOrigen(),

                  // ------------------------------------------------
                  // SITIOS Y TRAMOS
                  // ------------------------------------------------

                  ...List.generate(
                    sitios.length,
                    (indice) => _construirSitio(
                      context,
                      indice,
                      sitios[indice],
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingMd,
                  ),

                  Container(
                    padding: const EdgeInsets.all(
                      AppDimensions.spacingMd,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                        ),
                        SizedBox(
                          width:
                              AppDimensions.spacingSm,
                        ),
                        Expanded(
                          child: Tr(
                            'Al confirmar, esta ruta se guardará en tu cuenta durante 24 horas. También podrás eliminarla manualmente antes de que expire.',
                            style: TextStyle(
                              color:
                                  AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------------
            // BOTONES DE CONFIRMACIÓN
            // ------------------------------------------------------

            Container(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pageHorizontal,
                AppDimensions.spacingMd,
                AppDimensions.pageHorizontal,
                AppDimensions.spacingLg,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color:
                        AppColors.black.withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          true,
                        );
                      },
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                      ),
                      label: const Tr(
                        'Confirmar y guardar ruta',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.primary,
                        foregroundColor:
                            AppColors.textOnDark,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical:
                              AppDimensions.spacingMd,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppDimensions.radiusLg,
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
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          false,
                        );
                      },
                      icon: const Icon(
                        Icons.edit_location_alt_outlined,
                      ),
                      label: const Tr(
                        'Cambiar selección',
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            AppColors.primary,
                        side: const BorderSide(
                          color:
                              AppColors.primary,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          vertical:
                              AppDimensions.spacingMd,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
