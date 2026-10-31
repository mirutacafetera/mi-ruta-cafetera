import 'package:flutter/material.dart';

import '../../models/sitio/sitio_resena_model.dart';
import '../../services/sitio/sitio_panel_resenas_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/sitio/estado_resenas_sitio.dart';
import '../../widgets/sitio/sitio_avatar_perfil.dart';
import '../../widgets/sitio/tarjeta_resumen_resenas_sitio.dart';
import '../../widgets/sitio/tarjeta_seccion_sitio.dart';

class SitioResenasScreen extends StatefulWidget {
  const SitioResenasScreen({super.key});

  @override
  State<SitioResenasScreen> createState() => _SitioResenasScreenState();
}

class _SitioResenasScreenState extends State<SitioResenasScreen> {
  final SitioPanelResenasService _servicio =
      SitioPanelResenasService.instance;

  List<SitioResenaModel> _resenas = [];
  bool _cargando = true;
  String? _error;

  String _orden = 'recientes';
  int? _calificacionSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    if (mounted) {
      setState(() {
        _cargando = true;
        _error = null;
      });
    }

    try {
      final resultado = await _servicio.obtenerResenas();

      if (!mounted) return;

      setState(() {
        _resenas = resultado;
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

  List<SitioResenaModel> get _resenasVisibles {
    final resultado = _resenas.where((resena) {
      if (_calificacionSeleccionada != null &&
          resena.calificacion != _calificacionSeleccionada) {
        return false;
      }

      return true;
    }).toList();

    resultado.sort((a, b) {
      final fechaA =
          a.creadaEn ?? DateTime.fromMillisecondsSinceEpoch(0);
      final fechaB =
          b.creadaEn ?? DateTime.fromMillisecondsSinceEpoch(0);

      return _orden == 'antiguas'
          ? fechaA.compareTo(fechaB)
          : fechaB.compareTo(fechaA);
    });

    return resultado;
  }

  double get _promedio {
    if (_resenas.isEmpty) return 0;

    final suma = _resenas.fold<int>(
      0,
      (total, resena) => total + resena.calificacion,
    );

    return suma / _resenas.length;
  }

  int get _positivas =>
      _resenas.where((resena) => resena.calificacion >= 4).length;

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Fecha no disponible';

    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');

    return '$dia/$mes/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.sizeOf(context).width;
    final esEscritorio = ancho >= 900;

    return Container(
      color: AppColors.sitioBackground,
      child: SingleChildScrollView(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _encabezado(context, ancho),
                const SizedBox(
                  height: AppDimensions.sitioSectionGap,
                ),
                _resumen(esEscritorio),
                const SizedBox(
                  height: AppDimensions.sitioSectionGap,
                ),
                _seccion(esEscritorio),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context, double ancho) {
    final compacto = ancho < 420;

    return Container(
      padding: EdgeInsets.all(
        compacto ? AppDimensions.sitioPanelCardPadding : 22,
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
            width: compacto ? 48 : 56,
            height: compacto ? 48 : 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.rate_review_rounded,
              color: AppColors.sitioTextOnPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reseñas de visitantes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.sitioTextOnPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: compacto ? 18 : 22,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Conoce las experiencias de quienes visitan tu sitio.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resumen(bool esEscritorio) {
    final tarjetas = [
      TarjetaResumenResenasSitio(
        icono: Icons.star_rounded,
        titulo: 'Calificación',
        valor: _promedio.toStringAsFixed(1),
        descripcion: 'Promedio sobre 5',
      ),
      TarjetaResumenResenasSitio(
        icono: Icons.rate_review_rounded,
        titulo: 'Reseñas',
        valor: '${_resenas.length}',
        descripcion: 'Opiniones recibidas',
      ),
      TarjetaResumenResenasSitio(
        icono: Icons.thumb_up_alt_rounded,
        titulo: 'Valoraciones positivas',
        valor: '$_positivas',
        descripcion: 'Calificaciones de 4 o 5 estrellas',
      ),
    ];

    if (esEscritorio) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < tarjetas.length; i++) ...[
            if (i > 0)
              const SizedBox(
                width: AppDimensions.sitioPanelCardGap,
              ),
            Expanded(child: tarjetas[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (int i = 0; i < tarjetas.length; i++) ...[
          if (i > 0)
            const SizedBox(
              height: AppDimensions.sitioPanelCardGap,
            ),
          tarjetas[i],
        ],
      ],
    );
  }

  Widget _seccion(bool esEscritorio) {
    return TarjetaSeccionSitio(
      titulo: 'Opiniones de los visitantes',
      subtitulo:
          'Consulta los comentarios y filtra las reseñas por calificación.',
      icono: Icons.forum_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _filtros(esEscritorio),
          const SizedBox(
            height: AppDimensions.sitioSectionGapCompact,
          ),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.sitioPrimary,
                ),
              ),
            )
          else if (_error != null)
            _estadoError()
          else if (_resenas.isEmpty)
            const EstadoResenasSitio()
          else if (_resenasVisibles.isEmpty)
            _sinResultados()
          else
            ..._resenasVisibles.map(_tarjetaResena),
        ],
      ),
    );
  }

  Widget _filtros(bool esEscritorio) {
    final orden = DropdownButtonFormField<String>(
      initialValue: _orden,
      isExpanded: true,
      decoration: _decoracionFiltro('Ordenar por'),
      dropdownColor: AppColors.sitioSurface,
      iconEnabledColor: AppColors.sitioPrimary,
      items: const [
        DropdownMenuItem(
          value: 'recientes',
          child: Text('Más recientes'),
        ),
        DropdownMenuItem(
          value: 'antiguas',
          child: Text('Más antiguas'),
        ),
      ],
      onChanged: (valor) {
        if (valor == null) return;
        setState(() => _orden = valor);
      },
    );

    final calificacion = DropdownButtonFormField<int?>(
      initialValue: _calificacionSeleccionada,
      isExpanded: true,
      decoration: _decoracionFiltro('Calificación'),
      dropdownColor: AppColors.sitioSurface,
      iconEnabledColor: AppColors.sitioPrimary,
      items: const [
        DropdownMenuItem<int?>(
          value: null,
          child: Text('Todas las calificaciones'),
        ),
        DropdownMenuItem<int?>(
          value: 5,
          child: Text('5 estrellas'),
        ),
        DropdownMenuItem<int?>(
          value: 4,
          child: Text('4 estrellas'),
        ),
        DropdownMenuItem<int?>(
          value: 3,
          child: Text('3 estrellas'),
        ),
        DropdownMenuItem<int?>(
          value: 2,
          child: Text('2 estrellas'),
        ),
        DropdownMenuItem<int?>(
          value: 1,
          child: Text('1 estrella'),
        ),
      ],
      onChanged: (valor) {
        setState(() => _calificacionSeleccionada = valor);
      },
    );

    final actualizar = IconButton(
      tooltip: 'Actualizar reseñas',
      onPressed: _cargando ? null : _cargarResenas,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.sitioSurfaceGreen,
        foregroundColor: AppColors.sitioPrimary,
        minimumSize: const Size(48, 48),
      ),
      icon: const Icon(Icons.refresh_rounded),
    );

    if (esEscritorio) {
      return Row(
        children: [
          Expanded(child: orden),
          const SizedBox(width: AppDimensions.sitioPanelCardGap),
          Expanded(child: calificacion),
          const SizedBox(width: AppDimensions.sitioPanelCardGap),
          actualizar,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        orden,
        const SizedBox(height: AppDimensions.sitioFormFieldGap),
        calificacion,
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _cargando ? null : _cargarResenas,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.sitioPrimary,
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Actualizar reseñas'),
          ),
        ),
      ],
    );
  }

