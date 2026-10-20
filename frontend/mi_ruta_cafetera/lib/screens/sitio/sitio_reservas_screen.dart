import 'package:flutter/material.dart';

import '../../models/sitio/sitio_notificacion_model.dart';
import '../../models/sitio/sitio_reserva_model.dart';
import '../../services/sitio/sitio_reservas_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/estado_reservas_sitio.dart';
import '../../widgets/sitio/tarjeta_resumen_reservas_sitio.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

class SitioReservasScreen extends StatefulWidget {
  const SitioReservasScreen({super.key});

  @override
  State<SitioReservasScreen> createState() =>
      _SitioReservasScreenState();
}

class _SitioReservasScreenState extends State<SitioReservasScreen> {
  final SitioReservasService _servicio =
      SitioReservasService.instance;

  List<SitioReservaModel> _reservas = [];
  List<SitioNotificacionModel> _avisos = [];
  bool _cargando = true;
  String? _error;
  String _filtroEstado = 'todas';
  DateTime? _fechaSeleccionada;
  String _busqueda = '';
  final TextEditingController _busquedaController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarReservas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final reservas = await _servicio.obtenerReservas();
      final avisos = await _cargarAvisos();

      if (!mounted) return;

      setState(() {
        _reservas = reservas;
        _avisos = avisos;
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

  // Los avisos son un complemento: si fallan, la lista de reservas
  // se muestra igual.
  Future<List<SitioNotificacionModel>> _cargarAvisos() async {
    try {
      return await _servicio.obtenerNotificaciones();
    } catch (_) {
      return <SitioNotificacionModel>[];
    }
  }

  int get _avisosSinLeer => _avisos.where((a) => !a.leida).length;

  Future<void> _marcarAvisosVistos() async {
    final pendientes = _avisos.where((a) => !a.leida).toList();

    try {
      for (final aviso in pendientes) {
        await _servicio.marcarNotificacionLeida(aviso.id);
      }

      final avisos = await _cargarAvisos();

      if (!mounted) return;

      setState(() => _avisos = avisos);
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    }
  }

  List<SitioReservaModel> get _reservasFiltradas {
    final busqueda = _busqueda.trim().toLowerCase();

    return _reservas.where((reserva) {
      if (_filtroEstado != 'todas' &&
          reserva.estado.toLowerCase() != _filtroEstado) {
        return false;
      }

      if (_fechaSeleccionada != null) {
        final fecha = reserva.fecha;

        if (fecha == null ||
            fecha.year != _fechaSeleccionada!.year ||
            fecha.month != _fechaSeleccionada!.month ||
            fecha.day != _fechaSeleccionada!.day) {
          return false;
        }
      }

      if (busqueda.isNotEmpty) {
        final texto = [
          reserva.nombreUsuario,
          reserva.apellidoUsuario,
          reserva.correoUsuario,
          reserva.nombreActividad,
          reserva.estado,
        ].join(' ').toLowerCase();

        if (!texto.contains(busqueda)) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        final fechaA = a.fecha ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final fechaB = b.fecha ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return fechaA.compareTo(fechaB);
      });
  }

  int get _pendientes => _reservas
      .where((r) => r.estado.toLowerCase() == 'pendiente')
      .length;

  int get _confirmadas => _reservas
      .where((r) => r.estado.toLowerCase() == 'confirmada')
      .length;

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecciona la fecha de reserva',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.sitioPrimary,
              onPrimary: Colors.white,
              surface: AppColors.sitioSurface,
              onSurface: AppColors.sitioTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted || fecha == null) return;

    setState(() {
      _fechaSeleccionada = fecha;
    });
  }

  Future<void> _cambiarEstado(
    SitioReservaModel reserva,
    String estado,
  ) async {
    final motivo = await _pedirConfirmacion(estado);

    if (motivo == null || !mounted) return;

    try {
      await _servicio.actualizarEstado(
        reservaId: reserva.id,
        estado: estado,
        motivo: motivo,
      );

      if (!mounted) return;

      _mostrarMensaje('Reserva actualizada correctamente.');
      await _cargarReservas();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    }
  }

  // Devuelve null si la persona cancela; si acepta, devuelve el
  // mensaje escrito ('' si no escribió ninguno).
  //  - rechazada: el motivo es obligatorio (mínimo 3 caracteres).
  //  - confirmada: mensaje opcional para el visitante.
  Future<String?> _pedirConfirmacion(String estado) async {
    final controlador = TextEditingController();
    final pideTexto = estado == 'rechazada' || estado == 'confirmada';
    final obligatorio = estado == 'rechazada';
    String? errorTexto;

    final resultado = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              backgroundColor: AppColors.sitioSurface,
              title: const Text('Actualizar reserva'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Deseas cambiar el estado de esta reserva a '
                    '${_nombreEstado(estado)}?',
                  ),
                  if (pideTexto) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: controlador,
                      maxLength: 300,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: obligatorio
                            ? 'Motivo (obligatorio)'
                            : 'Mensaje para el visitante (opcional)',
                        helperText: obligatorio
                            ? null
                            : 'Por ejemplo, cómo te comunicarás para '
                                'coordinar el pago.',
                        errorText: errorTexto,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Volver'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sitioPrimary,
                  ),
                  onPressed: () {
                    final texto = controlador.text.trim();

                    if (obligatorio && texto.length < 3) {
                      setLocal(() {
                        errorTexto = 'Escribe el motivo (mínimo 3 letras).';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, texto);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    return resultado;
  }

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError
            ? AppColors.sitioError
            : AppColors.sitioPrimary,
      ),
    );
  }

