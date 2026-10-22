import 'package:flutter/material.dart';

import '../../models/chat_model.dart';
import '../../models/clima_model.dart';
import '../../models/ia_recomendacion_model.dart';
import '../../services/chat_service.dart';
import '../../services/clima_service.dart';
import '../../services/ia_recomendaciones_service.dart';
import '../../services/ubicacion_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../utils/categoria_utils.dart';
import '../../widgets/usuario/icono_ia.dart';
import '../mapa_screen_2.dart';
import 'detalle_sitio_usuario_screen.dart';
import '../../l10n/textos.dart';

// ============================================================
// CHAT DE MI RUTA CAFETERA IA
// ============================================================
//
// Conversa con el asistente del backend (POST /api/chat).
//
// * Solo con sesión de usuario: el backend rechaza lo contrario.
// * La ubicación (y el clima de esa zona) solo se usan si la
//   persona activa "Usar mi ubicación"; se piden una única vez
//   mientras el chat esté abierto.
// * Los sitios mostrados bajo cada respuesta son sitios reales
//   que el backend detectó en el texto; la distancia es en
//   línea recta, no por carretera.
// ============================================================

class ChatIaScreen extends StatefulWidget {
  const ChatIaScreen({super.key});

  @override
  State<ChatIaScreen> createState() => _ChatIaScreenState();
}

class _ChatIaScreenState extends State<ChatIaScreen> {
  static const int _maxCaracteres = 500;

  static const List<String> _sugerencias = [
    'Quiero tomarme un café',
    '¿Qué puedo hacer esta tarde?',
    'Algo para un día de lluvia',
  ];

  final TextEditingController _textoController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final List<ChatMensaje> _mensajes = [];

  bool _enviando = false;

  // Contexto opcional, solo con permiso de la persona.
  bool _usarUbicacion = false;
  bool _cargandoContexto = false;
  UbicacionUsuario? _ubicacion;
  ClimaModel? _clima;

  @override
  void dispose() {
    _textoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // UBICACIÓN Y CLIMA (SOLO SI LA PERSONA LO ACTIVA)
  // ============================================================

  Future<void> _cambiarUbicacion(bool activar) async {
    if (!activar) {
      setState(() {
        _usarUbicacion = false;
      });
      return;
    }

    // Ya se obtuvieron antes: no se vuelve a pedir el GPS.
    if (_ubicacion != null) {
      setState(() {
        _usarUbicacion = true;
      });
      return;
    }

    setState(() {
      _cargandoContexto = true;
    });

    final resultado = await UbicacionService.obtener();

    if (!mounted) {
      return;
    }

    final ubicacion = resultado.ubicacion;

    if (ubicacion == null) {
      setState(() {
        _usarUbicacion = false;
        _cargandoContexto = false;
      });

      _mostrarMensaje(
        resultado.mensaje.isEmpty
            ? Textos.t('No fue posible obtener tu ubicación.')
            : resultado.mensaje,
      );
      return;
    }

    ClimaModel? clima;

    try {
      clima = await ClimaService.obtener(
        latitud: ubicacion.latitud,
        longitud: ubicacion.longitud,
      );
    } catch (_) {
      // Sin clima el chat sigue funcionando.
      clima = null;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _ubicacion = ubicacion;
      _clima = clima;
      _usarUbicacion = true;
      _cargandoContexto = false;
    });
  }

  // ============================================================
  // ENVIAR
  // ============================================================

  Future<void> _enviar([String? sugerencia]) async {
    final texto = (sugerencia ?? _textoController.text).trim();

    if (texto.isEmpty || _enviando) {
      return;
    }

    final sesion = UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null) {
      Navigator.of(context).maybePop();
      return;
    }

    // Historial = lo anterior a este mensaje.
    final historial = List<ChatMensaje>.from(_mensajes);

    setState(() {
      _mensajes.add(ChatMensaje(rol: ChatRol.usuario, texto: texto));
      _enviando = true;
      _textoController.clear();
    });

    _irAlFinal();

