import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class EncabezadoPerfilSitio extends StatelessWidget {
  final bool editando;
  final VoidCallback onEditar;

  const EncabezadoPerfilSitio({
    super.key,
    required this.editando,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppDimensions.sitioPanelCardPadding,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.sitioPrimary,
            AppColors.sitioPrimaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.sitioCardShadow,
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 18,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppColors.sitioTextOnPrimary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Text(
                      'GESTIÓN DE TU EXPERIENCIA',
                      style: TextStyle(
                        color: AppColors.sitioTextOnPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  if (editando)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sitioAccent,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.sitioStatusRadius,
                        ),
                      ),
                      child: const Text(
                        'EDITANDO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Mi sitio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.sitioTextOnPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 28,
                      height: 1.15,
                    ),
              ),
              const SizedBox(height: 9),
              Text(
                'Administra la información que los visitantes encontrarán sobre tu experiencia.',
                style: const TextStyle(
                  color: Color(0xFFE6EDE7),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              if (!editando)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onEditar,
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 18,
                    ),
                    label: const Text('Editar información'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sitioAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(
                        0,
                        AppDimensions.sitioButtonHeight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.sitioFormRadius,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFFE6EDE7),
                      size: 18,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Modifica los campos y guarda tus cambios.',
                        style: const TextStyle(
                          color: Color(0xFFE6EDE7),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}