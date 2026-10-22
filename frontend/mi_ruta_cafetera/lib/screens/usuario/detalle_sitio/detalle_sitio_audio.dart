import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../../../models/contenido_model.dart';
import '../../../l10n/textos.dart';

class DetalleSitioAudio extends ChangeNotifier {
  DetalleSitioAudio() : player = AudioPlayer();

  final AudioPlayer player;

  AudioGuiaModel? _audioActual;
  bool _cargando = false;
  String? _error;
  bool _cerrado = false;

  AudioGuiaModel? get audioActual => _audioActual;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> reproducirContenido(ContenidoModel contenido) async {
    final audios = contenido.audioGuias
        .where((audio) => audio.url.trim().isNotEmpty)
        .toList();

    if (audios.isEmpty) {
      throw Exception('Este contenido no tiene una audioguía disponible.');
    }

    await reproducirAudio(audios.first);
  }

  Future<void> reproducirAudio(AudioGuiaModel audio) async {
    if (_cerrado) return;

    final url = audio.url.trim();

    if (url.isEmpty || _cargando) return;

    final mismoAudio =
        _audioActual?.url.trim() == url && player.audioSource != null;

    if (mismoAudio) {
      try {
        if (player.playing) {
          await player.pause();
        } else {
          if (player.processingState == ProcessingState.completed) {
            await player.seek(Duration.zero);
          }

          await player.play();
        }
      } catch (e) {
        _error = Textos.t('No fue posible controlar esta audioguía.');
        _notificar();
      }

      return;
    }

    _audioActual = audio;
    _cargando = true;
    _error = null;
    _notificar();

    try {
      await player.stop();
      await player.setUrl(url);

      if (_cerrado) return;

      _cargando = false;
      _notificar();

      await player.play();
    } catch (e) {
      if (_cerrado) return;

      _cargando = false;
      _error = Textos.t('No fue posible cargar esta audioguía.');
      _notificar();

      debugPrint('Error al reproducir audioguía: $e');
    }
  }

  Future<void> cerrar() async {
    try {
      await player.stop();
    } catch (e) {
      debugPrint('Error al detener la audioguía: $e');
    }

    if (_cerrado) return;

    _audioActual = null;
    _cargando = false;
    _error = null;
    _notificar();
  }

  void _notificar() {
    if (!_cerrado) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _cerrado = true;
    player.dispose();
    super.dispose();
  }
}
