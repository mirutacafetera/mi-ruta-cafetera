import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/sitio/sitio_contenido_model.dart';
import '../../theme/app_colors.dart';
import 'audio_guia_borrador.dart';

class SeccionAudioguias extends StatefulWidget {
  final List<AudioGuiaBorrador> audiosNuevos;
  final List<SitioAudioGuiaModel> audiosExistentes;
  final Set<String> audiosAEliminar;
  final bool deshabilitado;

  final ValueChanged<List<AudioGuiaBorrador>> onAudiosNuevosChanged;
  final ValueChanged<Set<String>> onAudiosAEliminarChanged;

  const SeccionAudioguias({
    super.key,
    required this.audiosNuevos,
    required this.audiosExistentes,
    required this.audiosAEliminar,
    required this.deshabilitado,
    required this.onAudiosNuevosChanged,
    required this.onAudiosAEliminarChanged,
  });

  @override
  State<SeccionAudioguias> createState() =>
      _SeccionAudioguiasState();
}

class _SeccionAudioguiasState extends State<SeccionAudioguias> {
  final AudioPlayer _player = AudioPlayer();
  String? _audioActual;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _seleccionarAudio() async {
    try {
      final archivos = await FilePicker.pickFiles(
        type: FileType.audio,
      );

      if (archivos.isEmpty) return;

      final archivo = archivos.first;

      const extensionesPermitidas = {
        'mp3', 'wav', 'm4a', 'aac',
        'ogg', 'oga', 'opus', 'webm',
      };

      if (!extensionesPermitidas.contains(
        archivo.extension?.toLowerCase(),
      )) {
        _mensaje('Formato de audio no admitido.');
        return;
      }

      final audios = List<AudioGuiaBorrador>.from(
        widget.audiosNuevos,
      );

      audios.add(
        AudioGuiaBorrador(
          archivo: archivo,
          titulo: archivo.name.replaceFirst(
            RegExp(r'\.[^.]+$'),
            '',
          ),
          descripcion: '',
        ),
      );

      widget.onAudiosNuevosChanged(audios);
    } catch (_) {
      _mensaje('No fue posible seleccionar el audio.');
    }
  }

  void _actualizarAudio(
    int index, {
    String? titulo,
    String? descripcion,
  }) {
    final audios = List<AudioGuiaBorrador>.from(
      widget.audiosNuevos,
    );

    audios[index] = audios[index].copyWith(
      titulo: titulo,
      descripcion: descripcion,
    );

    widget.onAudiosNuevosChanged(audios);
  }

  void _eliminarAudioNuevo(int index) {
    final audios = List<AudioGuiaBorrador>.from(
      widget.audiosNuevos,
    );

    audios.removeAt(index);
    widget.onAudiosNuevosChanged(audios);
  }

  Future<void> _reproducir(SitioAudioGuiaModel audio) async {
    try {
      if (_audioActual == audio.id && _player.playing) {
        await _player.pause();
        return;
      }

      setState(() => _audioActual = audio.id);

      await _player.setUrl(audio.url);
      await _player.play();
    } catch (_) {
      _mensaje('No fue posible reproducir esta audioguía.');
    }
  }

  void _marcarParaEliminar(String id) {
    final eliminados = Set<String>.from(
      widget.audiosAEliminar,
    );

    if (!eliminados.add(id)) {
      eliminados.remove(id);
    }

    widget.onAudiosAEliminarChanged(eliminados);
  }

  void _mensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audiosVisibles = widget.audiosExistentes
        .where(
          (audio) => !widget.audiosAEliminar.contains(audio.id),
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.headphones_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Audioguías',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Agregar audioguía',
                onPressed: widget.deshabilitado
                    ? null
                    : _seleccionarAudio,
                icon: const Icon(Icons.add_circle),
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Agrega relatos de audio para enriquecer '
            'la experiencia del visitante.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          if (audiosVisibles.isEmpty && widget.audiosNuevos.isEmpty)
            _estadoVacio(),

          ...audiosVisibles.map(_tarjetaExistente),

          ...widget.audiosNuevos.indexed.map(
            (entrada) => _tarjetaNueva(
              entrada.$1,
              entrada.$2,
            ),
          ),

          if (!widget.deshabilitado) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _seleccionarAudio,
              icon: const Icon(Icons.audio_file_outlined),
              label: const Text('Agregar archivo de audio'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                minimumSize: const Size(double.infinity, 46),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _estadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.graphic_eq_rounded,
            size: 34,
            color: AppColors.primary.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 8),
          const Text('Todavía no hay audioguías'),
          const SizedBox(height: 4),
          Text(
            'Puedes agregar una para este contenido.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaNueva(
    int index,
    AudioGuiaBorrador audio,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.audio_file,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  audio.archivo.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Quitar audio',
                onPressed: widget.deshabilitado
                    ? null
                    : () => _eliminarAudioNuevo(index),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey('titulo_audio_$index'),
            initialValue: audio.titulo,
            enabled: !widget.deshabilitado,
            decoration: const InputDecoration(
              labelText: 'Título de la audioguía',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (valor) => _actualizarAudio(
              index,
              titulo: valor,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: ValueKey('descripcion_audio_$index'),
            initialValue: audio.descripcion,
            enabled: !widget.deshabilitado,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (valor) => _actualizarAudio(
              index,
              descripcion: valor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaExistente(SitioAudioGuiaModel audio) {
    final reproduciendo =
        _audioActual == audio.id && _player.playing;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: IconButton(
          tooltip: reproduciendo ? 'Pausar' : 'Reproducir',
          onPressed: () => _reproducir(audio),
          icon: Icon(
            reproduciendo
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            size: 34,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          audio.titulo,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: audio.descripcion.isEmpty
            ? null
            : Text(
                audio.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: widget.deshabilitado
            ? null
            : IconButton(
                tooltip: 'Marcar para eliminar',
                onPressed: () => _marcarParaEliminar(audio.id),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
      ),
    );
  }
}