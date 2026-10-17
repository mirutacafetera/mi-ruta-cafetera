
import 'package:flutter/material.dart';

import '../../models/contenido_model.dart';
import '../../theme/app_dimensions.dart';

class SeccionContenidoSitio extends StatelessWidget {
  const SeccionContenidoSitio({
    super.key,
    required this.contenidos,
    this.onReproducirAudioguia,
  });

  final List<ContenidoModel> contenidos;
  final ValueChanged<ContenidoModel>? onReproducirAudioguia;

  @override
  Widget build(BuildContext context) {
    final visibles = contenidos.where((item) => item.activo).toList();

    if (visibles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...visibles.map(
            (contenido) => _ContenidoCard(
              contenido: contenido,
              onReproducirAudioguia: onReproducirAudioguia,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContenidoCard extends StatelessWidget {
  const _ContenidoCard({
    required this.contenido,
    required this.onReproducirAudioguia,
  });

  final ContenidoModel contenido;
  final ValueChanged<ContenidoModel>? onReproducirAudioguia;

  List<String> get _imagenes {
    final resultado = <String>[];
    final principal = contenido.imagenPrincipal.trim();

    if (principal.isNotEmpty) {
      resultado.add(principal);
    }

    for (final imagen in contenido.imagenes) {
      final url = imagen.trim();

      if (url.isNotEmpty && !resultado.contains(url)) {
        resultado.add(url);
      }
    }

    return resultado;
  }

  bool get _tieneAudio => contenido.audioGuias.any(
        (audio) => audio.url.trim().isNotEmpty,
      );

  @override
  Widget build(BuildContext context) {
    final imagenes = _imagenes;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFDED5C8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _abrirDetalle(context, imagenes),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imagenes.isEmpty
                      ? Container(
                          color: const Color(0xFFE8F0E9),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.auto_stories_rounded,
                            size: 46,
                            color: Color(0xFF214F3D),
                          ),
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              imagenes.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: const Color(0xFFE8F0E9),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                  color: Color(0xFF214F3D),
                                ),
                              ),
                            ),
                            if (imagenes.length > 1)
                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(
                                      alpha: 0.65,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.photo_library_outlined,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${imagenes.length} fotos',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contenido.titulo,
                        style: const TextStyle(
                          color: Color(0xFF292D29),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (contenido.descripcion.trim().isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          contenido.descripcion.trim(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6C746D),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Text(
                            'Leer historia completa',
                            style: TextStyle(
                              color: Color(0xFF214F3D),
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF214F3D),
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_tieneAudio)
            _BotonEscucharHistoria(
              onPressed: onReproducirAudioguia == null
                  ? null
                  : () => onReproducirAudioguia!(contenido),
            ),
        ],
      ),
    );
  }

  void _abrirDetalle(
    BuildContext context,
    List<String> imagenes,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _DetalleContenidoScreen(
          contenido: contenido,
          imagenes: imagenes,
          onReproducirAudioguia: onReproducirAudioguia,
        ),
      ),
    );
  }
}

class _BotonEscucharHistoria extends StatelessWidget {
  const _BotonEscucharHistoria({
    required this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0E9),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.headphones_rounded,
            color: Color(0xFF214F3D),
            size: 25,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Escuchar esta historia',
              style: TextStyle(
                color: Color(0xFF214F3D),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          IconButton.filled(
            tooltip: 'Escuchar historia',
            onPressed: onPressed,
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF214F3D),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.play_arrow_rounded),
          ),
        ],
      ),
    );
  }
}

class _DetalleContenidoScreen extends StatefulWidget {
  const _DetalleContenidoScreen({
    required this.contenido,
    required this.imagenes,
    required this.onReproducirAudioguia,
  });

  final ContenidoModel contenido;
  final List<String> imagenes;
  final ValueChanged<ContenidoModel>? onReproducirAudioguia;

  @override
  State<_DetalleContenidoScreen> createState() =>
      _DetalleContenidoScreenState();
}

class _DetalleContenidoScreenState
    extends State<_DetalleContenidoScreen> {
  final PageController _pageController = PageController();

  int _indice = 0;

  bool get _tieneAudio => widget.contenido.audioGuias.any(
        (audio) => audio.url.trim().isNotEmpty,
      );

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagenes = widget.imagenes;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF214F3D),
        foregroundColor: Colors.white,
        title: const Text('Historia y experiencias'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagenes.isNotEmpty) ...[
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: imagenes.length,
                      onPageChanged: (index) {
                        setState(() => _indice = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          imagenes[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFFE8F0E9),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.broken_image_outlined,
                              size: 44,
                              color: Color(0xFF214F3D),
                            ),
                          ),
                        );
                      },
                    ),
                    if (imagenes.length > 1)
                      Positioned(
                        bottom: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_indice + 1} / ${imagenes.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (imagenes.length > 1)
                SizedBox(
                  height: 76,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: imagenes.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          width: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _indice == index
                                  ? const Color(0xFF214F3D)
                                  : const Color(0xFFDED5C8),
                              width: _indice == index ? 3 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            imagenes[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: Color(0xFFE8F0E9),
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF214F3D),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contenido.titulo,
                    style: const TextStyle(
                      color: Color(0xFF214F3D),
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.contenido.descripcion.trim().isEmpty
                        ? 'No hay una descripción adicional disponible.'
                        : widget.contenido.descripcion.trim(),
                    style: const TextStyle(
                      color: Color(0xFF535B54),
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                  if (_tieneAudio) ...[
                    const SizedBox(height: 24),
                    _BotonEscucharHistoria(
                      onPressed: widget.onReproducirAudioguia == null
                          ? null
                          : () => widget.onReproducirAudioguia!(
                                widget.contenido,
                              ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
