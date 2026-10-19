
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/sitio/sitio_contenido_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
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
  State<SeccionAudioguias> createState() => _SeccionAudioguiasState();
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
    if (widget.deshabilitado) return;

    try {
      final archivos = await FilePicker.pickFiles(
        type: FileType.audio,
      );

      if (!mounted || archivos.isEmpty) return;

      final archivo = archivos.first;

      const extensionesPermitidas = {
        'mp3',
        'wav',
        'm4a',
        'aac',
        'ogg',
        'oga',
        'opus',
        'webm',
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
    if (widget.deshabilitado) return;

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
        if (mounted) setState(() {});
        return;
      }

      setState(() => _audioActual = audio.id);

      await _player.setUrl(audio.url);
      await _player.play();

      if (mounted) setState(() {});
    } catch (_) {
      _mensaje('No fue posible reproducir esta audioguía.');
    }
  }

  void _marcarParaEliminar(String id) {
    if (widget.deshabilitado) return;

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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          backgroundColor: AppColors.sitioPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
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
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: AppColors.sitioPrimary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audioguías',
                      style: TextStyle(
                        color: AppColors.sitioTextPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Historias para escuchar',
                      style: TextStyle(
                        color: AppColors.sitioTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Agregar audioguía',
                onPressed: widget.deshabilitado
                    ? null
                    : _seleccionarAudio,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.sitioPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.sitioDivider,
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Añade relatos y explicaciones de audio para enriquecer '
            'la experiencia de quienes visiten tu sitio.',
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
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
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _seleccionarAudio,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sitioPrimary,
                  side: const BorderSide(
                    color: AppColors.sitioBorder,
                  ),
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                icon: const Icon(
                  Icons.audio_file_outlined,
                  size: 19,
                ),
                label: const Text('Agregar archivo de audio'),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.graphic_eq_rounded,
            size: 36,
            color: AppColors.sitioPrimary,
          ),
          SizedBox(height: 10),
          Text(
            'Todavía no hay audioguías',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.sitioTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Agrega una narración para acompañar este contenido.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.sitioTextSecondary,
              fontSize: 12,
              height: 1.4,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceSoft,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.sitioSurfaceGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.audio_file_rounded,
                  color: AppColors.sitioPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Audio nuevo',
                        style: TextStyle(
                          color: AppColors.sitioPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        audio.archivo.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.sitioTextPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Quitar audio',
                onPressed: widget.deshabilitado
                    ? null
                    : () => _eliminarAudioNuevo(index),
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.sitioError,
                ),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _campoAudio(
            key: ValueKey('titulo_audio_$index'),
            valorInicial: audio.titulo,
            etiqueta: 'Título de la audioguía',
            pista: 'Ej. Historia de la finca',
            icono: Icons.title_rounded,
            onChanged: (valor) => _actualizarAudio(
              index,
              titulo: valor,
            ),
          ),
          const SizedBox(height: 12),
          _campoAudio(
            key: ValueKey('descripcion_audio_$index'),
            valorInicial: audio.descripcion,
            etiqueta: 'Descripción (opcional)',
            pista: '¿Qué escuchará el visitante?',
            icono: Icons.notes_rounded,
            maxLines: 2,
            onChanged: (valor) => _actualizarAudio(
              index,
              descripcion: valor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoAudio({
    required Key key,
    required String valorInicial,
    required String etiqueta,
    required String pista,
    required IconData icono,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      key: key,
      initialValue: valorInicial,
      enabled: !widget.deshabilitado,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.sitioTextPrimary,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: pista,
        prefixIcon: maxLines == 1
            ? Icon(
                icono,
                color: AppColors.sitioPrimary,
                size: 19,
              )
            : null,
        filled: true,
        fillColor: AppColors.sitioSurface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          color: AppColors.sitioTextSecondary,
          fontSize: 12,
        ),
        hintStyle: const TextStyle(
          color: AppColors.sitioTextSecondary,
          fontSize: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.sitioBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.sitioPrimary,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.sitioDivider,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _tarjetaExistente(SitioAudioGuiaModel audio) {
    final reproduciendo = _audioActual == audio.id && _player.playing;
    final marcada = widget.audiosAEliminar.contains(audio.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: reproduciendo
                  ? AppColors.sitioPrimary
                  : AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: IconButton(
              tooltip: reproduciendo ? 'Pausar' : 'Reproducir',
              onPressed: widget.deshabilitado
                  ? null
                  : () => _reproducir(audio),
              padding: EdgeInsets.zero,
              icon: Icon(
                reproduciendo
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 25,
                color: reproduciendo
                    ? Colors.white
                    : AppColors.sitioPrimary,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.sitioTextPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (audio.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    audio.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.sitioTextSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
                if (reproduciendo) ...[
                  const SizedBox(height: 7),
                  const Row(
                    children: [
                      Icon(
                        Icons.volume_up_rounded,
                        size: 14,
                        color: AppColors.sitioSuccess,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Reproduciendo',
                        style: TextStyle(
                          color: AppColors.sitioSuccess,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
                if (marcada) ...[
                  const SizedBox(height: 7),
                  const Text(
                    'Se eliminará al guardar',
                    style: TextStyle(
                      color: AppColors.sitioError,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!widget.deshabilitado)
            IconButton(
              tooltip: marcada ? 'Restaurar audioguía' : 'Marcar para eliminar',
              onPressed: () => _marcarParaEliminar(audio.id),
              style: IconButton.styleFrom(
                foregroundColor: marcada
                    ? AppColors.sitioSuccess
                    : AppColors.sitioError,
              ),
              icon: Icon(
                marcada
                    ? Icons.undo_rounded
                    : Icons.delete_outline_rounded,
              ),
            ),
        ],
      ),
    );
  }
}
