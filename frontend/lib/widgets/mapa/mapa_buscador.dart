import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';

class MapaBuscador extends StatelessWidget {
  final TextEditingController controller;
  final List<SitioTuristicoModel> resultados;
  final ValueChanged<String> onChanged;
  final ValueChanged<SitioTuristicoModel> onSeleccionar;
  final VoidCallback onLimpiar;

  const MapaBuscador({
    super.key,
    required this.controller,
    required this.resultados,
    required this.onChanged,
    required this.onSeleccionar,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    final mostrarResultados =
        controller.text.trim().isNotEmpty && resultados.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar sitio turístico...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.brown,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: onLimpiar,
                        icon: const Icon(Icons.close),
                        tooltip: 'Limpiar búsqueda',
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),

          if (mostrarResultados) ...[
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 260,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: resultados.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final sitio = resultados[index];

                  return ListTile(
                    dense: true,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF1E5D6),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: Colors.brown,
                        size: 21,
                      ),
                    ),
                    title: Text(
                      sitio.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: sitio.categoriaNombre.isNotEmpty
                        ? Text(
                            sitio.categoriaNombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () {
                      onSeleccionar(sitio);
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}