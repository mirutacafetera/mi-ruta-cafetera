import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../l10n/textos.dart';

class MapaControles extends StatelessWidget {
  /// Centra el mapa en la posición GPS real del usuario.
  final VoidCallback onCentrar;

  /// Restablece la vista del corredor Garzón–Gigante.
  final VoidCallback onMostrarTodos;

  const MapaControles({
    super.key,
    required this.onCentrar,
    required this.onMostrarTodos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _boton(
          icono: Icons.my_location,
          tooltip: Textos.t('Mi ubicación'),
          onPressed: onCentrar,
        ),

        const SizedBox(
          height: AppDimensions.spacingSm,
        ),

        _boton(
          icono: Icons.map_outlined,
          tooltip: Textos.t('Ver corredor Garzón–Gigante'),
          onPressed: onMostrarTodos,
        ),
      ],
    );
  }

  Widget _boton({
    required IconData icono,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: AppColors.white,
      elevation: AppDimensions.elevationFloating,
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(
          icono,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
