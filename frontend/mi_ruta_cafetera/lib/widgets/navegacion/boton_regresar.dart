import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class BotonRegresar extends StatelessWidget {
  const BotonRegresar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Regresar',
      icon: const Icon(
        Icons.arrow_back,
        color: AppColors.textPrimary,
      ),
      onPressed: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