  String _nombreEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmada':
        return 'Confirmada';
      case 'rechazada':
        return 'Rechazada';
      case 'cancelada':
        return 'Cancelada';
      case 'completada':
        return 'Completada';
      default:
        return estado;
    }
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Fecha no disponible';

    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');

    return '$dia/$mes/${local.year}';
  }

  String _formatearPrecio(double precio) {
    return '\$${precio.toStringAsFixed(0)}';
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
      case 'completada':
        return AppColors.sitioSuccess;
      case 'cancelada':
      case 'rechazada':
        return AppColors.sitioError;
      default:
        return AppColors.sitioWarning;
    }
  }

  Color _fondoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
      case 'completada':
        return AppColors.sitioSuccessSoft;
      case 'cancelada':
      case 'rechazada':
        return AppColors.sitioErrorSoft;
      default:
        return AppColors.sitioWarningSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esEscritorio = ancho >= 900;

    return Container(
      color: AppColors.sitioBackground,
      child: RefreshIndicator(
        color: AppColors.sitioPrimary,
        onRefresh: _cargarReservas,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: esEscritorio
                ? AppDimensions.sitioPagePadding
                : AppDimensions.sitioPagePaddingCompact,
            vertical: AppDimensions.sitioSectionGapCompact,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _encabezado(context),
                  const SizedBox(
                    height: AppDimensions.sitioSectionGap,
                  ),
                  _resumenReservas(esEscritorio),
                  const SizedBox(
                    height: AppDimensions.sitioSectionGap,
                  ),
                  _seccionReservas(esEscritorio),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.sitioPrimaryDark,
            AppColors.sitioPrimary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.sitioHeaderIconSize,
            height: AppDimensions.sitioHeaderIconSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.sitioTextOnPrimary,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservas',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        color: AppColors.sitioTextOnPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Consulta y gestiona las reservas de tus visitantes.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Actualizar reservas',
            onPressed: _cargando ? null : _cargarReservas,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumenReservas(bool esEscritorio) {
    final tarjetas = [
      TarjetaResumenReservasSitio(
        icono: Icons.calendar_month_rounded,
        titulo: 'Reservas',
        valor: '${_reservas.length}',
        descripcion: 'Reservas recibidas',
      ),
      TarjetaResumenReservasSitio(
        icono: Icons.pending_actions_rounded,
        titulo: 'Pendientes',
        valor: '$_pendientes',
        descripcion: 'Por revisar',
      ),
      TarjetaResumenReservasSitio(
        icono: Icons.check_circle_rounded,
        titulo: 'Confirmadas',
        valor: '$_confirmadas',
        descripcion: 'Reservas confirmadas',
      ),
    ];

    if (esEscritorio) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: tarjetas[0]),
          const SizedBox(
            width: AppDimensions.sitioPanelCardGap,
          ),
          Expanded(child: tarjetas[1]),
          const SizedBox(
            width: AppDimensions.sitioPanelCardGap,
          ),
          Expanded(child: tarjetas[2]),
        ],
      );
    }

    return Column(
      children: [
        tarjetas[0],
        const SizedBox(height: AppDimensions.sitioPanelCardGap),
        tarjetas[1],
        const SizedBox(height: AppDimensions.sitioPanelCardGap),
        tarjetas[2],
      ],
    );
  }

  Widget _seccionReservas(bool esEscritorio) {
    return TarjetaSeccionSitio(
      titulo: 'Reservas recibidas',
      subtitulo:
          'Consulta las solicitudes y revisa los datos de cada visitante.',
      icono: Icons.event_available_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_avisosSinLeer > 0) ...[
            _bannerAvisos(),
            const SizedBox(
              height: AppDimensions.sitioSectionGapCompact,
            ),
          ],
          _controles(esEscritorio),
          const SizedBox(
            height: AppDimensions.sitioSectionGapCompact,
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.sitioPrimary,
                ),
              ),
            )
          else if (_error != null)
            _estadoError()
          else if (_reservasFiltradas.isEmpty)
            _reservas.isEmpty
                ? const EstadoReservasSitio()
                : _sinResultados()
          else
            _listaReservas(esEscritorio),
        ],
      ),
    );
  }

  Widget _bannerAvisos() {
    final n = _avisosSinLeer;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sitioWarningSoft,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioWarning.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_rounded,
            color: AppColors.sitioWarning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              n == 1
                  ? 'Tienes 1 aviso nuevo de reservas.'
                  : 'Tienes $n avisos nuevos de reservas.',
              style: const TextStyle(
                color: AppColors.sitioTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: _marcarAvisosVistos,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.sitioPrimary,
            ),
            child: const Text('Marcar vistos'),
          ),
        ],
      ),
    );
  }

  Widget _controles(bool esEscritorio) {
    final busqueda = TextField(
      controller: _busquedaController,
      onChanged: (valor) => setState(() => _busqueda = valor),
      decoration: InputDecoration(
        hintText: 'Buscar visitante o actividad',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppColors.sitioSurfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioBorder,
          ),
        ),
      ),
    );

    final estado = DropdownButtonFormField<String>(
      initialValue: _filtroEstado,
      decoration: InputDecoration(
        labelText: 'Estado',
        filled: true,
        fillColor: AppColors.sitioSurfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.sitioBorder,
          ),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'todas', child: Text('Todas')),
        DropdownMenuItem(
          value: 'pendiente',
          child: Text('Pendientes'),
        ),
        DropdownMenuItem(
          value: 'confirmada',
          child: Text('Confirmadas'),
        ),
        DropdownMenuItem(
          value: 'rechazada',
          child: Text('Rechazadas'),
        ),
        DropdownMenuItem(
          value: 'cancelada',
          child: Text('Canceladas'),
        ),
        DropdownMenuItem(
          value: 'completada',
          child: Text('Completadas'),
        ),
      ],
      onChanged: (valor) {
        if (valor != null) {
          setState(() => _filtroEstado = valor);
        }
      },
    );

    final fecha = OutlinedButton.icon(
      onPressed: _seleccionarFecha,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.sitioPrimary,
        backgroundColor: AppColors.sitioSurfaceGreen,
        side: const BorderSide(color: AppColors.sitioBorder),
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioFormRadius,
          ),
        ),
      ),
      icon: const Icon(Icons.calendar_today_rounded),
      label: Text(
        _fechaSeleccionada == null
            ? 'Seleccionar fecha'
            : _formatearFecha(_fechaSeleccionada),
      ),
    );

    final limpiar = TextButton.icon(
      onPressed: _fechaSeleccionada == null &&
              _filtroEstado == 'todas' &&
              _busqueda.isEmpty
          ? null
          : () {
              setState(() {
                _fechaSeleccionada = null;
                _filtroEstado = 'todas';
                _busqueda = '';
                _busquedaController.clear();
              });
            },
      icon: const Icon(Icons.restart_alt_rounded),
      label: const Text('Limpiar'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.sitioPrimary,
      ),
    );

    if (esEscritorio) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(flex: 3, child: busqueda),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: estado),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              fecha,
              const Spacer(),
              limpiar,
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        busqueda,
        const SizedBox(height: 12),
        estado,
        const SizedBox(height: 12),
        fecha,
        Align(
          alignment: Alignment.centerRight,
          child: limpiar,
        ),
      ],
    );
  }

  Widget _listaReservas(bool esEscritorio) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_reservasFiltradas.length} '
              '${_reservasFiltradas.length == 1 ? 'reserva encontrada' : 'reservas encontradas'}',
              style: const TextStyle(
                color: AppColors.sitioTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        ..._reservasFiltradas.map(
          (reserva) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _tarjetaReserva(reserva, esEscritorio),
          ),
        ),
      ],
    );
  }

  Widget _tarjetaReserva(
    SitioReservaModel reserva,
    bool esEscritorio,
  ) {
    final color = _colorEstado(reserva.estado);
    final fondo = _fondoEstado(reserva.estado);
    final nombre = [
      reserva.nombreUsuario,
      reserva.apellidoUsuario,
    ].where((parte) => parte.trim().isNotEmpty).join(' ');

    return Container(
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
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: AppColors.sitioPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reserva.nombreActividad.isEmpty
                          ? 'Actividad reservada'
                          : reserva.nombreActividad,
                      style: const TextStyle(
                        color: AppColors.sitioTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      nombre.isEmpty ? 'Visitante' : nombre,
                      style: const TextStyle(
                        color: AppColors.sitioTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: fondo,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.sitioStatusRadius,
                  ),
                ),
                child: Text(
                  _nombreEstado(reserva.estado),
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.sitioDivider),
          const SizedBox(height: 10),
          _dato(
            Icons.calendar_month_outlined,
            'Fecha',
            _formatearFecha(reserva.fecha),
          ),
          const SizedBox(height: 10),
          _dato(
            Icons.groups_outlined,
            'Personas',
            '${reserva.cantidadPersonas}',
          ),
          const SizedBox(height: 10),
          _dato(
            Icons.email_outlined,
            'Correo',
            reserva.correoUsuario.isEmpty
                ? 'No disponible'
                : reserva.correoUsuario,
          ),
          if (reserva.telefonoUsuario.isNotEmpty) ...[
            const SizedBox(height: 10),
            _dato(
              Icons.phone_outlined,
              'Teléfono',
              reserva.telefonoUsuario,
            ),
          ],
          const SizedBox(height: 10),
          _dato(
            Icons.payments_outlined,
            'Precio',
            _formatearPrecio(
              reserva.precioTotal > 0
                  ? reserva.precioTotal
                  : reserva.precioActividad,
            ),
          ),
          if (reserva.observaciones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sitioSurfaceSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Observaciones: ${reserva.observaciones}',
                style: const TextStyle(
                  color: AppColors.sitioTextSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (reserva.respuestaSitio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sitioSurfaceGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tu respuesta: ${reserva.respuestaSitio}',
                style: const TextStyle(
                  color: AppColors.sitioTextPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (reserva.estado.toLowerCase() == 'pendiente' ||
              reserva.estado.toLowerCase() == 'confirmada') ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                if (reserva.estado.toLowerCase() == 'pendiente')
                  OutlinedButton.icon(
                    onPressed: () =>
                        _cambiarEstado(reserva, 'rechazada'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.sitioError,
                      side: const BorderSide(
                        color: AppColors.sitioError,
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Rechazar'),
                  ),
                if (reserva.estado.toLowerCase() == 'confirmada')
                  OutlinedButton.icon(
                    onPressed: () =>
                        _cambiarEstado(reserva, 'cancelada'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.sitioError,
                      side: const BorderSide(
                        color: AppColors.sitioError,
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancelar'),
                  ),
                if (reserva.estado.toLowerCase() == 'pendiente')
                  FilledButton.icon(
                    onPressed: () =>
                        _cambiarEstado(reserva, 'confirmada'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.sitioPrimary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Confirmar'),
                  ),
                if (reserva.estado.toLowerCase() == 'confirmada')
                  FilledButton.icon(
                    onPressed: () =>
                        _cambiarEstado(reserva, 'completada'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.sitioPrimary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.task_alt_rounded),
                    label: const Text('Marcar completada'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _dato(IconData icono, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icono,
          size: 19,
          color: AppColors.sitioPrimary,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 76,
          child: Text(
            titulo,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            valor,
            style: const TextStyle(
              color: AppColors.sitioTextPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _estadoError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sitioErrorSoft,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioError.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: AppColors.sitioError,
          ),
          const SizedBox(height: 12),
          const Text(
            'No pudimos cargar las reservas',
            style: TextStyle(
              color: AppColors.sitioTextPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Ocurrió un error inesperado.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _cargarReservas,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sitioPrimary,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Intentar nuevamente'),
          ),
        ],
      ),
    );
  }

  Widget _sinResultados() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(color: AppColors.sitioBorder),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 42,
            color: AppColors.sitioTextSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'No encontramos reservas con estos filtros',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.sitioTextPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Prueba cambiando el estado, la fecha o la búsqueda.',
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
}