  InputDecoration _decoracionFiltro(String etiqueta) {
    return InputDecoration(
      labelText: etiqueta,
      labelStyle: const TextStyle(
        color: AppColors.sitioTextSecondary,
      ),
      filled: true,
      fillColor: AppColors.sitioSurfaceSoft,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioFormRadius,
        ),
        borderSide: const BorderSide(
          color: AppColors.sitioPrimary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _tarjetaResena(SitioResenaModel resena) {
    final nombre = resena.nombreUsuario.trim().isEmpty
        ? 'Visitante'
        : resena.nombreUsuario.trim();

    final comentario = resena.comentario.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SitioAvatarPerfil(
                fotoPerfil: resena.fotoPerfil,
                avatar: resena.avatar,
                nombre: nombre,
                radio: 24,
                colorFondo: AppColors.sitioSurfaceGreen,
                colorIcono: AppColors.sitioPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.sitioTextPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: AppColors.sitioTextSecondary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            _formatearFecha(resena.creadaEn),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.sitioTextSecondary,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sitioWarningSoft,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.sitioStatusRadius,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.sitioWarning,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${resena.calificacion}/5',
                      style: const TextStyle(
                        color: AppColors.sitioWarning,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              5,
              (indice) => Icon(
                indice < resena.calificacion
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: AppColors.sitioAccent,
                size: 21,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              comentario.isEmpty
                  ? 'Este visitante no dejó un comentario escrito.'
                  : comentario,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.sitioTextPrimary,
                    height: 1.55,
                  ),
            ),
          ),

          // --- VISOR DE IMÁGENES ADJUNTAS EN LA RESEÑA ---
          if (resena.imagenes.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: resena.imagenes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final urlImagen = resena.imagenes[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => _mostrarVisorImagen(context, urlImagen),
                      child: Image.network(
                        urlImagen,
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 84,
                          height: 84,
                          color: AppColors.sitioSurfaceSoft,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.sitioTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _mostrarVisorImagen(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.sitioSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              size: 30,
              color: AppColors.sitioError,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No pudimos cargar las reseñas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.sitioTextPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _cargarResenas,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.sitioPrimary,
              foregroundColor: AppColors.sitioTextOnPrimary,
              minimumSize: const Size(0, 46),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }

  Widget _sinResultados() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.filter_alt_off_rounded,
              size: 30,
              color: AppColors.sitioPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No hay reseñas con esa calificación',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.sitioTextPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Prueba con otra calificación o consulta todas las opiniones.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              setState(() => _calificacionSeleccionada = null);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.sitioPrimary,
            ),
            icon: const Icon(Icons.filter_alt_off_rounded),
            label: const Text('Mostrar todas'),
          ),
        ],
      ),
    );
  }
}