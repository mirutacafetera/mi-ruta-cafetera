import 'package:flutter/material.dart';

import '../../services/sitio/sitio_ayuda_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/avisos_sitio.dart';
import '../../widgets/sitio/tarjeta_resumen_sitio.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

class SitioReportesScreen extends StatefulWidget {
  const SitioReportesScreen({super.key});

  @override
  State<SitioReportesScreen> createState() => _SitioReportesScreenState();
}

class _TipoReporte {
  const _TipoReporte(this.valor, this.nombre, this.icono);

  final String valor;
  final String nombre;
  final IconData icono;
}

class _SitioReportesScreenState extends State<SitioReportesScreen> {
  static const List<_TipoReporte> _tipos = [
    _TipoReporte(
      'problema',
      'Reportar un problema',
      Icons.report_problem_outlined,
    ),
    _TipoReporte(
      'sugerencia',
      'Enviar una sugerencia',
      Icons.lightbulb_outline_rounded,
    ),
    _TipoReporte(
      'mejora',
      'Proponer una mejora',
      Icons.trending_up_rounded,
    ),
    _TipoReporte(
      'otro',
      'Otro',
      Icons.more_horiz_rounded,
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _asuntoController = TextEditingController();
  final _mensajeController = TextEditingController();
  final _service = SitioAyudaService();

  String _tipoReporte = 'problema';
  bool _enviando = false;
  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _reportes = [];

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  @override
  void dispose() {
    _asuntoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATOS
  // ============================================================

  Future<void> _cargarReportes() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final reportes = await _service.obtenerMisReportes();

      if (!mounted) return;

      setState(() {
        _reportes = reportes;
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

  Future<void> _enviarReporte() async {
    FocusScope.of(context).unfocus();

    if (_enviando) return;

    if (!_formKey.currentState!.validate()) {
      AvisosSitio.error(
        context,
        'Completa los campos marcados en rojo para continuar.',
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      await _service.crearReporte(
        tipoReporte: _tipoReporte,
        asunto: _asuntoController.text,
        mensaje: _mensajeController.text,
      );

      if (!mounted) return;

      _asuntoController.clear();
      _mensajeController.clear();

      AvisosSitio.exito(context, 'Tu reporte fue enviado correctamente.');

      await _cargarReportes();
    } catch (e) {
      if (!mounted) return;

      AvisosSitio.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  // ============================================================
  // AYUDAS
  // ============================================================

  int get _enProceso => _reportes
      .where((r) => (r['estado']?.toString() ?? 'pendiente') != 'resuelto')
      .length;

  int get _resueltos =>
      _reportes.where((r) => r['estado']?.toString() == 'resuelto').length;

  _TipoReporte? _buscarTipo(String valor) {
    for (final tipo in _tipos) {
      if (tipo.valor == valor) return tipo;
    }

    return null;
  }

  String _nombreTipo(String tipo) => _buscarTipo(tipo)?.nombre ?? tipo;

  IconData _iconoTipo(String tipo) =>
      _buscarTipo(tipo)?.icono ?? Icons.chat_bubble_outline_rounded;

  String _nombreEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_revision':
        return 'En revisión';
      case 'resuelto':
        return 'Resuelto';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
    }
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'resuelto':
        return AppColors.sitioSuccess;
      case 'en_revision':
        return AppColors.sitioInfo;
      default:
        return AppColors.sitioWarning;
    }
  }

  IconData _iconoEstado(String estado) {
    switch (estado) {
      case 'resuelto':
        return Icons.check_circle_outline_rounded;
      case 'en_revision':
        return Icons.visibility_outlined;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _fecha(dynamic valor) {
    if (valor == null) return 'Fecha no disponible';

    final fecha = DateTime.tryParse(valor.toString())?.toLocal();
    if (fecha == null) return 'Fecha no disponible';

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year} · $hora:$minuto';
  }

  // ============================================================
  // ENCABEZADO Y RESUMEN
  // ============================================================

  Widget _encabezado(bool esDesktop) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.sitioPanelCardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.sitioPrimary,
            AppColors.sitioPrimaryDark,
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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.sitioHeaderIconSize,
            height: AppDimensions.sitioHeaderIconSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: AppColors.sitioAccent,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SOPORTE Y MEJORAS',
                  style: TextStyle(
                    color: Color(0xFFE6EDE7),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu opinión importa',
                  style: TextStyle(
                    color: AppColors.sitioTextOnPrimary,
                    fontSize: esDesktop ? 26 : 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Envíanos tus comentarios y consulta aquí el seguimiento '
                  'de cada solicitud.',
                  style: TextStyle(
                    color: Color(0xFFE6EDE7),
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumen(double ancho) {
    final tarjetas = [
      TarjetaResumenSitio(
        titulo: 'Total',
        valor: _reportes.length.toString(),
        descripcion: 'Solicitudes enviadas',
        icono: Icons.forum_outlined,
      ),
      TarjetaResumenSitio(
        titulo: 'En proceso',
        valor: _enProceso.toString(),
        descripcion: 'Pendientes o en revisión',
        icono: Icons.hourglass_empty_rounded,
      ),
      TarjetaResumenSitio(
        titulo: 'Resueltas',
        valor: _resueltos.toString(),
        descripcion: 'Con respuesta de la administración',
        icono: Icons.check_circle_outline_rounded,
      ),
    ];

    if (ancho >= 600) {
      return Row(
        children: [
          Expanded(child: tarjetas[0]),
          const SizedBox(width: AppDimensions.sitioPanelCardGap),
          Expanded(child: tarjetas[1]),
          const SizedBox(width: AppDimensions.sitioPanelCardGap),
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

  // ============================================================
  // FORMULARIO
  // ============================================================

  Widget _construirFormulario() {
    return TarjetaSeccionSitio(
      titulo: 'Cuéntanos cómo podemos ayudarte',
      subtitulo:
          'Tu comentario nos ayuda a mejorar la experiencia de los sitios turísticos.',
      icono: Icons.edit_note_rounded,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de solicitud',
              style: TextStyle(
                color: AppColors.sitioTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              children: _tipos.map(_chipTipo).toList(),
            ),
            const SizedBox(height: AppDimensions.sitioFormSectionGap),
            TextFormField(
              controller: _asuntoController,
              enabled: !_enviando,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              decoration: _decoracion(
                'Asunto',
                Icons.short_text_rounded,
                hint: 'Ej. Problema al actualizar información',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe el asunto de tu solicitud.';
                }
                if (value.trim().length > 120) {
                  return 'Máximo 120 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.sitioFormFieldGap),
            TextFormField(
              controller: _mensajeController,
              enabled: !_enviando,
              minLines: 4,
              maxLines: 7,
              maxLength: 3000,
              textCapitalization: TextCapitalization.sentences,
              decoration: _decoracion(
                'Descripción',
                Icons.chat_bubble_outline_rounded,
                hint: 'Describe con detalle tu reporte o propuesta...',
                alignLabel: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Escribe una descripción.';
                }
                if (value.trim().length > 3000) {
                  return 'Máximo 3000 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.sitioButtonHeight,
              child: FilledButton.icon(
                onPressed: _enviando ? null : _enviarReporte,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sitioPrimary,
                  foregroundColor: AppColors.sitioTextOnPrimary,
                  disabledBackgroundColor:
                      AppColors.sitioPrimary.withValues(alpha: 0.45),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.sitioFormRadius,
                    ),
                  ),
                ),
                icon: _enviando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(_enviando ? 'Enviando...' : 'Enviar solicitud'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipTipo(_TipoReporte tipo) {
    final seleccionado = _tipoReporte == tipo.valor;

    return ChoiceChip(
      avatar: Icon(
        tipo.icono,
        size: 18,
        color: seleccionado
            ? AppColors.sitioTextOnPrimary
            : AppColors.sitioPrimary,
      ),
      label: Text(tipo.nombre),
      selected: seleccionado,
      showCheckmark: false,
      selectedColor: AppColors.sitioPrimary,
      backgroundColor: AppColors.sitioSurfaceSoft,
      side: BorderSide(
        color: seleccionado ? AppColors.sitioPrimary : AppColors.sitioBorder,
      ),
      labelStyle: TextStyle(
        color: seleccionado
            ? AppColors.sitioTextOnPrimary
            : AppColors.sitioTextPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.sitioStatusRadius),
      ),
      onSelected: _enviando
          ? null
          : (_) => setState(() => _tipoReporte = tipo.valor),
    );
  }

  InputDecoration _decoracion(
    String etiqueta,
    IconData icono, {
    String? hint,
    bool alignLabel = false,
  }) {
    OutlineInputBorder borde(Color color, [double ancho = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.sitioFormRadius),
        borderSide: BorderSide(color: color, width: ancho),
      );
    }

    return InputDecoration(
      labelText: etiqueta,
      hintText: hint,
      alignLabelWithHint: alignLabel,
      prefixIcon: Icon(icono, color: AppColors.sitioPrimary),
      filled: true,
      fillColor: AppColors.sitioSurfaceSoft,
      labelStyle: const TextStyle(
        color: AppColors.sitioTextSecondary,
        fontSize: 13,
      ),
      hintStyle: const TextStyle(
        color: AppColors.sitioTextSecondary,
        fontSize: 12,
      ),
      counterStyle: const TextStyle(
        color: AppColors.sitioTextSecondary,
        fontSize: 11,
      ),
      border: borde(AppColors.sitioBorder),
      enabledBorder: borde(AppColors.sitioBorder),
      disabledBorder: borde(AppColors.sitioDivider),
      focusedBorder: borde(AppColors.sitioPrimary, 1.5),
      errorBorder: borde(AppColors.sitioError),
      focusedErrorBorder: borde(AppColors.sitioError, 1.5),
    );
  }

  // ============================================================
  // HISTORIAL
  // ============================================================

  Widget _construirHistorial() {
    return TarjetaSeccionSitio(
      titulo: 'Mis solicitudes',
      subtitulo: 'Consulta su estado y las respuestas de la administración.',
      icono: Icons.history_rounded,
      child: _contenidoHistorial(),
    );
  }

  Widget _contenidoHistorial() {
    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXxl),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.sitioPrimary),
        ),
      );
    }

    if (_error != null) {
      return _panelMensaje(
        icono: Icons.cloud_off_rounded,
        titulo: 'No pudimos cargar tus solicitudes',
        mensaje: _error!,
        esError: true,
        accion: OutlinedButton.icon(
          onPressed: _cargarReportes,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Intentar nuevamente'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sitioPrimary,
            side: const BorderSide(color: AppColors.sitioPrimary),
          ),
        ),
      );
    }

    if (_reportes.isEmpty) {
      return _panelMensaje(
        icono: Icons.inbox_outlined,
        titulo: 'Aún no tienes solicitudes',
        mensaje:
            'Cuando envíes un reporte o una sugerencia, aparecerá aquí con su estado.',
      );
    }

    return Column(children: _reportes.map(_tarjetaReporte).toList());
  }

  Widget _panelMensaje({
    required IconData icono,
    required String titulo,
    required String mensaje,
    bool esError = false,
    Widget? accion,
  }) {
    final color = esError ? AppColors.sitioError : AppColors.sitioPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingXl,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: esError ? AppColors.sitioErrorSoft : AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(AppDimensions.sitioFormRadius),
        border: Border.all(
          color: esError
              ? AppColors.sitioError.withValues(alpha: 0.25)
              : AppColors.sitioDivider,
        ),
      ),
      child: Column(
        children: [
          Icon(icono, size: 38, color: color),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          if (accion != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            accion,
          ],
        ],
      ),
    );
  }

  Widget _tarjetaReporte(Map<String, dynamic> reporte) {
    final tipo = reporte['tipoReporte']?.toString() ?? 'otro';
    final estado = reporte['estado']?.toString() ?? 'pendiente';
    final asunto = reporte['asunto']?.toString() ?? 'Sin asunto';
    final mensaje = reporte['mensaje']?.toString() ?? '';
    final respuesta = reporte['respuestaAdmin']?.toString().trim() ?? '';
    final fecha = _fecha(reporte['createdAt']);
    final color = _colorEstado(estado);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.sitioPanelCardGap),
      padding: const EdgeInsets.all(AppDimensions.sitioPanelCardPadding),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(AppDimensions.sitioFormRadius),
        border: Border.all(color: AppColors.sitioBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconoTipo(tipo),
                  color: AppColors.sitioPrimary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asunto,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.sitioTextPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_nombreTipo(tipo)} · $fecha',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.sitioTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sitioStatusHorizontalPadding,
                  vertical: AppDimensions.sitioStatusVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.sitioStatusRadius,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_iconoEstado(estado), size: 14, color: color),
                    const SizedBox(width: 5),
                    Text(
                      _nombreEstado(estado),
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (mensaje.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            const Divider(color: AppColors.sitioDivider, height: 1),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              mensaje,
              style: const TextStyle(
                height: 1.5,
                fontSize: 13,
                color: AppColors.sitioTextPrimary,
              ),
            ),
          ],
          if (respuesta.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.sitioSuccessSoft,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.mark_chat_read_outlined,
                        size: 19,
                        color: AppColors.sitioSuccess,
                      ),
                      SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: Text(
                          'Respuesta de la administración',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.sitioSuccess,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    respuesta,
                    style: const TextStyle(
                      color: AppColors.sitioTextPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esDesktop = ancho >= 900;

    return Scaffold(
      backgroundColor: AppColors.sitioBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sitioPrimaryDark,
        foregroundColor: AppColors.sitioTextOnPrimary,
        iconTheme: const IconThemeData(color: AppColors.sitioTextOnPrimary),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Reportes y sugerencias',
          style: TextStyle(
            color: AppColors.sitioTextOnPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargando ? null : _cargarReportes,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarReportes,
          color: AppColors.sitioPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: esDesktop
                  ? AppDimensions.sitioPagePadding
                  : AppDimensions.sitioPagePaddingCompact,
              vertical: AppDimensions.sitioSectionGapCompact,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _encabezado(esDesktop),
                    const SizedBox(height: AppDimensions.sitioSectionGap),
                    _resumen(ancho),
                    const SizedBox(height: AppDimensions.sitioSectionGap),
                    _construirFormulario(),
                    const SizedBox(height: AppDimensions.sitioSectionGap),
                    _construirHistorial(),
                    const SizedBox(height: AppDimensions.sitioSectionGap),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
