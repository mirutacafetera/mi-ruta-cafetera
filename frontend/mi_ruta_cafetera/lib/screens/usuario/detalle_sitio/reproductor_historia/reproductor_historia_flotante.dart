
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';

class ReproductorHistoriaFlotante extends StatelessWidget {
  const ReproductorHistoriaFlotante({
    super.key,
    required this.player,
    required this.titulo,
    required this.cargando,
    required this.error,
    required this.onCerrar,
  });

  final AudioPlayer player;
  final String titulo;
  final bool cargando;
  final String? error;
  final VoidCallback onCerrar;

  String _formatear(Duration duracion) {
    final minutos = duracion.inMinutes;
    final segundos = duracion.inSeconds.remainder(60);
    return '$minutos:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusLg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.headphones,
                  color: AppColors.primary,
                ),
                const SizedBox(
                  width: AppDimensions.spacingSm,
                ),
                Expanded(
                  child: Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar reproductor',
                  onPressed: onCerrar,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (cargando)
              const LinearProgressIndicator()
            else if (error != null)
              Text(
                error!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.error),
              )
            else
              StreamBuilder<Duration?>(
                stream: player.durationStream,
                builder: (context, duracionSnapshot) {
                  final duracion =
                      duracionSnapshot.data ?? Duration.zero;

                  return StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, posicionSnapshot) {
                      final posicion =
                          posicionSnapshot.data ?? Duration.zero;

                      final maximo =
                          duracion.inMilliseconds.toDouble();

                      final valor = maximo > 0
                          ? posicion.inMilliseconds
                              .toDouble()
                              .clamp(0.0, maximo)
                          : 0.0;

                      return Column(
                        children: [
                          Slider(
                            value: valor,
                            max: maximo > 0 ? maximo : 1,
                            activeColor: AppColors.primary,
                            onChanged: maximo <= 0
                                ? null
                                : (nuevoValor) {
                                    player.seek(
                                      Duration(
                                        milliseconds:
                                            nuevoValor.round(),
                                      ),
                                    );
                                  },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spacingSm,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatear(posicion)),
                                Text(_formatear(duracion)),
                              ],
                            ),
                          ),
                          StreamBuilder<PlayerState>(
                            stream: player.playerStateStream,
                            builder: (context, snapshot) {
                              final estado = snapshot.data;
                              final reproduciendo =
                                  estado?.playing ?? false;
                              final terminado =
                                  estado?.processingState ==
                                      ProcessingState.completed;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: 'Retroceder 10 segundos',
                                    onPressed: () {
                                      final destino = posicion -
                                          const Duration(seconds: 10);

                                      player.seek(
                                        destino < Duration.zero
                                            ? Duration.zero
                                            : destino,
                                      );
                                    },
                                    icon: const Icon(Icons.replay_10),
                                  ),
                                  IconButton.filled(
                                    tooltip: reproduciendo
                                        ? 'Pausar'
                                        : 'Reproducir',
                                    onPressed: () {
                                      if (terminado) {
                                        player.seek(Duration.zero);
                                        player.play();
                                      } else if (reproduciendo) {
                                        player.pause();
                                      } else {
                                        player.play();
                                      }
                                    },
                                    icon: Icon(
                                      reproduciendo
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Avanzar 10 segundos',
                                    onPressed: () {
                                      final destino = posicion +
                                          const Duration(seconds: 10);

                                      player.seek(
                                        destino > duracion
                                            ? duracion
                                            : destino,
                                      );
                                    },
                                    icon: const Icon(Icons.forward_10),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
