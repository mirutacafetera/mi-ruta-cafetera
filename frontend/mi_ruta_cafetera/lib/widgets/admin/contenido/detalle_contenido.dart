import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../models/admin/admin_contenido_model.dart';

class DetalleContenido extends StatelessWidget {
  final AdminContenidoModel contenido;
  final AudioPlayer audio;
  final VoidCallback onVolver;
  final VoidCallback onActualizar;
  final VoidCallback onEditar;
  final VoidCallback onCambiarEstado;
  final VoidCallback onEliminar;
  final VoidCallback onAprobar;
  final VoidCallback onRechazar;
  final Function(List<String>, int) onMostrarGaleria;
  final Function(String) onMensaje;

  const DetalleContenido({
    super.key,
    required this.contenido,
    required this.audio,
    required this.onVolver,
    required this.onActualizar,
    required this.onEditar,
    required this.onCambiarEstado,
    required this.onEliminar,
    required this.onAprobar,
    required this.onRechazar,
    required this.onMostrarGaleria,
    required this.onMensaje,
  });

  @override
  Widget build(BuildContext context) {
    final imagenes = [
      if (contenido.imagenPrincipal.trim().isNotEmpty)
        contenido.imagenPrincipal,
      ...contenido.imagenes.where((url) => url.trim().isNotEmpty),
    ];

    final pendiente =
        contenido.estadoPublicacion == 'pendiente_revision';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              IconButton(
                onPressed: onVolver,
                icon: const Icon(Icons.arrow_back),
              ),
              const Expanded(
                child: Text(
                  'Detalles del contenido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onActualizar,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contenido.titulo.isEmpty
                          ? 'Contenido sin título'
                          : contenido.titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    _dato('Descripción', contenido.descripcion),
                    _dato('Sitio turístico', contenido.sitioNombre),
                    _dato('Ciudad', contenido.ciudad),
                    _dato('Departamento', contenido.departamento),
                    _dato('Estado', contenido.estadoPublicacion),
                    if (contenido.motivoRechazo.isNotEmpty)
                      _dato('Motivo del rechazo', contenido.motivoRechazo),
                    const Divider(height: 28),
                    _tituloSeccion('Imágenes', Icons.photo_library_outlined),
                    const SizedBox(height: 12),
                    if (imagenes.isEmpty)
                      const Text('No hay imágenes disponibles.')
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final ancho = (constraints.maxWidth - 16) / 3;

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              imagenes.length,
                              (i) => GestureDetector(
                                onTap: () => onMostrarGaleria(imagenes, i),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imagenes[i],
                                    width: ancho,
                                    height: ancho,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, error, stackTrace) =>
                                        Container(
                                      width: ancho,
                                      height: ancho,
                                      color: Colors.black12,
                                      child: const Icon(
                                        Icons.broken_image_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    const Divider(height: 28),
                    _tituloSeccion('Audioguías', Icons.headphones_outlined),
                    const SizedBox(height: 12),
                    if (contenido.audioGuias.isEmpty)
                      const Text('No hay audioguías disponibles.')
                    else
                      ...contenido.audioGuias.map(_audioguia),
                    const Divider(height: 28),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: pendiente
                          ? [
                              _boton(
                                'Aprobar',
                                Icons.check_circle_outline,
                                onAprobar,
                                Colors.green,
                              ),
                              _boton(
                                'Rechazar',
                                Icons.cancel_outlined,
                                onRechazar,
                                Colors.red,
                              ),
                            ]
                          : [
                              _boton(
                                'Editar',
                                Icons.edit_outlined,
                                onEditar,
                              ),
                              _boton(
                                contenido.activo ? 'Desactivar' : 'Activar',
                                contenido.activo
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                onCambiarEstado,
                              ),
                              _boton(
                                'Eliminar',
                                Icons.delete_outline,
                                onEliminar,
                                Colors.red,
                              ),
                            ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tituloSeccion(String titulo, IconData icono) {
    return Row(
      children: [
        Icon(icono, size: 21),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(valor.isEmpty ? 'No disponible' : valor),
        ],
      ),
    );
  }

  Widget _audioguia(AdminAudioGuiaModel guia) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            guia.titulo.isEmpty ? 'Audioguía' : guia.titulo,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (guia.descripcion.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(guia.descripcion),
          ],
          if (guia.duracion.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Duración: ${guia.duracion}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                tooltip: 'Reproducir',
                onPressed: guia.url.trim().isEmpty
                    ? null
                    : () async {
                        try {
                          await audio.stop();
                          await audio.setUrl(guia.url.trim());
                          await audio.play();
                        } catch (_) {
                          onMensaje('No se pudo reproducir el audio.');
                        }
                      },
                icon: const Icon(Icons.play_circle_outline),
              ),
              IconButton(
                tooltip: 'Pausar',
                onPressed: () async => audio.pause(),
                icon: const Icon(Icons.pause_circle_outline),
              ),
              IconButton(
                tooltip: 'Detener',
                onPressed: () async => audio.stop(),
                icon: const Icon(Icons.stop_circle_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _boton(
    String texto,
    IconData icono,
    VoidCallback accion, [
    Color? color,
  ]) {
    return OutlinedButton.icon(
      onPressed: accion,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      icon: Icon(icono, size: 19),
      label: Text(texto),
    );
  }
}