import 'package:flutter/material.dart';

import '../../../services/admin/admin_sitio_service.dart';

import '../../../widgets/admin/sitio_card.dart';
import '../../../widgets/admin/sitio_empty_state.dart';
import '../../../widgets/admin/sitio_form_sheet.dart';
import '../../../widgets/admin/sitio_list_header.dart';
import '../../../widgets/admin/sitio_search_bar.dart';

class AdminSitioListScreen extends StatefulWidget {
  const AdminSitioListScreen({
    super.key,
  });

  @override
  State<AdminSitioListScreen> createState() =>
      _AdminSitioListScreenState();
}

class _AdminSitioListScreenState
    extends State<AdminSitioListScreen> {
  // =========================
  // DATOS
  // =========================

  List<Map<String, dynamic>> _sitios = [];
  List<Map<String, dynamic>> _categorias = [];

  bool _cargando = true;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // =========================
  // CARGAR DATOS
  // =========================

  Future<void> _cargarDatos() async {
    if (mounted) {
      setState(() {
        _cargando = true;
      });
    }

    try {
      final respuestaSitios =
          await AdminSitioService.obtenerSitios();

      final respuestaCategorias =
          await AdminSitioService.obtenerCategorias();

      final sitios = respuestaSitios
          .whereType<Map>()
          .map(
            (sitio) => Map<String, dynamic>.from(
              sitio,
            ),
          )
          .toList();

      final categorias = respuestaCategorias
          .whereType<Map>()
          .map(
            (categoria) =>
                Map<String, dynamic>.from(
              categoria,
            ),
          )
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _sitios = sitios;
        _categorias = categorias;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
      });

      _mostrarMensaje(
        'Error al cargar los datos: $e',
        error: true,
      );
    }
  }

  // =========================
  // FILTRAR
  // =========================

  List<Map<String, dynamic>> get _sitiosFiltrados {
    if (_busqueda.trim().isEmpty) {
      return _sitios;
    }

    final texto = _busqueda
        .toLowerCase()
        .trim();

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

      final categoria =
          _obtenerCategoria(sitio)
              .toLowerCase();

      return nombre.contains(texto) ||
          ciudad.contains(texto) ||
          direccion.contains(texto) ||
          categoria.contains(texto);
    }).toList();
  }

  // =========================
  // CREAR
  // =========================

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

  // =========================
  // EDITAR
  // =========================

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

  // =========================
  // ELIMINAR
  // =========================

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
        (sitio['nombre'] ?? 'este sitio')
            .toString();

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
      await AdminSitioService.eliminarSitio(
        id,
      );

      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        'Sitio eliminado correctamente.',
      );

      await _cargarDatos();
    } catch (e) {
      if (!mounted) {
        return;
      }

      _mostrarMensaje(
        'Error al eliminar el sitio: $e',
        error: true,
      );
    }
  }

  // =========================
  // ID
  // =========================

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

  // =========================
  // CATEGORÍA
  // =========================

  String _obtenerCategoria(
    Map<String, dynamic> sitio,
  ) {
    final categoria = sitio['categoria'];

    if (categoria == null) {
      return 'Sin categoría';
    }

    if (categoria is String) {
      final categoriaEncontrada =
          _categorias
              .cast<Map<String, dynamic>?>()
              .firstWhere(
                (item) =>
                    item?['_id']?.toString() ==
                    categoria,
                orElse: () => null,
              );

      if (categoriaEncontrada != null) {
        return (
          categoriaEncontrada['nombre'] ??
          'Sin categoría'
        ).toString();
      }

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

  // =========================
  // ESTADO
  // =========================

  bool _estaActivo(
    Map<String, dynamic> sitio,
  ) {
    final activo = sitio['activo'];

    if (activo is bool) {
      return activo;
    }

    final estado = sitio['estado'];

    if (estado is bool) {
      return estado;
    }

    return true;
  }

  // =========================
  // IMAGEN
  // =========================

  String? _obtenerImagen(
    Map<String, dynamic> sitio,
  ) {
    final imagen = sitio['imagen'];

    if (imagen != null &&
        imagen.toString().trim().isNotEmpty) {
      return imagen.toString();
    }

    final imagenes = sitio['imagenes'];

    if (imagenes is List &&
        imagenes.isNotEmpty) {
      final primera = imagenes.first;

      if (primera != null &&
          primera.toString().trim().isNotEmpty) {
        return primera.toString();
      }
    }

    return null;
  }

  // =========================
  // MENSAJE
  // =========================

  void _mostrarMensaje(
    String mensaje, {
    bool error = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
            error
                ? Colors.red
                : Colors.green,
      ),
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        SitioListHeader(
          cantidadSitios: _sitios.length,
          cargando: _cargando,
          onActualizar: _cargarDatos,
          onNuevoSitio: _crearSitio,
        ),

        SitioSearchBar(
          valor: _busqueda,
          onChanged: (valor) {
            setState(() {
              _busqueda = valor;
            });
          },
          onLimpiar: () {
            setState(() {
              _busqueda = '';
            });
          },
        ),

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

  // =========================
  // CONTENIDO
  // =========================

  Widget _contenido() {
    final sitios = _sitiosFiltrados;

    if (sitios.isEmpty) {
      return SitioEmptyState(
        buscando: _busqueda.isNotEmpty,
        onRegistrar: _crearSitio,
      );
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
        itemBuilder: (context, index) {
          final sitio = sitios[index];

          return SitioCard(
            sitio: sitio,
            categoria: _obtenerCategoria(
              sitio,
            ),
            activo: _estaActivo(
              sitio,
            ),
            imagen: _obtenerImagen(
              sitio,
            ),
            onEditar: () {
              _editarSitio(sitio);
            },
            onEliminar: () {
              _eliminarSitio(sitio);
            },
          );
        },
      ),
    );
  }
}