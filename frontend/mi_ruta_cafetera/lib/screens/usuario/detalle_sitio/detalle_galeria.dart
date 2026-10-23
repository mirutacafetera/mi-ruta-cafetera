
import 'package:flutter/material.dart';

import '../../../../theme/app_dimensions.dart';
import '../../../l10n/textos.dart';

class DetalleGaleria extends StatelessWidget {
  final List<String> imagenes;
  final bool cargando;

  const DetalleGaleria({
    super.key,
    required this.imagenes,
    this.cargando = false,
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
        padding: EdgeInsets.all(28),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF214F3D),
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
        vertical: 22,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0E9),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Color(0xFF214F3D),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tr(
                      'Galería de imágenes',
                      style: TextStyle(
                        color: Color(0xFF292D29),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Tr(
                      'Conoce cada rincón de este lugar.',
                      style: TextStyle(
                        color: Color(0xFF6C746D),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 142,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fotos.length > 5 ? 5 : fotos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
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
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _mostrarGaleriaCompleta(
                context,
                fotos,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF214F3D),
                side: const BorderSide(
                  color: Color(0xFF214F3D),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
      color: const Color(0xFFE8F0E9),
      borderRadius: BorderRadius.circular(15),
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
                  color: Color(0xFF214F3D),
                  size: 34,
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 18,
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
      backgroundColor: const Color(0xFFF5F0E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF214F3D),
        foregroundColor: Colors.white,
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
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: widget.imagenes.length,
      itemBuilder: (context, index) {
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
                  color: Color(0xFF214F3D),
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
                      color: Color(0xFF214F3D),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Tr(
            'Desliza para ver las demás fotografías',
            style: const TextStyle(
              color: Color(0xFF6C746D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
