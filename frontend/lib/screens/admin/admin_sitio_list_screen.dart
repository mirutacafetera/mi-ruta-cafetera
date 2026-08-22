import 'package:flutter/material.dart';

import '../../services/admin_sitio_service.dart';
import '../../widgets/sitio_form_sheet.dart';

class AdminSitioListScreen extends StatefulWidget {
  const AdminSitioListScreen({super.key});

  @override
  State<AdminSitioListScreen> createState() =>
      _AdminSitioListScreenState();
}

class _AdminSitioListScreenState
    extends State<AdminSitioListScreen> {
  late Future<List<dynamic>> _sitiosFuture;

  @override
  void initState() {
    super.initState();
    _cargarSitios();
  }

  // =====================================================
  // CARGAR SITIOS
  // =====================================================

  void _cargarSitios() {
    setState(() {
      _sitiosFuture = AdminSitioService.obtenerSitios();
    });
  }

  // =====================================================
  // CREAR SITIO
  // =====================================================

  Future<void> _crearSitio() async {
    final resultado = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const SitioFormSheet();
      },
    );

    // Si el formulario se cerró después de guardar,
    // volvemos a consultar el backend.
    if (resultado != null && mounted) {
      _cargarSitios();
    }
  }

  // =====================================================
  // EDITAR SITIO
  // =====================================================

  Future<void> _editarSitio(Map<String, dynamic> sitio) async {
    final resultado = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SitioFormSheet(
          sitio: sitio,
        );
      },
    );

    // Volvemos a cargar la lista después de editar.
    if (resultado != null && mounted) {
      _cargarSitios();
    }
  }

  // =====================================================
  // DESACTIVAR SITIO
  // =====================================================

  Future<void> _desactivarSitio(String id) async {
    try {
      await AdminSitioService.desactivarSitio(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sitio turístico desactivado correctamente',
          ),
        ),
      );

      _cargarSitios();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo desactivar el sitio: $e',
          ),
        ),
      );
    }
  }

  // =====================================================
  // CONFIRMAR DESACTIVACIÓN
  // =====================================================

  Future<void> _confirmarDesactivacion(
    String id,
    String nombre,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Desactivar sitio',
          ),
          content: Text(
            '¿Estás seguro de que deseas desactivar "$nombre"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _desactivarSitio(id);
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _sitiosFuture,
        builder: (context, snapshot) {
          // =================================================
          // CARGANDO
          // =================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // =================================================
          // ERROR
          // =================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'No se pudieron cargar los sitios turísticos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _cargarSitios,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          // =================================================
          // SIN DATOS
          // =================================================

          final sitios = snapshot.data ?? [];

          if (sitios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 70,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'No hay sitios turísticos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Agrega el primer sitio turístico.',
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: _crearSitio,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Crear sitio',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // =================================================
          // LISTA DE SITIOS
          // =================================================

          return RefreshIndicator(
            onRefresh: () async {
              _cargarSitios();
              await _sitiosFuture;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sitios.length,
              itemBuilder: (context, index) {
                final sitio = sitios[index];

                final String id =
                    sitio['_id']?.toString() ??
                    sitio['id']?.toString() ??
                    '';

                final String nombre =
                    sitio['nombre']?.toString() ??
                    'Sin nombre';

                final String descripcion =
                    sitio['descripcion']?.toString() ??
                    'Sin descripción';

                final String categoria =
                    sitio['categoria']?.toString() ??
                    'Sin categoría';

                final String direccion =
                    sitio['direccion']?.toString() ??
                    'Sin dirección';

                final bool activo =
                    sitio['activo'] != false;

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 14,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // =====================================
                        // NOMBRE
                        // =====================================

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF1B5E20),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            PopupMenuButton<String>(
                              onSelected: (opcion) {
                                if (opcion == 'editar') {
                                  _editarSitio(sitio);
                                }

                                if (opcion == 'desactivar') {
                                  _confirmarDesactivacion(
                                    id,
                                    nombre,
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'desactivar',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.block,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Desactivar',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // =====================================
                        // CATEGORÍA
                        // =====================================

                        Chip(
                          label: Text(categoria),
                          avatar: const Icon(
                            Icons.category,
                            size: 18,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // =====================================
                        // DESCRIPCIÓN
                        // =====================================

                        Text(
                          descripcion,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // =====================================
                        // DIRECCIÓN
                        // =====================================

                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.place,
                              size: 20,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 6),

                            Expanded(
                              child: Text(
                                direccion,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // =====================================
                        // ESTADO
                        // =====================================

                        Row(
                          children: [
                            Icon(
                              activo
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 18,
                              color: activo
                                  ? Colors.green
                                  : Colors.red,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              activo
                                  ? 'Activo'
                                  : 'Inactivo',
                              style: TextStyle(
                                color: activo
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      // =====================================================
      // BOTÓN AGREGAR
      // =====================================================

      floatingActionButton: FloatingActionButton(
        onPressed: _crearSitio,
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}