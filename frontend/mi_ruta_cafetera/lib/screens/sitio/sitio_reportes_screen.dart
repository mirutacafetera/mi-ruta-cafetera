import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../services/sitio/sitio_ayuda_service.dart';

class SitioReportesScreen extends StatefulWidget {
  const SitioReportesScreen({super.key});

  @override
  State<SitioReportesScreen> createState() => _SitioReportesScreenState();
}

class _SitioReportesScreenState extends State<SitioReportesScreen> {
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

    if (!_formKey.currentState!.validate() || _enviando) return;

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu reporte fue enviado correctamente.'),
          backgroundColor: AppColors.sitioSuccess,
        ),
      );

      await _cargarReportes();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.sitioError,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  String _nombreTipo(String tipo) {
    switch (tipo) {
      case 'problema':
        return 'Reportar un problema';
      case 'sugerencia':
        return 'Enviar una sugerencia';
      case 'mejora':
        return 'Proponer una mejora';
      case 'otro':
        return 'Otro';
      default:
        return tipo;
    }
  }

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

  Widget _construirFormulario() {
    return Card(
      color: AppColors.sitioSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.sitioPanelCardRadius),
        side: const BorderSide(color: AppColors.sitioBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.sitioPanelCardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cuéntanos cómo podemos ayudarte',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sitioTextPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              const Text(
                'Tu comentario nos ayuda a mejorar la experiencia de los sitios turísticos.',
                style: TextStyle(
                  height: 1.45,
                  color: AppColors.sitioTextSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.sitioFormSectionGap),
              DropdownButtonFormField<String>(
                initialValue: _tipoReporte,
                isExpanded: true,
                decoration: _decoracion(
                  'Tipo de solicitud',
                  Icons.category_outlined,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'problema',
                    child: Text('Reportar un problema'),
                  ),
                  DropdownMenuItem(
                    value: 'sugerencia',
                    child: Text('Enviar una sugerencia'),
                  ),
                  DropdownMenuItem(
                    value: 'mejora',
                    child: Text('Proponer una mejora'),
                  ),
                  DropdownMenuItem(value: 'otro', child: Text('Otro')),
                ],
                onChanged: _enviando
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _tipoReporte = value);
                        }
                      },
              ),
              const SizedBox(height: AppDimensions.sitioFormFieldGap),
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
      ),
    );
  }

  InputDecoration _decoracion(
    String etiqueta,
    IconData icono, {
    String? hint,
    bool alignLabel = false,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: hint,
      alignLabelWithHint: alignLabel,
      prefixIcon: Icon(icono, color: AppColors.sitioPrimary),
      filled: true,
      fillColor: AppColors.sitioSurfaceSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.sitioFormRadius),
        borderSide: const BorderSide(color: AppColors.sitioBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.sitioFormRadius),
        borderSide: const BorderSide(color: AppColors.sitioBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.sitioFormRadius),
        borderSide: const BorderSide(color: AppColors.sitioPrimary, width: 1.5),
      ),
    );
  }

  Widget _construirHistorial() {
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
        icono: Icons.cloud_off_outlined,
        mensaje: _error!,
        accion: TextButton.icon(
          onPressed: _cargarReportes,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      );
    }

    if (_reportes.isEmpty) {
      return _panelMensaje(
        icono: Icons.inbox_outlined,
        mensaje: 'Todavía no has enviado reportes ni sugerencias.',
      );
    }

    return Column(children: _reportes.map(_tarjetaReporte).toList());
  }

  Widget _panelMensaje({
    required IconData icono,
    required String mensaje,
    Widget? accion,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(AppDimensions.sitioPanelCardRadius),
        border: Border.all(color: AppColors.sitioBorder),
      ),
      child: Column(
        children: [
          Icon(icono, size: 34, color: AppColors.sitioPrimary),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              height: 1.45,
            ),
          ),
          if (accion != null) ...[
            const SizedBox(height: AppDimensions.spacingSm),
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

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sitioPanelCardGap),
      color: AppColors.sitioSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.sitioPanelCardRadius),
        side: const BorderSide(color: AppColors.sitioBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.sitioPanelCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sitioSurfaceGreen,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.sitioStatusRadius,
                    ),
                  ),
                  child: Text(
                    _nombreTipo(tipo),
                    style: const TextStyle(
                      color: AppColors.sitioPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.sitioStatusRadius,
                    ),
                  ),
                  child: Text(
                    _nombreEstado(estado),
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              asunto,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.sitioTextPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              fecha,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.sitioTextSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              mensaje,
              style: const TextStyle(
                height: 1.45,
                color: AppColors.sitioTextPrimary,
              ),
            ),
            if (respuesta.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingLg),
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
                          size: 20,
                          color: AppColors.sitioSuccess,
                        ),
                        SizedBox(width: AppDimensions.spacingSm),
                        Expanded(
                          child: Text(
                            'Respuesta de la administración',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
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
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sitioBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sitioBackground,
        foregroundColor: AppColors.sitioTextPrimary,
        elevation: 0,
        title: const Text(
          'Reportes y sugerencias',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarReportes,
          color: AppColors.sitioPrimary,
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.sitioPagePadding),
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                decoration: BoxDecoration(
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.sitioPanelCardRadius,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      size: 32,
                      color: AppColors.sitioPrimary,
                    ),
                    SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Text(
                        'Tu opinión importa. Envíanos tus comentarios y consulta aquí el seguimiento de cada solicitud.',
                        style: TextStyle(
                          height: 1.45,
                          color: AppColors.sitioTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.sitioSectionGap),
              _construirFormulario(),
              const SizedBox(height: AppDimensions.sitioSectionGap),
              const Text(
                'Mis solicitudes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sitioTextPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              const Text(
                'Consulta su estado y las respuestas de la administración.',
                style: TextStyle(
                  color: AppColors.sitioTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              _construirHistorial(),
              const SizedBox(height: AppDimensions.spacingXl),
            ],
          ),
        ),
      ),
    );
  }
}
