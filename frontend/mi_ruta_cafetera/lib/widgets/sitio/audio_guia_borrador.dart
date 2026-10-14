import 'package:file_picker/file_picker.dart';

class AudioGuiaBorrador {
  final PlatformFile archivo;
  final String titulo;
  final String descripcion;

  const AudioGuiaBorrador({
    required this.archivo,
    required this.titulo,
    required this.descripcion,
  });

  AudioGuiaBorrador copyWith({
    String? titulo,
    String? descripcion,
  }) {
    return AudioGuiaBorrador(
      archivo: archivo,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}