
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
  State<SitioResenasScreen> createState() =>
      _SitioResenasScreenState();
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: esEscritorio
            ? AppDimensions.pageHorizontal
            : AppDimensions.pageHorizontalSmall,
        vertical: AppDimensions.spacingLg,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _encabezado(context),
              const SizedBox(height: AppDimensions.spacingLg),
              _resumen(esEscritorio),
              const SizedBox(height: AppDimensions.sectionGap),
              _seccion(esEscritorio),
            ],
          ),
        ),
      ),
    );
  }

  Widget _encabezado(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reseñas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          'Consulta las opiniones que los visitantes han dejado sobre tu sitio turístico.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
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
        titulo: 'Valoraciones',
        valor: '$_positivas',
        descripcion: 'Calificaciones de 4 o 5 estrellas',
      ),
    ];

    if (esEscritorio) {
      return Row(
        children: [
          for (int i = 0; i < tarjetas.length; i++) ...[
            if (i > 0)
              const SizedBox(width: AppDimensions.spacingMd),
            Expanded(child: tarjetas[i]),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (int i = 0; i < tarjetas.length; i++) ...[
          if (i > 0)
            const SizedBox(height: AppDimensions.spacingMd),
          tarjetas[i],
        ],
      ],
    );
  }

  Widget _seccion(bool esEscritorio) {
    return TarjetaSeccionSitio(
      titulo: 'Opiniones de los visitantes',
      subtitulo:
          'Consulta las experiencias y comentarios que han compartido tus visitantes.',
      icono: Icons.rate_review_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filtros(esEscritorio),
          const SizedBox(height: AppDimensions.spacingLg),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingXl),
              child: Center(child: CircularProgressIndicator()),
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
      value: _orden,
      decoration: const InputDecoration(
        labelText: 'Ordenar por',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
      ),
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
      value: _calificacionSeleccionada,
      decoration: const InputDecoration(
        labelText: 'Calificación',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
      ),
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

    if (esEscritorio) {
      return Row(
        children: [
          Expanded(child: orden),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(child: calificacion),
          const SizedBox(width: AppDimensions.spacingMd),
          IconButton(
            tooltip: 'Actualizar reseñas',
            onPressed: _cargando ? null : _cargarResenas,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        orden,
        const SizedBox(height: AppDimensions.spacingMd),
        calificacion,
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _cargando ? null : _cargarResenas,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Actualizar reseñas'),
          ),
        ),
      ],
    );
  }

  Widget _tarjetaResena(SitioResenaModel resena) {
    final nombre = resena.nombreUsuario.trim().isEmpty
        ? 'Visitante'
        : resena.nombreUsuario.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SitioAvatarPerfil(
                fotoPerfil: resena.fotoPerfil,
                nombre: nombre,
                radio: 24,
                colorFondo: AppColors.surfaceGreen,
                colorIcono: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      _formatearFecha(resena.creadaEn),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${resena.calificacion}/5',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: List.generate(
              5,
              (indice) => Icon(
                indice < resena.calificacion
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: AppColors.primary,
                size: AppDimensions.iconSm,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            resena.comentario.trim().isEmpty
                ? 'Sin comentario escrito.'
                : resena.comentario,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _estadoError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 40),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'No pudimos cargar las reseñas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          SelectableText(
            _error!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          FilledButton.icon(
            onPressed: _cargarResenas,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }

  Widget _sinResultados() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        children: [
          const Icon(Icons.filter_alt_off_rounded, size: 40),
          const SizedBox(height: AppDimensions.spacingMd),
          const Text(
            'No hay reseñas con esa calificación.',
            textAlign: TextAlign.center,
          ),
          TextButton(
            onPressed: () {
              setState(() => _calificacionSeleccionada = null);
            },
            child: const Text('Mostrar todas'),
          ),
        ],
      ),
    );
  }
}