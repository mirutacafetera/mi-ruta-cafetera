import 'package:flutter/material.dart';

import '../../services/usuario/ayuda_usuario_service.dart';
import '../../services/usuario/preferencias_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

// ============================================================
// AYUDA Y SOPORTE
// ============================================================
//
// Permite al usuario con sesión enviar un reporte al equipo y
// ver el estado y la respuesta de sus reportes anteriores.
//
// - La identidad sale del token de la sesión: la pantalla nunca
//   pide ni envía un id de usuario.
// - Mientras se envía, el botón queda bloqueado (sin doble
//   envío).
// - Los textos se resuelven aquí según el idioma elegido en
//   Preferencias (español / inglés), sin depender de las
//   tablas globales de traducción.
// ============================================================

/// Texto en el idioma activo de la aplicación.
String _tx(String es, String en) {
  return PreferenciasService.instance.idioma.value == IdiomaApp.en ? en : es;
}

/// Textos que también usa la entrada del menú de Mi perfil.
class AyudaTextos {
  AyudaTextos._();

  static String get titulo => _tx('Ayuda y soporte', 'Help & support');

  static String get descripcion => _tx(
        'Envía una consulta o reporta un problema',
        'Send a question or report a problem',
      );
}

class AyudaSoporteScreen extends StatefulWidget {
  const AyudaSoporteScreen({
    super.key,
  });

  @override
  State<AyudaSoporteScreen> createState() => _AyudaSoporteScreenState();
}

class _AyudaSoporteScreenState extends State<AyudaSoporteScreen> {
  final _asuntoController = TextEditingController();
  final _mensajeController = TextEditingController();

  bool _enviando = false;

  bool _cargandoLista = true;
  String? _errorLista;
  List<ReporteAyuda> _reportes = const [];

  String? _errorAsunto;
  String? _errorMensaje;

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
    setState(() {
      _cargandoLista = true;
      _errorLista = null;
    });

    final resultado = await AyudaUsuarioService.misReportes();

    if (!mounted) {
      return;
    }

