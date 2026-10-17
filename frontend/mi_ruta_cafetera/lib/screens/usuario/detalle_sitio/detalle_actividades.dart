
import 'package:flutter/material.dart';

import '../../../../models/sitio/sitio_actividad_model.dart';
import '../../../../theme/app_dimensions.dart';

class DetalleActividades extends StatelessWidget {
  final List<SitioActividadModel> actividades;
  final bool cargando;
  final ValueChanged<SitioActividadModel> onSeleccionar;

  const DetalleActividades({
    super.key,
    required this.actividades,
    this.cargando = false,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final visibles = actividades.where((a) => a.activo).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pageHorizontal,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0E9),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.coffee_rounded,
                    color: Color(0xFF214F3D),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actividades para disfrutar',
                        style: TextStyle(
                          color: Color(0xFF292D29),
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Explora las experiencias de este lugar.',
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
          ),
          const SizedBox(height: 16),
          if (cargando)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF214F3D),
                ),
              ),
            )
          else if (visibles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pageHorizontal,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFDED5C8),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.local_activity_outlined,
                      size: 38,
                      color: Color(0xFF98651E),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Próximamente nuevas experiencias',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF292D29),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Estamos preparando actividades para tu visita.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6C746D),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 258,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontal,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: visibles.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final actividad = visibles[index];
                  final imagen = actividad.imagenPrincipal.trim();

                  return SizedBox(
                    width: 230,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(19),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => onSeleccionar(actividad),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFDED5C8),
                            ),
                            borderRadius: BorderRadius.circular(19),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (imagen.isNotEmpty)
                                      Image.network(
                                        imagen,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _imagenAlternativa(),
                                      )
                                    else
                                      _imagenAlternativa(),
                                    if (actividad.imagenes.isNotEmpty)
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.65,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.photo_library_outlined,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                '${_imagenesActividad(actividad).length}',
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
                                padding: const EdgeInsets.all(13),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      actividad.nombre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF292D29),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      actividad.descripcion.trim().isEmpty
                                          ? 'Descubre esta experiencia.'
                                          : actividad.descripcion.trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF6C746D),
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Row(
                                      children: [
                                        Text(
                                          'Ver experiencia',
                                          style: TextStyle(
                                            color: Color(0xFF214F3D),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 15,
                                          color: Color(0xFF214F3D),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  List<String> _imagenesActividad(SitioActividadModel actividad) {
    final principal = actividad.imagenPrincipal.trim();
    final urls = <String>[];

    if (principal.isNotEmpty) {
      urls.add(principal);
    }

    for (final imagen in actividad.imagenes) {
      final url = imagen.trim();
      if (url.isNotEmpty && !urls.contains(url)) {
        urls.add(url);
      }
    }

    return urls;
  }

  Widget _imagenAlternativa() {
    return Container(
      color: const Color(0xFFE8F0E9),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_cafe_rounded,
        size: 44,
        color: Color(0xFF214F3D),
      ),
    );
  }
}
