import 'package:flutter/material.dart';

class GaleriaImagenes {
  static void mostrar(
    BuildContext context,
    List<String> imagenes,
    int inicial,
  ) {
    if (imagenes.isEmpty) return;

    final pagina = inicial.clamp(0, imagenes.length - 1);
    final controlador = PageController(initialPage: pagina);
    var actual = pagina;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, actualizar) {
          final tamano = MediaQuery.of(ctx).size;

          return Dialog.fullscreen(
            backgroundColor: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: controlador,
                  itemCount: imagenes.length,
                  onPageChanged: (indice) {
                    actualizar(() {
                      actual = indice;
                    });
                  },
                  itemBuilder: (_, indice) {
                    return InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4,
                      child: SizedBox(
                        width: tamano.width,
                        height: tamano.height,
                        child: Image.network(
                          imagenes[indice],
                          fit: BoxFit.contain,
                          errorBuilder: (_, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: MediaQuery.of(ctx).padding.top + 8,
                  right: 12,
                  child: IconButton(
                    tooltip: 'Cerrar galería',
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (actual > 0)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        tooltip: 'Imagen anterior',
                        onPressed: () {
                          controlador.previousPage(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                if (actual < imagenes.length - 1)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        tooltip: 'Imagen siguiente',
                        onPressed: () {
                          controlador.nextPage(
                            duration: const Duration(
                              milliseconds: 250,
                            ),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 42,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: MediaQuery.of(ctx).padding.bottom + 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Imagen ${actual + 1} de ${imagenes.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      controlador.dispose();
    });
  }
}