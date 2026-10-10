import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class BotonComenzar extends StatefulWidget {
  final VoidCallback onPressed;

  const BotonComenzar({
    super.key,
    required this.onPressed,
  });

  @override
  State<BotonComenzar> createState() => _BotonComenzarState();
}

class _BotonComenzarState extends State<BotonComenzar> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _presionado = true);
      },
      onTapUp: (_) {
        setState(() => _presionado = false);
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _presionado = false);
      },
      child: AnimatedScale(
        scale: _presionado ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusXl,
            ),
            border: Border.all(
              color: AppColors.white.withValues(
                alpha: 0.22,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(
                  alpha: 0.25,
                ),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'Comenzar a explorar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}