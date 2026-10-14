
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

class EstadoCategoria extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  final bool cargando;
  final bool error;

  const EstadoCategoria({
    super.key,
    required this.mensaje,
    this.icono = Icons.category_outlined,
    this.cargando = false,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXxl),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    final color =
        error ? AppColors.error : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 26, color: color),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
