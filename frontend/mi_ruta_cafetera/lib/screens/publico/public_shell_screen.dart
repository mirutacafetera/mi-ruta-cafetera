import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

import '../mapa_screen_2.dart';

import 'home_publico_screen.dart';
import 'perfil_publico_screen.dart';

class PublicShellScreen extends StatefulWidget {
  final int initialIndex;

  const PublicShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<PublicShellScreen> createState() => _PublicShellScreenState();
}

class _PublicShellScreenState extends State<PublicShellScreen> {
  late int _indiceActual;

  @override
  void initState() {
    super.initState();

    _indiceActual = widget.initialIndex.clamp(
      0,
      2,
    );
  }

  void _cambiarSeccion(int indice) {
    if (_indiceActual == indice) {
      return;
    }

    setState(() {
      _indiceActual = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ==========================================================
      // CONTENIDO PÚBLICO
      // ==========================================================
      body: IndexedStack(
        index: _indiceActual,
        children: const [
          HomePublicoScreen(),
          MapaScreen2(),
          PerfilPublicoScreen(),
        ],
      ),

      // ==========================================================
      // NAVEGACIÓN INFERIOR
      // ==========================================================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AppDimensions.pageHorizontalSmall,
            0,
            AppDimensions.pageHorizontalSmall,
            AppDimensions.navigationBarBottomMargin,
          ),
          height: AppDimensions.navigationBarHeight,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(
              AppDimensions.bottomNavigationRadius,
            ),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 16,
                offset: Offset(
                  0,
                  6,
                ),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _ItemNavegacion(
                  icono: Icons.home_rounded,
                  etiqueta: 'Inicio',
                  seleccionado: _indiceActual == 0,
                  onTap: () {
                    _cambiarSeccion(0);
                  },
                ),
              ),
              Expanded(
                child: _ItemNavegacion(
                  icono: Icons.map_rounded,
                  etiqueta: 'Mapa',
                  seleccionado: _indiceActual == 1,
                  onTap: () {
                    _cambiarSeccion(1);
                  },
                ),
              ),
              Expanded(
                child: _ItemNavegacion(
                  icono: Icons.person_rounded,
                  etiqueta: 'Perfil',
                  seleccionado: _indiceActual == 2,
                  onTap: () {
                    _cambiarSeccion(2);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNavegacion extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ItemNavegacion({
    required this.icono,
    required this.etiqueta,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = seleccionado
        ? AppColors.primary
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppDimensions.bottomNavigationRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingSm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(
                  milliseconds: AppDimensions.animationFast,
                ),
                width: AppDimensions.categoryIconContainer,
                height: AppDimensions.categoryIconContainer,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? AppColors.getSoftColorForCategory(
                          'naturaleza',
                        )
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLg,
                  ),
                ),
                child: Icon(
                  icono,
                  size: AppDimensions.navigationIcon,
                  color: color,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXs,
              ),
              Text(
                etiqueta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: seleccionado
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}