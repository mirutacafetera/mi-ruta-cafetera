import 'package:flutter/material.dart';

import '../../models/usuario/reserva_usuario_model.dart';
import '../../services/usuario/reserva_usuario_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

// ============================================================
// MIS RESERVAS
// ============================================================
//
// Lista las solicitudes del usuario con su estado, muestra el
// detalle (incluida la respuesta del establecimiento) y permite
// cancelar mientras esté pendiente o confirmada.
// ============================================================

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  final ReservaUsuarioService _servicio = ReservaUsuarioService.instance;

  List<ReservaUsuarioModel> _reservas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final lista = await _servicio.obtenerReservas();

      if (!mounted) return;

      setState(() {
        _reservas = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  String _fecha(DateTime? fecha) {
    if (fecha == null) return Textos.t('Fecha no disponible');

    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');

    return '$dia/$mes/${local.year}';
  }

  String _dinero(double valor) => '\$${valor.toStringAsFixed(0)}';

  Color _color(String estado) {
    switch (estado) {
      case 'confirmada':
      case 'completada':
        return AppColors.success;
      case 'rechazada':
      case 'cancelada':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _cancelar(ReservaUsuarioModel reserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Tr('Cancelar reserva'),
          content: const Tr(
            '¿Deseas cancelar esta solicitud? El establecimiento será avisado.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Tr('Volver'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Tr('Cancelar reserva'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    try {
      await _servicio.cancelar(reserva.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Tr('Reserva cancelada.')),
      );

      await _cargar();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  void _verDetalle(ReservaUsuarioModel reserva) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.pageHorizontal,
              0,
              AppDimensions.pageHorizontal,
              AppDimensions.spacingXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reserva.nombreActividad.isEmpty
                      ? Textos.t('Actividad')
                      : reserva.nombreActividad,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  reserva.nombreSitio.isEmpty
                      ? Textos.t('Establecimiento')
                      : reserva.nombreSitio,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                _fila(Textos.t('Estado'), reserva.estadoLegible,
                    color: _color(reserva.estado)),
                _fila(Textos.t('Fecha'), _fecha(reserva.fecha)),
                _fila(Textos.t('Personas'), '${reserva.cantidadPersonas}'),
                _fila(Textos.t('Total estimado'), _dinero(reserva.precioTotal)),
                _fila(Textos.t('Solicitada'), _fecha(reserva.creadaEn)),
                if (reserva.observaciones.isNotEmpty)
                  _fila(Textos.t('Tus observaciones'), reserva.observaciones),
                if (reserva.respuestaSitio.isNotEmpty)
                  _fila(Textos.t('Respuesta del establecimiento'),
                      reserva.respuestaSitio),
                if (reserva.esConfirmada)
                  const Padding(
                    padding: EdgeInsets.only(top: AppDimensions.spacingSm),
                    child: Tr(
                      'El establecimiento se pondrá en contacto contigo para coordinar el pago.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                if (reserva.sePuedeCancelar) ...[
                  const SizedBox(height: AppDimensions.spacingLg),
                  SizedBox(
                    height: AppDimensions.buttonHeight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _cancelar(reserva);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      icon: const Icon(Icons.close_rounded),
                      label: const Tr('Cancelar reserva'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _fila(String titulo, String valor, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            valor,
            style: TextStyle(
              color: color ?? AppColors.textPrimary,
              fontWeight: color == null ? FontWeight.w500 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(ReservaUsuarioModel reserva) {
    final color = _color(reserva.estado);

    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: () => _verDetalle(reserva),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reserva.nombreActividad.isEmpty
                          ? Textos.t('Actividad')
                          : reserva.nombreActividad,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      '${reserva.nombreSitio.isEmpty ? 'Establecimiento' : reserva.nombreSitio}'
                      ' · ${_fecha(reserva.fecha)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      '${reserva.cantidadPersonas} '
                      '${reserva.cantidadPersonas == 1 ? 'persona' : 'personas'}'
                      ' · ${_dinero(reserva.precioTotal)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingXs + 2,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusPill,
                  ),
                ),
                child: Text(
                  reserva.estadoLegible,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
        children: [
          const SizedBox(height: AppDimensions.sectionGap),
          const Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Center(
            child: OutlinedButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Tr('Intentar de nuevo'),
            ),
          ),
        ],
      );
    }

    if (_reservas.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
        children: const [
          SizedBox(height: AppDimensions.sectionGap),
          Icon(
            Icons.event_available_rounded,
            size: 42,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppDimensions.spacingMd),
          Tr(
            'Aún no tienes reservas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: AppDimensions.spacingXs),
          Tr(
            'Entra al detalle de un sitio, elige una actividad y solicita tu reserva.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
      itemCount: _reservas.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacingMd),
      itemBuilder: (_, i) => _tarjeta(_reservas[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Tr('Mis reservas')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargar,
          child: _cuerpo(),
        ),
      ),
    );
  }
}
