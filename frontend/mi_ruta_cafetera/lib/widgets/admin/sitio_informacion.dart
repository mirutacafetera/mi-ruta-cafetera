import 'package:flutter/material.dart';

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

  static const Color verdePrincipal = Color(0xFF31572C);
  static const Color cafe = Color(0xFF795548);
  static const Color grisBorde = Color(0xFFE1E1E1);

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
            padding: const EdgeInsets.only(bottom: 14),
            child: DropdownButtonFormField<String>(
              initialValue: categoriaSeleccionada,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Categoría',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.category_rounded,
                  color: cafe,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: grisBorde,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: grisBorde,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: verdePrincipal,
                    width: 2,
                  ),
                ),
              ),
              items: categorias.map((categoria) {
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
              }).whereType<DropdownMenuItem<String>>().toList(),
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
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: verdePrincipal,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Separa las etiquetas con comas. Ejemplo: café, naturaleza, aventura.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B6B6B),
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