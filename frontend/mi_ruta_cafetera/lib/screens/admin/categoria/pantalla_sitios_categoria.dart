import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../models/categoria_model.dart';
import '../../../models/admin/sitio_admin_model.dart';
import '../../../services/admin/sitio/servicio_admin_sitio.dart';

class PantallaSitiosCategoria extends StatefulWidget {
  final CategoriaModel categoria;

  const PantallaSitiosCategoria({
    super.key,
    required this.categoria,
  });

  @override
  State<PantallaSitiosCategoria> createState() =>
      _PantallaSitiosCategoriaState();
}

class _PantallaSitiosCategoriaState
    extends State<PantallaSitiosCategoria> {
  List<SitioAdminModel> sitios = [];
  bool cargando = true;
  String? error;
  String busqueda = '';

  @override
  void initState() {
    super.initState();
    cargarSitios();
  }

  Future<void> cargarSitios() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final todos = await ServicioAdminSitio.obtenerSitios();

      if (!mounted) return;

      setState(() {
        sitios = todos
            .where(
              (sitio) => sitio.categoria?.id == widget.categoria.id,
            )
            .toList();
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'No se pudieron cargar los sitios: $e';
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = sitios.where((sitio) {
      return sitio.nombre.toLowerCase().contains(
            busqueda.trim().toLowerCase(),
          );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.categoria.nombre),
        actions: [
          IconButton(
            onPressed: cargarSitios,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: cargarSitios,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar sitio turístico...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (valor) {
                setState(() {
                  busqueda = valor;
                });
              },
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            if (cargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (error != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      error!,
                      style: const TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                    TextButton(
                      onPressed: cargarSitios,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
            else if (filtrados.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No hay sitios en esta categoría.',
                  ),
                ),
              )
            else
              ...filtrados.map(
                (sitio) => Card(
                  color: AppColors.surface,
                  child: ListTile(
                    leading: sitio.imagen.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              sitio.imagen,
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.place),
                            ),
                          )
                        : const Icon(Icons.place),
                    title: Text(
                      sitio.nombre,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      sitio.descripcion.isEmpty
                          ? sitio.direccion
                          : sitio.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}