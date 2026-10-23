
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
  int _operacionAudio = 0;

  AudioGuiaModel? get audioActual => _audioActual;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> reproducirContenido(ContenidoModel contenido) async {
    final audios = contenido.audioGuias
        .where((audio) => audio.url.trim().isNotEmpty)
        .toList();

    if (audios.isEmpty) {
      throw Exception(
        'Este contenido no tiene una audioguía disponible.',
      );
    }

    await reproducirAudio(audios.first);
  }

  Future<void> reproducirAudio(AudioGuiaModel audio) async {
    if (_cerrado) return;

    final url = audio.url.trim();

    if (url.isEmpty) return;

    final mismoAudio =
        _audioActual?.url.trim() == url &&
        player.audioSource != null;

    if (mismoAudio && !_cargando) {
      try {
        if (player.playing) {
          ++_operacionAudio;
          await player.pause();
        } else {
          if (player.processingState == ProcessingState.completed) {
            await player.seek(Duration.zero);
          }

          await player.play();
        }
      } catch (e) {
        if (_cerrado) return;

        _error = Textos.t('No fue posible controlar esta audioguía.');
        _notificar();

        debugPrint('Error al controlar audioguía: $e');
      }

      return;
    }

    final operacion = ++_operacionAudio;

    _audioActual = audio;
    _cargando = true;
    _error = null;
    _notificar();

    try {
      await player.stop();

      if (_cerrado || operacion != _operacionAudio) return;

      await player.setUrl(url);

      if (_cerrado || operacion != _operacionAudio) return;

      _cargando = false;
      _notificar();

      if (_cerrado || operacion != _operacionAudio) return;

      await player.play();
    } catch (e) {
      if (_cerrado || operacion != _operacionAudio) return;

      _cargando = false;
      _error = Textos.t('No fue posible cargar esta audioguía.');
      _notificar();

      debugPrint('Error al reproducir audioguía: $e');
    }
  }

  Future<void> alternarReproduccion() async {
    if (_cerrado || _cargando) return;

    try {
      if (player.playing) {
        // Invalida operaciones pendientes antes de pausar.
        ++_operacionAudio;
        await player.pause();
        return;
      }

      if (player.audioSource == null) return;

      if (player.processingState == ProcessingState.completed) {
        await player.seek(Duration.zero);
      }

      await player.play();
    } catch (e) {
      if (_cerrado) return;

      _error = Textos.t('No fue posible controlar esta audioguía.');
      _notificar();

      debugPrint('Error al controlar audioguía: $e');
    }
  }

  Future<void> cerrar() async {
    // Invalida las operaciones pendientes.
    ++_operacionAudio;

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
    ++_operacionAudio;
    player.dispose();
    super.dispose();
  }
}
