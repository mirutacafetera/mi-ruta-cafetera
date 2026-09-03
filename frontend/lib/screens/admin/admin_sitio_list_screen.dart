import 'package:flutter/material.dart';

import '../../services/admin/admin_sitio_service.dart';
import '../../widgets/admin/sitio_form_sheet.dart';

class AdminSitioListScreen extends StatefulWidget {
  const AdminSitioListScreen({super.key});

  @override
  State<AdminSitioListScreen> createState() =>
      _AdminSitioListScreenState();
}

class _AdminSitioListScreenState
    extends State<AdminSitioListScreen> {
  List<Map<String, dynamic>> _sitios = [];
  List<Map<String, dynamic>> _categorias = [];

  bool _cargando = true;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ============================================================
  // CARGAR SITIOS Y CATEGORÍAS
  // ============================================================

  Future<void> _cargarDatos() async {
    if (mounted) {
      setState(() {
        _cargando = true;
      });
    }

    try {
      // Obtener sitios desde /admin/authsitio
      final List<dynamic> respuestaSitios =
          await AdminSitioService.obtenerSitios();

      // Obtener categorías desde /categorias-sitios
      final List<dynamic> respuestaCategorias =
          await AdminSitioService.obtenerCategorias();

      final sitios = respuestaSitios
          .whereType<Map>()
          .map(
            (sitio) =>
                Map<String, dynamic>.from(sitio),
          )
          .toList();

      final categorias = respuestaCategorias
          .whereType<Map>()
          .map(
            (categoria) =>
                Map<String, dynamic>.from(categoria),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _sitios = sitios;
        _categorias = categorias;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      _mostrarMensaje(
        'Error al cargar los datos: $e',
        error: true,
      );
    }
  }

  // ============================================================
  // FILTRAR SITIOS
  // ============================================================

  List<Map<String, dynamic>> get _sitiosFiltrados {
    if (_busqueda.trim().isEmpty) {
      return _sitios;
    }

    final texto = _busqueda.toLowerCase().trim();

    return _sitios.where((sitio) {
      final nombre =
          (sitio['nombre'] ?? '')
              .toString()
              .toLowerCase();

      final ciudad =
          (sitio['ciudad'] ?? '')
              .toString()
              .toLowerCase();

      final direccion =
          (sitio['direccion'] ?? '')
              .toString()
              .toLowerCase();

      return nombre.contains(texto) ||
          ciudad.contains(texto) ||
          direccion.contains(texto);
    }).toList();
  }

  // ============================================================
  // CREAR SITIO
  // ============================================================

  Future<void> _crearSitio() async {
    final resultado =
        await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SitioFormSheet(
          categorias: _categorias,
        );
      },
    );

    if (resultado == true) {
      await _cargarDatos();
    }
  }

  // ============================================================
  // EDITAR SITIO
  // ============================================================

  Future<void> _editarSitio(
    Map<String, dynamic> sitio,
  ) async {
    final resultado =
        await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SitioFormSheet(
          sitio: sitio,
          categorias: _categorias,
        );
      },
    );

    if (resultado == true) {
      await _cargarDatos();
    }
  }

  // ============================================================
  // ELIMINAR SITIO
  // ============================================================

  Future<void> _eliminarSitio(
    Map<String, dynamic> sitio,
  ) async {
    final id = _obtenerId(sitio);

    if (id == null || id.isEmpty) {
      _mostrarMensaje(
        'No se encontró el ID del sitio.',
        error: true,
      );
      return;
    }

    final nombre =
        (sitio['nombre'] ?? 'este sitio').toString();

    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Eliminar sitio',
          ),
          content: Text(
            '¿Seguro que deseas eliminar "$nombre"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await AdminSitioService.eliminarSitio(id);

      if (!mounted) return;

      _mostrarMensaje(
        'Sitio eliminado correctamente.',
      );

      await _cargarDatos();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(
        'Error al eliminar el sitio: $e',
        error: true,
      );
    }
  }

  // ============================================================
  // OBTENER ID
  // ============================================================

  String? _obtenerId(
    Map<String, dynamic> sitio,
  ) {
    final id = sitio['_id'] ?? sitio['id'];

    if (id == null) {
      return null;
    }

    if (id is Map) {
      return id[r'$oid']?.toString();
    }

    return id.toString();
  }

  // ============================================================
  // OBTENER CATEGORÍA
  // ============================================================

  String _obtenerCategoria(
    Map<String, dynamic> sitio,
  ) {
    final categoria = sitio['categoria'];

    if (categoria == null) {
      return 'Sin categoría';
    }

    if (categoria is String) {
      return categoria;
    }

    if (categoria is Map) {
      return (
        categoria['nombre'] ??
        categoria['name'] ??
        'Sin categoría'
      ).toString();
    }

    return categoria.toString();
  }

  // ============================================================
  // ESTADO
  // ============================================================

  bool _estaActivo(
    Map<String, dynamic> sitio,
  ) {
    // Tu base de datos utiliza "activo".
    final activo = sitio['activo'];

    if (activo is bool) {
      return activo;
    }

    // Compatibilidad con documentos antiguos.
    final estado = sitio['estado'];

    if (estado is bool) {
      return estado;
    }

    return true;
  }

  // ============================================================
  // MENSAJE
  // ============================================================

  void _mostrarMensaje(
    String mensaje, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
            error ? Colors.red : Colors.green,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        _barraSuperior(),
        _barraBusqueda(),
        Expanded(
          child: _cargando
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : _contenido(),
        ),
      ],
    );
  }

  // ============================================================
  // BARRA SUPERIOR
  // ============================================================

  Widget _barraSuperior() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Sitios turísticos',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                      ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  '${_sitios.length} sitios registrados',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed:
                _cargando ? null : _cargarDatos,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          FilledButton.icon(
            onPressed: _crearSitio,
            icon: const Icon(
              Icons.add,
            ),
            label: const Text(
              'Nuevo sitio',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUSCADOR
  // ============================================================

  Widget _barraBusqueda() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        12,
      ),
      child: TextField(
        onChanged: (valor) {
          setState(() {
            _busqueda = valor;
          });
        },
        decoration: InputDecoration(
          hintText:
              'Buscar por nombre, ciudad o dirección...',
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon:
              _busqueda.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _busqueda = '';
                        });
                      },
                      icon: const Icon(
                        Icons.clear,
                      ),
                    )
                  : null,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _contenido() {
    final sitios = _sitiosFiltrados;

    if (sitios.isEmpty) {
      return _sinResultados();
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          4,
          16,
          24,
        ),
        itemCount: sitios.length,
        itemBuilder: (
          context,
          index,
        ) {
          return _tarjetaSitio(
            sitios[index],
          );
        },
      ),
    );
  }

  // ============================================================
  // SIN RESULTADOS
  // ============================================================

  Widget _sinResultados() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 70,
              color:
                  Colors.grey.shade400,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              _busqueda.isEmpty
                  ? 'No hay sitios registrados'
                  : 'No se encontraron sitios',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              _busqueda.isEmpty
                  ? 'Puedes registrar el primer sitio turístico.'
                  : 'Prueba con otro nombre, ciudad o dirección.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),
            if (_busqueda.isEmpty) ...[
              const SizedBox(
                height: 20,
              ),
              FilledButton.icon(
                onPressed: _crearSitio,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Registrar sitio',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA DEL SITIO
  // ============================================================

  Widget _tarjetaSitio(
    Map<String, dynamic> sitio,
  ) {
    final nombre =
        (sitio['nombre'] ?? 'Sin nombre')
            .toString();

    final descripcion =
        (sitio['descripcion'] ??
                'Sin descripción')
            .toString();

    final ciudad =
        (sitio['ciudad'] ?? '')
            .toString();

    final direccion =
        (sitio['direccion'] ?? '')
            .toString();

    final categoria =
        _obtenerCategoria(sitio);

    final activo =
        _estaActivo(sitio);

    final imagen =
        _obtenerImagen(sitio);

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 2,
      clipBehavior:
          Clip.antiAlias,
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _imagenSitio(imagen),
            const SizedBox(
              width: 14,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected:
                            (opcion) {
                          if (opcion ==
                              'editar') {
                            _editarSitio(
                              sitio,
                            );
                          }

                          if (opcion ==
                              'eliminar') {
                            _eliminarSitio(
                              sitio,
                            );
                          }
                        },
                        itemBuilder:
                            (context) =>
                                const [
                          PopupMenuItem(
                            value:
                                'editar',
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .edit_outlined,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Editar',
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value:
                                'eliminar',
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .delete_outline,
                                  color:
                                      Colors.red,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Eliminar',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _etiqueta(
                        categoria,
                        Icons
                            .category_outlined,
                      ),
                      if (ciudad.isNotEmpty)
                        _etiqueta(
                          ciudad,
                          Icons
                              .location_city_outlined,
                        ),
                      _estado(
                        activo,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          Colors.grey.shade700,
                    ),
                  ),
                  if (direccion.isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons
                              .location_on_outlined,
                          size: 16,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            direccion,
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGEN
  // ============================================================

  String? _obtenerImagen(
    Map<String, dynamic> sitio,
  ) {
    final imagen = sitio['imagen'];

    if (imagen != null &&
        imagen.toString().trim().isNotEmpty) {
      return imagen.toString();
    }

    final imagenes =
        sitio['imagenes'];

    if (imagenes is List &&
        imagenes.isNotEmpty) {
      final primera =
          imagenes.first;

      if (primera != null &&
          primera
              .toString()
              .trim()
              .isNotEmpty) {
        return primera.toString();
      }
    }

    return null;
  }

  Widget _imagenSitio(
    String? imagen,
  ) {
    if (imagen == null ||
        imagen.isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration:
            BoxDecoration(
          color:
              Colors.green.shade50,
          borderRadius:
              BorderRadius.circular(
            10,
          ),
        ),
        child: Icon(
          Icons.place_outlined,
          size: 42,
          color:
              Colors.green.shade700,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(10),
      child: Image.network(
        imagen,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            width: 90,
            height: 90,
            color:
                Colors.green.shade50,
            child: Icon(
              Icons
                  .broken_image_outlined,
              size: 38,
              color:
                  Colors.grey.shade500,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ETIQUETA
  // ============================================================

  Widget _etiqueta(
    String texto,
    IconData icono,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icono,
            size: 14,
            color:
                Colors.grey.shade700,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            texto,
            style:
                const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ESTADO
  // ============================================================

  Widget _estado(
    bool activo,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: activo
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        activo
            ? 'Activo'
            : 'Inactivo',
        style: TextStyle(
          fontSize: 12,
          fontWeight:
              FontWeight.w600,
          color: activo
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ),
    );
  }
}