import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import 'sitio_form_field.dart';
import 'sitio_section_card.dart';
import 'sitio_section_title.dart';

class SitioInformacion extends StatelessWidget {
  final TextEditingController nombreController;
  final TextEditingController descripcionController;
  final TextEditingController etiquetasController;

  final List<Map<String, dynamic>> categorias;
  final String? categoriaSeleccionada;
  final ValueChanged<String?> onCategoriaChanged;

  const SitioInformacion({
    super.key,
    required this.nombreController,
    required this.descripcionController,
    required this.etiquetasController,
    required this.categorias,
    required this.categoriaSeleccionada,
    required this.onCategoriaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SitioSectionCard(
      child: Column(
        children: [
          const SitioSectionTitle(
            icono: Icons.place_outlined,
            titulo: 'Información del sitio',
            subtitulo: 'Datos principales del lugar turístico',
          ),

          SitioFormField(
            controller: nombreController,
            label: 'Nombre del sitio',
            icon: Icons.place_rounded,
            obligatorio: true,
          ),

          SitioFormField(
            controller: descripcionController,
            label: 'Descripción',
            icon: Icons.description_rounded,
            maxLines: 4,
            obligatorio: true,
          ),

          Padding(
            padding: const EdgeInsets.only(
              bottom: AppDimensions.spacingMd + 2,
            ),
            child: DropdownButtonFormField<String>(
              initialValue: categoriaSeleccionada,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Categoría',
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(
                  Icons.category_rounded,
                  color: AppColors.secondary,
                  size: AppDimensions.iconMd,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingLg,
                  vertical: AppDimensions.spacingLg,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd,
                  ),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              items: categorias
                  .map((categoria) {
                    final id = categoria['_id']?.toString();
                    final nombre =
                        categoria['nombre']?.toString() ?? 'Sin nombre';

                    if (id == null || id.isEmpty) {
                      return null;
                    }

                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(
                        nombre,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
              onChanged: onCategoriaChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selecciona una categoría';
                }

                return null;
              },
            ),
          ),

          SitioFormField(
            controller: etiquetasController,
            label: 'Etiquetas',
            icon: Icons.local_offer_rounded,
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusSm,
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppDimensions.iconSm,
                  color: AppColors.primary,
                ),
                SizedBox(
                  width: AppDimensions.spacingSm,
                ),
                Expanded(
                  child: Text(
                    'Separa las etiquetas con comas. Ejemplo: café, naturaleza, aventura.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}