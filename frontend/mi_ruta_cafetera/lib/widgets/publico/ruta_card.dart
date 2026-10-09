import 'package:flutter/material.dart';

import '../../models/ruta_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class RutaCard extends StatefulWidget {
  final RutaModel ruta;
  final VoidCallback onTap;

  const RutaCard({
    super.key,
    required this.ruta,
    required this.onTap,
  });

  @override
  State<RutaCard> createState() => _RutaCardState();
}

class _RutaCardState extends State<RutaCard> {
  bool _presionando = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _presionando = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _presionando = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _presionando = false;
        });

        widget.onTap();
      },
      child: AnimatedScale(
        scale: _presionando ? 0.97 : 1.0,
        duration: const Duration(
          milliseconds: AppDimensions.animationFast,
        ),
        curve: Curves.easeOut,
        child: Container(
          height: AppDimensions.rutaCardHeight,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppDimensions.rutaCardRadius,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              _construirIcono(),
              Expanded(
                child: _construirContenido(),
              ),
              _construirFlecha(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirIcono() {
    return Container(
      width: AppDimensions.rutaIconContainer,
      height: AppDimensions.rutaIconContainer,
      margin: const EdgeInsets.only(
        left: AppDimensions.spacingMd,
        right: AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.nature,
          ],
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
      ),
      child: const Icon(
        Icons.route_rounded,
        size: AppDimensions.iconLg,
        color: AppColors.textOnDark,
      ),
    );
  }

  Widget _construirContenido() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingMd,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.ruta.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(
            height: AppDimensions.spacingXs,
          ),
          Text(
            _textoRuta(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.25,
                ),
          ),
          const SizedBox(
            height: AppDimensions.spacingSm,
          ),
          _construirInformacion(),
        ],
      ),
    );
  }

  Widget _construirInformacion() {
    final cantidadSitios = widget.ruta.sitios.length;
    final distancia = widget.ruta.distanciaKm;

    return Row(
      children: [
        _construirDato(
          icono: Icons.place_outlined,
          texto:
              '$cantidadSitios ${cantidadSitios == 1 ? 'lugar' : 'lugares'}',
        ),
        if (distancia > 0) ...[
          const SizedBox(
            width: AppDimensions.spacingMd,
          ),
          _construirDato(
            icono: Icons.straighten_rounded,
            texto: '${distancia.toStringAsFixed(1)} km',
          ),
        ],
      ],
    );
  }

  Widget _construirDato({
    required IconData icono,
    required String texto,
  }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: AppDimensions.iconSm,
            color: AppColors.primary,
          ),
          const SizedBox(
            width: AppDimensions.spacingXs,
          ),
          Flexible(
            child: Text(
              texto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirFlecha() {
    return Container(
      width: AppDimensions.circularButtonSmall,
      height: AppDimensions.circularButtonSmall,
      margin: const EdgeInsets.only(
        right: AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.getSoftColorForCategory(
          'naturaleza',
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        size: AppDimensions.iconMd,
        color: AppColors.primary,
      ),
    );
  }

  String _textoRuta() {
    final cantidadSitios = widget.ruta.sitios.length;

    if (cantidadSitios == 0) {
      return 'Ruta turística del Huila';
    }

    return 'Una experiencia para descubrir '
        '$cantidadSitios '
        '${cantidadSitios == 1 ? 'lugar' : 'lugares'} '
        'del Huila.';
  }
}