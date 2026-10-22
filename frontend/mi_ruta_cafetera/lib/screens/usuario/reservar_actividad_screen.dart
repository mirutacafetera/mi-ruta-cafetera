import 'package:flutter/material.dart';

import '../../models/sitio/sitio_actividad_model.dart';
import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/usuario/reserva_usuario_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

// ============================================================
// SOLICITAR RESERVA DE UNA ACTIVIDAD
// ============================================================
//
// La persona envía una SOLICITUD: el establecimiento la confirma o
// la rechaza y se pone en contacto para coordinar el pago. No hay
// pagos electrónicos en esta versión.
// ============================================================

class ReservarActividadScreen extends StatefulWidget {
  const ReservarActividadScreen({
    super.key,
    required this.actividad,
    this.nombreSitio = '',
  });

  final SitioActividadModel actividad;
  final String nombreSitio;

  @override
  State<ReservarActividadScreen> createState() =>
      _ReservarActividadScreenState();
}

class _ReservarActividadScreenState
    extends State<ReservarActividadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cantidad =
      TextEditingController(text: '1');
  final TextEditingController _observaciones = TextEditingController();

  // Una sola clave por pantalla: reintentar no duplica la solicitud.
  final String _clave = ReservaUsuarioService.nuevaClaveSolicitud();

  DateTime? _fecha;
  bool _enviando = false;

  @override
  void dispose() {
    _cantidad.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  int get _personas => int.tryParse(_cantidad.text.trim()) ?? 0;

  double get _total => widget.actividad.precio * _personas;

  String _dinero(double valor) => '\$${valor.toStringAsFixed(0)}';

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();

    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy.add(const Duration(days: 1)),
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365)),
      helpText: Textos.t('Fecha de la actividad'),
      cancelText: Textos.t('Cancelar'),
      confirmText: Textos.t('Aceptar'),
    );

    if (elegida != null && mounted) {
      setState(() => _fecha = elegida);
    }
  }

  String? _validarCantidad(String? valor) {
    final n = int.tryParse((valor ?? '').trim());

    if (n == null || n < 1) {
      return Textos.t('Escribe al menos 1 persona');
    }

    if (n > 50) {
      return Textos.t('Máximo 50 personas por solicitud');
    }

    return null;
  }

  Future<void> _enviar() async {
    if (_enviando) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_fecha == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Tr('Elige la fecha de la actividad.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _enviando = true);

    try {
      final mensaje = await ReservaUsuarioService.instance.crearSolicitud(
        actividadId: widget.actividad.id,
        fecha: _fecha!,
        cantidadPersonas: _personas,
        observaciones: _observaciones.text,
        claveSolicitud: _clave,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje)),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _enviando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UsuarioSesionModel? sesion =
        UsuarioSesionService.instance.sesionActual.value;

    final actividad = widget.actividad;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Tr('Solicitar reserva')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius,
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actividad.nombre,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.nombreSitio.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          widget.nombreSitio,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      if (actividad.precio > 0) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        Tr(
                          '{0} por persona', args: [_dinero(actividad.precio)],
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                OutlinedButton.icon(
                  onPressed: _enviando ? null : _elegirFecha,
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(
                    _fecha == null
                        ? Textos.t('Elegir fecha')
                        : Textos.t('Fecha: {0}', [_formatearFecha(_fecha!)]),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                TextFormField(
                  controller: _cantidad,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: Textos.t('Número de personas'),
                    prefixIcon: const Icon(Icons.groups_rounded),
                  ),
                  validator: _validarCantidad,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                TextFormField(
                  controller: _observaciones,
                  maxLength: 500,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: Textos.t('Observaciones (opcional)'),
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes_rounded),
                  ),
                ),
                if (actividad.precio > 0 && _personas > 0) ...[
                  const SizedBox(height: AppDimensions.spacingSm),
                  Tr(
                    'Total estimado: {0}', args: [_dinero(_total)],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingLg),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLg,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Tr(
                        'El establecimiento revisará tu solicitud y te responderá. Si la confirma, se pondrá en contacto contigo para coordinar el pago.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (sesion != null) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        Tr(
                          'Te contactarán a: {0}{1}', args: [sesion.correo, sesion.telefono.isEmpty ? '' : ' · ${sesion.telefono}'],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (sesion.telefono.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(
                              top: AppDimensions.spacingXs,
                            ),
                            child: Tr(
                              'Agrega tu teléfono en Editar perfil para que puedan llamarte.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.sectionGap),
                SizedBox(
                  height: AppDimensions.buttonHeightLarge,
                  child: ElevatedButton.icon(
                    onPressed: _enviando ? null : _enviar,
                    icon: _enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _enviando ? Textos.t('Enviando…') : Textos.t('Enviar solicitud'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
