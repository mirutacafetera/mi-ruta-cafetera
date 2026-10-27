
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_dimensions.dart';
import '../../../../l10n/textos.dart';

class ReproductorHistoriaFlotante extends StatelessWidget {
  const ReproductorHistoriaFlotante({
    super.key,
    required this.player,
    required this.titulo,
    required this.cargando,
    required this.error,
    required this.onCerrar,
    required this.onAlternarReproduccion,
  });

  final AudioPlayer player;
  final String titulo;
  final bool cargando;
  final String? error;
  final VoidCallback onCerrar;
  final VoidCallback onAlternarReproduccion;

  String _formatear(Duration duracion) {
    final minutos = duracion.inMinutes;
    final segundos = duracion.inSeconds.remainder(60);
    return '$minutos:${segundos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sitioSurface,
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
                  color: AppColors.sitioPrimary,
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
                          color: AppColors.sitioTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: Textos.t('Cerrar reproductor'),
                  onPressed: onCerrar,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (cargando)
              const LinearProgressIndicator(color: AppColors.sitioPrimary)
            else if (error != null)
              Text(
                error!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.sitioError),
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
                            activeColor: AppColors.sitioPrimary,
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

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    tooltip: Textos.t('Retroceder 10 segundos'),
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
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          AppColors.sitioPrimary,
                                      foregroundColor:
                                          AppColors.sitioTextOnPrimary,
                                    ),
                                    tooltip: reproduciendo
                                        ? Textos.t('Pausar')
                                        : Textos.t('Reproducir'),
                                    onPressed: onAlternarReproduccion,
                                    icon: Icon(
                                      reproduciendo
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: Textos.t('Avanzar 10 segundos'),
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