    setState(() {
      _cargandoLista = false;

      if (resultado['exito'] == true) {
        _reportes = resultado['reportes'] as List<ReporteAyuda>;
      } else {
        final mensaje = (resultado['mensaje'] ?? '').toString();
        _errorLista = mensaje.isEmpty
            ? _tx(
                'No fue posible cargar tus reportes.',
                'Your reports could not be loaded.',
              )
            : mensaje;
      }
    });
  }

  bool _validar() {
    final error = AyudaUsuarioService.validar(
      asunto: _asuntoController.text,
      mensaje: _mensajeController.text,
    );

    final asuntoMal = error == ErrorFormularioAyuda.asuntoLongitud;
    final mensajeMal = error == ErrorFormularioAyuda.mensajeLongitud;

    setState(() {
      _errorAsunto = asuntoMal
          ? _tx(
              'Escribe un asunto de ${AyudaUsuarioService.asuntoMin} a '
                  '${AyudaUsuarioService.asuntoMax} caracteres.',
              'Enter a subject of ${AyudaUsuarioService.asuntoMin} to '
                  '${AyudaUsuarioService.asuntoMax} characters.',
            )
          : null;

      _errorMensaje = mensajeMal
          ? _tx(
              'Cuéntanos con ${AyudaUsuarioService.mensajeMin} a '
                  '${AyudaUsuarioService.mensajeMax} caracteres.',
              'Tell us in ${AyudaUsuarioService.mensajeMin} to '
                  '${AyudaUsuarioService.mensajeMax} characters.',
            )
          : null;
    });

    return error == null;
  }

  Future<void> _enviar() async {
    // Evita envíos duplicados (doble toque).
    if (_enviando) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_validar()) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    setState(() => _enviando = true);

    final resultado = await AyudaUsuarioService.enviarReporte(
      asunto: _asuntoController.text,
      mensaje: _mensajeController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() => _enviando = false);

    if (resultado['exito'] == true) {
      _asuntoController.clear();
      _mensajeController.clear();

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _tx(
              'Reporte enviado. Te responderemos pronto.',
              'Report sent. We will get back to you soon.',
            ),
          ),
        ),
      );

      _cargarReportes();
      return;
    }

    final codigo = resultado['codigo'];
    var mensaje = (resultado['mensaje'] ?? '').toString();

    if (codigo == 401) {
      mensaje = _tx(
        'Tu sesión expiró. Inicia sesión de nuevo para enviar el reporte.',
        'Your session expired. Sign in again to send the report.',
      );
    } else if (mensaje.isEmpty) {
      mensaje = _tx(
        'No fue posible enviar el reporte.',
        'The report could not be sent.',
      );
    }

    // El texto escrito se conserva para poder reintentar.
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(mensaje),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IdiomaApp>(
      valueListenable: PreferenciasService.instance.idioma,
      builder: (context, idioma, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(AyudaTextos.titulo),
          ),
          body: SafeArea(
            child: ValueListenableBuilder(
              valueListenable: UsuarioSesionService.instance.sesionActual,
              builder: (context, sesion, _) {
                if (sesion == null) {
                  return _construirSinSesion();
                }

                return RefreshIndicator(
                  onRefresh: _cargarReportes,
                  child: _construirContenido(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _construirSinSesion() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
        child: Text(
          _tx(
            'Inicia sesión para enviar un reporte al equipo de soporte.',
            'Sign in to send a report to the support team.',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.45,
          ),
        ),
      ),
    );
  }

  Widget _construirContenido() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
      children: [
        Text(
          _tx(
            '¿Tienes una duda o encontraste un problema? Cuéntanos y '
                'te responderemos desde la aplicación.',
            'Have a question or found a problem? Tell us and we will '
                'reply inside the app.',
          ),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        TextField(
          controller: _asuntoController,
          enabled: !_enviando,
          maxLength: AyudaUsuarioService.asuntoMax,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: _tx('Asunto', 'Subject'),
            errorText: _errorAsunto,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        TextField(
          controller: _mensajeController,
          enabled: !_enviando,
          maxLength: AyudaUsuarioService.mensajeMax,
          minLines: 5,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            labelText: _tx('Mensaje', 'Message'),
            alignLabelWithHint: true,
            errorText: _errorMensaje,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        SizedBox(
          height: AppDimensions.buttonHeightLarge,
          child: FilledButton.icon(
            onPressed: _enviando ? null : _enviar,
            icon: _enviando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(
              _enviando
                  ? _tx('Enviando...', 'Sending...')
                  : _tx('Enviar reporte', 'Send report'),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.sectionGap),
        Text(
          _tx('Mis reportes', 'My reports'),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        ..._construirLista(),
      ],
    );
  }

  List<Widget> _construirLista() {
    if (_cargandoLista) {
      return const [
        Padding(
          padding: EdgeInsets.all(AppDimensions.spacingLg),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_errorLista != null) {
      return [
        Text(
          _errorLista!,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _cargarReportes,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(_tx('Reintentar', 'Retry')),
          ),
        ),
      ];
    }

    if (_reportes.isEmpty) {
      return [
        Text(
          _tx(
            'Aún no has enviado reportes.',
            'You have not sent any reports yet.',
          ),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ];
    }

    return [
      for (final reporte in _reportes) ...[
        _TarjetaReporte(reporte: reporte),
        const SizedBox(height: AppDimensions.spacingMd),
      ],
    ];
  }
}

// ============================================================
// TARJETA DE UN REPORTE
// ============================================================

class _TarjetaReporte extends StatelessWidget {
  const _TarjetaReporte({
    required this.reporte,
  });

  final ReporteAyuda reporte;

  String get _estado {
    switch (reporte.estado) {
      case 'en_revision':
        return _tx('En revisión', 'In review');
      case 'resuelto':
        return _tx('Resuelto', 'Resolved');
      default:
        return _tx('Pendiente', 'Pending');
    }
  }

  String? get _fecha {
    final fecha = reporte.creadoEn;

    if (fecha == null) {
      return null;
    }

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    final fecha = _fecha;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reporte.asunto,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                _estado,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (fecha != null) ...[
            const SizedBox(height: 2),
            Text(
              fecha,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            reporte.mensaje,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (reporte.respuestaAdmin != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              _tx('Respuesta del equipo', 'Team reply'),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              reporte.respuestaAdmin!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
