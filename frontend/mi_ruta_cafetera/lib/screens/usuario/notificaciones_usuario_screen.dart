import 'package:flutter/material.dart';

import '../../l10n/textos.dart';
import '../../models/usuario/notificacion_usuario_model.dart';
import '../../services/favorito_service.dart';
import '../../services/sitio_service.dart';
import '../../services/usuario/notificacion_usuario_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import 'detalle_sitio_usuario_screen.dart';

/// Lista de notificaciones del usuario.
///
/// Al tocar una novedad de actividad o producto se marca como leída
/// y se abre el detalle del sitio que la publicó.
class NotificacionesUsuarioScreen extends StatefulWidget {
  const NotificacionesUsuarioScreen({super.key});

  @override
  State<NotificacionesUsuarioScreen> createState() =>
      _NotificacionesUsuarioScreenState();
}

class _NotificacionesUsuarioScreenState
    extends State<NotificacionesUsuarioScreen> {
  final NotificacionUsuarioService _servicio =
      NotificacionUsuarioService.instance;

  List<NotificacionUsuarioModel> _notificaciones = [];

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
      final lista = await _servicio.obtener();

      if (!mounted) return;

      setState(() {
        _notificaciones = lista;
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

  Future<void> _marcarTodas() async {
    try {
      await _servicio.marcarTodasLeidas();

      if (!mounted) return;

      setState(() {
        _notificaciones =
            _notificaciones.map((n) => n.copiarLeida()).toList();
      });
    } catch (e) {
      _mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _abrir(NotificacionUsuarioModel notificacion) async {
    if (!notificacion.leida) {
      try {
        await _servicio.marcarLeida(notificacion.id);

        if (mounted) {
          setState(() {
            final indice =
                _notificaciones.indexWhere((n) => n.id == notificacion.id);

            if (indice != -1) {
              _notificaciones[indice] = notificacion.copiarLeida();
            }
          });
        }
      } catch (_) {
        // Si falla, igualmente se continúa con la navegación.
      }
    }

    if (!notificacion.abreSitio) {
      return;
    }

    await _abrirSitio(notificacion.sitioId!);
  }

  Future<void> _abrirSitio(String sitioId) async {
    final sesion = UsuarioSesionService.instance.sesionActual.value;

    try {
      final sitio = await SitioService().obtenerSitioPorId(sitioId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalleSitioUsuarioScreen(
            sitio: sitio,
            // Recibe avisos de este sitio porque lo tiene en favoritos.
            esFavorito: true,
            onFavorite: sesion == null
                ? null
                : () => _alternarFavorito(sitioId),
          ),
        ),
      );
    } catch (_) {
      _mostrarMensaje(Textos.t('No se pudo abrir el sitio.'));
    }
  }

  // Misma lógica del detalle desde el Home: quita el favorito si
  // existe y lo agrega si no.
  Future<void> _alternarFavorito(String sitioId) async {
    final sesion = UsuarioSesionService.instance.sesionActual.value;

    if (sesion == null) {
      throw Exception('Inicia sesión para usar favoritos.');
    }

    final favoritos = await FavoritoService.instance.obtenerFavoritos(
      sesion.id,
      token: sesion.token,
    );

    final existentes = favoritos.where((f) => f.sitio.id == sitioId);

    if (existentes.isNotEmpty) {
      await FavoritoService.instance.eliminarFavorito(
        existentes.first.id,
        token: sesion.token,
      );
    } else {
      await FavoritoService.instance.agregarFavorito(
        usuarioId: sesion.id,
        sitioId: sitioId,
        token: sesion.token,
      );
    }
  }

  void _mostrarMensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hayNoLeidas = _notificaciones.any((n) => !n.leida);

    return Scaffold(
      appBar: AppBar(
        title: Text(Textos.t('Notificaciones')),
        actions: [
          if (hayNoLeidas)
            IconButton(
              tooltip: Textos.t('Marcar todas como leídas'),
              onPressed: _marcarTodas,
              icon: const Icon(Icons.done_all_rounded),
            ),
        ],
      ),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _Mensaje(
        icono: Icons.cloud_off_rounded,
        texto: _error!,
        accion: TextButton(
          onPressed: _cargar,
          child: Text(Textos.t('Reintentar')),
        ),
      );
    }

    if (_notificaciones.isEmpty) {
      return _Mensaje(
        icono: Icons.notifications_none_rounded,
        texto: Textos.t(
          'Aún no tienes notificaciones. Guarda sitios en favoritos para enterarte de sus novedades.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.pageHorizontalSmall),
        itemCount: _notificaciones.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppDimensions.spacingSm),
        itemBuilder: (context, indice) {
          final notificacion = _notificaciones[indice];

          return _TarjetaNotificacion(
            notificacion: notificacion,
            onTap: () => _abrir(notificacion),
          );
        },
      ),
    );
  }
}

class _TarjetaNotificacion extends StatelessWidget {
  final NotificacionUsuarioModel notificacion;
  final VoidCallback onTap;

  const _TarjetaNotificacion({
    required this.notificacion,
    required this.onTap,
  });

  IconData get _icono {
    switch (notificacion.tipo) {
      case 'actividad':
        return Icons.hiking_rounded;
      case 'producto':
        return Icons.shopping_bag_rounded;
      case 'reserva':
        return Icons.event_available_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final leida = notificacion.leida;

    return Material(
      color: leida ? AppColors.surface : AppColors.cream,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: leida ? AppColors.border : AppColors.secondary,
              width: leida ? 0.7 : 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnDark,
                child: Icon(_icono),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notificacion.titulo,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight:
                                leida ? FontWeight.w600 : FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      notificacion.mensaje,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      _tiempo(notificacion.fecha),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (!leida)
                const Padding(
                  padding: EdgeInsets.only(left: AppDimensions.spacingSm),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _tiempo(DateTime? fecha) {
    if (fecha == null) return '';

    final diferencia = DateTime.now().difference(fecha.toLocal());

    if (diferencia.inMinutes < 1) return Textos.t('Ahora');

    if (diferencia.inMinutes < 60) {
      return Textos.t('Hace {0} min', [diferencia.inMinutes]);
    }

    if (diferencia.inHours < 24) {
      return Textos.t('Hace {0} h', [diferencia.inHours]);
    }

    if (diferencia.inDays < 7) {
      return Textos.t('Hace {0} días', [diferencia.inDays]);
    }

    final local = fecha.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}

class _Mensaje extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Widget? accion;

  const _Mensaje({
    required this.icono,
    required this.texto,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingSection),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: AppColors.textLight),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            ?accion,
          ],
        ),
      ),
    );
  }
}