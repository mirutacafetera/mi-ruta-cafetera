
import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import '../../../l10n/textos.dart';
import '../../../widgets/usuario/detalle_sitio/componentes_detalle.dart';

class DetalleGaleria extends StatelessWidget {
  final List<String> imagenes;
  final bool cargando;

  /// Cuando la pantalla que lo contiene ya dibuja el encabezado
  /// de la sección, se envía `false` para no repetirlo.
  final bool mostrarEncabezado;

  const DetalleGaleria({
    super.key,
    required this.imagenes,
    this.cargando = false,
    this.mostrarEncabezado = true,
  });

  List<String> get _imagenesValidas {
    return imagenes
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final fotos = _imagenesValidas;

    if (cargando) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXxl),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.sitioPrimary,
          ),
        ),
      );
    }

    if (fotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
        vertical: AppDimensions.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mostrarEncabezado) ...[
            EncabezadoSeccionDetalle(
              icono: Icons.photo_library_rounded,
              titulo: Textos.t('Galería de imágenes'),
              descripcion: Textos.t('Conoce cada rincón de este lugar.'),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
          ],
          SizedBox(
            height: 142,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fotos.length > 5 ? 5 : fotos.length,
              separatorBuilder: (_, _) => const SizedBox(
                width: AppDimensions.spacingMd - 2,
              ),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 164,
                  child: _miniatura(
                    context,
                    fotos,
                    index,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: () => _mostrarGaleriaCompleta(
                context,
                fotos,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sitioPrimary,
                side: const BorderSide(
                  color: AppColors.sitioPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLg,
                  ),
                ),
              ),
              icon: const Icon(Icons.grid_view_rounded),
              label: Tr('Ver toda la galería ({0})', args: [fotos.length]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniatura(
    BuildContext context,
    List<String> fotos,
    int index,
  ) {
    return Material(
      color: AppColors.sitioSurfaceGreen,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _mostrarImagen(context, fotos, index),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              fotos[index],
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.sitioPrimary,
                  size: 34,
                ),
              ),
            ),
            Positioned(
              right: AppDimensions.spacingSm,
              bottom: AppDimensions.spacingSm,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.zoom_in_rounded,
                  color: AppColors.white,
                  size: AppDimensions.iconSm,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarGaleriaCompleta(
    BuildContext context,
    List<String> fotos,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _GaleriaCompletaScreen(imagenes: fotos),
      ),
    );
  }

  void _mostrarImagen(
    BuildContext context,
    List<String> fotos,
    int indice,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _GaleriaCompletaScreen(
          imagenes: fotos,
          indiceInicial: indice,
          modoCarrusel: true,
        ),
      ),
    );
  }
}

class _GaleriaCompletaScreen extends StatefulWidget {
  final List<String> imagenes;
  final int indiceInicial;
  final bool modoCarrusel;

  const _GaleriaCompletaScreen({
    required this.imagenes,
    this.indiceInicial = 0,
    this.modoCarrusel = false,
  });

  @override
  State<_GaleriaCompletaScreen> createState() =>
      _GaleriaCompletaScreenState();
}

class _GaleriaCompletaScreenState extends State<_GaleriaCompletaScreen> {
  late final PageController _pageController;
  late int _indiceActual;

  @override
  void initState() {
    super.initState();
    _indiceActual = widget.indiceInicial;
    _pageController = PageController(
      initialPage: widget.indiceInicial,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sitioBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sitioPrimary,
        foregroundColor: AppColors.white,
        title: Tr(
          'Galería · {0} de {1}', args: [_indiceActual + 1, widget.imagenes.length],
        ),
      ),
      body: widget.modoCarrusel
          ? _carrusel()
          : _cuadricula(),
    );
  }

  Widget _cuadricula() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.sitioContentPadding),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        crossAxisSpacing: AppDimensions.spacingMd,
        mainAxisSpacing: AppDimensions.spacingMd,
        childAspectRatio: 0.9,
      ),
      itemCount: widget.imagenes.length,
      itemBuilder: (context, index) {
        return Material(
          color: AppColors.sitioSurface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              setState(() {
                _indiceActual = index;
              });
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _GaleriaCompletaScreen(
                    imagenes: widget.imagenes,
                    indiceInicial: index,
                    modoCarrusel: true,
                  ),
                ),
              );
            },
            child: Image.network(
              widget.imagenes[index],
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 36,
                  color: AppColors.sitioPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _carrusel() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imagenes.length,
            onPageChanged: (indice) {
              setState(() {
                _indiceActual = indice;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.network(
                    widget.imagenes[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      size: 52,
                      color: AppColors.sitioPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: const Tr(
            'Desliza para ver las demás fotografías',
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