    try {
      final respuesta = await ChatService.enviar(
        token: sesion.token,
        mensaje: texto,
        historial: historial,
        ubicacion: _usarUbicacion ? _ubicacion : null,
        clima: _usarUbicacion ? _clima : null,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _mensajes.add(
          ChatMensaje(
            rol: ChatRol.asistente,
            texto: respuesta.respuesta,
            sitios: respuesta.sitios,
          ),
        );
        _enviando = false;
      });
    } on IaException catch (error) {
      if (!mounted) {
        return;
      }

      if (error.sesionInvalida) {
        await UsuarioSesionService.instance.cerrarSesionCompleta();
        return;
      }

      setState(() {
        _mensajes.add(
          ChatMensaje(
            rol: ChatRol.asistente,
            texto: error.mensaje,
            esError: true,
          ),
        );
        _enviando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _mensajes.add(
          ChatMensaje(
            rol: ChatRol.asistente,
            texto: Textos.t('No fue posible enviar tu mensaje.'),
            esError: true,
          ),
        );
        _enviando = false;
      });
    }

    _irAlFinal();
  }

  void _irAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: AppDimensions.animationFast),
        curve: Curves.easeOut,
      );
    });
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // ============================================================
  // ACCIONES SOBRE UN SITIO
  // ============================================================

  void _verDetalle(IaRecomendacion recomendacion) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalleSitioUsuarioScreen(
          sitio: recomendacion.sitio,
          imagen: CategoriaUtils.imagen(recomendacion.sitio.categoriaNombre),
          esFavorito: recomendacion.esFavorito,
          onRequiereCuenta: () {
            _mostrarMensaje(
              Textos.t('Guarda tus favoritos desde la pantalla de Inicio.'),
            );
          },
        ),
      ),
    );
  }

  void _verEnMapa(IaRecomendacion recomendacion) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapaScreen2(sitioInicial: recomendacion.sitio),
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
      appBar: AppBar(title: const Tr('Mi Ruta Cafetera IA')),
      body: Column(
        children: [
          Expanded(
            child: _mensajes.isEmpty
                ? _construirBienvenida()
                : _construirLista(),
          ),
          _construirUbicacion(),
          _construirEntrada(),
        ],
      ),
    );
  }

  // ============================================================
  // BIENVENIDA
  // ============================================================

  Widget _construirBienvenida() {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontal),
      children: [
        const Center(
          child: IconoIa(
            size: 56,
            iconoRespaldo: Icons.coffee_rounded,
            colorRespaldo: AppColors.secondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        const Tr(
          '¡Hola! ¿Qué te provoca hoy?',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        const Tr(
          'Te sugiero sitios reales del Huila. Si activas tu ubicación, tendré en cuenta qué tan cerca están y el clima de tu zona.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppDimensions.spacingSm,
          runSpacing: AppDimensions.spacingSm,
          children: [
            for (final sugerencia in _sugerencias)
              ActionChip(
                label: Tr(sugerencia),
                backgroundColor: AppColors.cream,
                side: const BorderSide(color: AppColors.border),
                onPressed: _enviando ? null : () => _enviar(sugerencia),
              ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // LISTA DE MENSAJES
  // ============================================================

  Widget _construirLista() {
    final total = _mensajes.length + (_enviando ? 1 : 0);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalSmall),
      itemCount: total,
      itemBuilder: (context, indice) {
        if (indice >= _mensajes.length) {
          return _construirEscribiendo();
        }

        return _construirMensaje(_mensajes[indice]);
      },
    );
  }

  Widget _construirEscribiendo() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
        child: Tr(
          'Escribiendo…',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _construirMensaje(ChatMensaje mensaje) {
    final esUsuario = mensaje.rol == ChatRol.usuario;

    final colorFondo = esUsuario
        ? AppColors.primary
        : mensaje.esError
        ? AppColors.orangeSoft
        : AppColors.surface;

    final colorTexto = esUsuario ? AppColors.white : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
      child: Column(
        crossAxisAlignment: esUsuario
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.82,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              decoration: BoxDecoration(
                color: colorFondo,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: esUsuario ? null : Border.all(color: AppColors.border),
              ),
              child: Text(
                mensaje.texto,
                style: TextStyle(color: colorTexto, fontSize: 15, height: 1.4),
              ),
            ),
          ),
          for (final recomendacion in mensaje.sitios) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            _construirSitio(recomendacion),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TARJETA DE SITIO REAL
  // ============================================================

  Widget _construirSitio(IaRecomendacion recomendacion) {
    final sitio = recomendacion.sitio;
    final categoria = sitio.categoriaNombre;
    final color = AppColors.getColorForCategory(categoria);

    final detalles = <String>[
      if (categoria.isNotEmpty) categoria,
      if (sitio.ciudad.isNotEmpty) sitio.ciudad,
      if (recomendacion.distanciaKm != null)
        Textos.t('≈ {0} km en línea recta', [recomendacion.distanciaKm!.toStringAsFixed(1)]),
    ];

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.82,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppColors.getIconForCategory(categoria),
                  color: color,
                  size: AppDimensions.iconMd,
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Expanded(
                  child: Text(
                    sitio.nombre,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (detalles.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                detalles.join(' · '),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingSm),
            Wrap(
              spacing: AppDimensions.spacingSm,
              children: [
                TextButton.icon(
                  onPressed: () => _verDetalle(recomendacion),
                  icon: const Icon(Icons.info_outline_rounded),
                  label: const Tr('Ver detalle'),
                ),
                TextButton.icon(
                  onPressed: () => _verEnMapa(recomendacion),
                  icon: const Icon(Icons.map_rounded),
                  label: const Tr('Ver en el mapa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // UBICACIÓN
  // ============================================================

  Widget _construirUbicacion() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _usarUbicacion
                  ? Textos.t('Usando tu ubicación (distancias en línea recta)')
                  : Textos.t('Usar mi ubicación para sugerencias cercanas'),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          if (_cargandoContexto)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingSm),
              child: SizedBox(
                width: AppDimensions.iconSm,
                height: AppDimensions.iconSm,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Switch(
              value: _usarUbicacion,
              onChanged: _enviando ? null : _cambiarUbicacion,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ENTRADA DE TEXTO
  // ============================================================

  Widget _construirEntrada() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pageHorizontalSmall,
          AppDimensions.spacingXs,
          AppDimensions.pageHorizontalSmall,
          AppDimensions.spacingMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textoController,
                enabled: !_enviando,
                maxLength: _maxCaracteres,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _enviar(),
                decoration: InputDecoration(
                  hintText: Textos.t('Escribe tu mensaje'),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            IconButton.filled(
              onPressed: _enviando ? null : () => _enviar(),
              icon: const Icon(Icons.send_rounded),
              tooltip: Textos.t('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
