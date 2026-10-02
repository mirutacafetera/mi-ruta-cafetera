import 'package:flutter/material.dart';

import '../../../controllers/admin/sitio/lista_sitios.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';
import '../../../widgets/admin/sitio_turistico/sitios_tarjetas/informacion_sitios.dart';
import '../../../widgets/admin/sitio_turistico/sitios_tarjetas/tarjeta_sitio.dart';

import 'formulario_sitio.dart';

class PantallaListaSitios extends StatefulWidget {
  const PantallaListaSitios({super.key});

  @override
  State<PantallaListaSitios> createState() => _PantallaListaSitiosState();
}

class _PantallaListaSitiosState extends State<PantallaListaSitios> {
  late final ListaSitios controlador;

  @override
  void initState() {
    super.initState();

    controlador = ListaSitios();
    controlador.addListener(_actualizar);
    controlador.cargarDatos();
  }

  void _actualizar() {
    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // CREAR SITIO
  // ============================================================

  Future<void> _crearSitio() async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (contextModal) {
        return FormularioSitio(categorias: controlador.categorias);
      },
    );

    if (!mounted) return;

    if (resultado == true) {
      await controlador.cargarDatos();

      if (!mounted) return;

      _mostrarMensaje('Sitio turístico creado correctamente.');
    }
  }

  // ============================================================
  // EDITAR SITIO
  // ============================================================

  Future<void> _editarSitio(Map<String, dynamic> sitio) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (contextModal) {
        return FormularioSitio(
          sitio: sitio,
          categorias: controlador.categorias,
        );
      },
    );

    if (!mounted) return;

    if (resultado == true) {
      await controlador.cargarDatos();

      if (!mounted) return;

      _mostrarMensaje('Sitio turístico actualizado correctamente.');
    }
  }

  // ============================================================
  // ELIMINAR SITIO
  // ============================================================

  Future<void> _eliminarSitio(Map<String, dynamic> sitio) async {
    final id = controlador.obtenerId(sitio);

    if (id == null || id.isEmpty) {
      _mostrarMensaje('No se encontró el ID del sitio.', error: true);
      return;
    }

    final nombre = (sitio['nombre'] ?? 'este sitio').toString();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (contextDialogo) {
        return AlertDialog(
          title: const Text('Eliminar sitio'),
          content: Text('¿Seguro que deseas eliminar "$nombre"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(contextDialogo).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
              ),
              onPressed: () {
                Navigator.of(contextDialogo).pop(true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await controlador.eliminarSitio(id);

      if (!mounted) return;

      _mostrarMensaje('Sitio eliminado correctamente.');
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje('Error al eliminar el sitio: $e', error: true);
    }
  }

  // ============================================================
  // MENSAJES
  // ============================================================

  void _mostrarMensaje(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: error ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppDimensions.spacingMd),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final sitios = controlador.sitiosFiltrados;

    return Column(
      children: [
        EncabezadoLista(
          titulo: 'Sitios turísticos',
          descripcion: 'sitios registrados',
          textoNuevo: 'Nuevo sitio',
          cantidad: controlador.sitios.length,
          cargando: controlador.cargando,
          onActualizar: controlador.cargarDatos,
          onNuevo: _crearSitio,
        ),

        BarraBusqueda(
          valor: controlador.busqueda,
          textoAyuda: 'Buscar por nombre, ciudad, dirección o categoría...',
          onChanged: controlador.buscar,
          onLimpiar: controlador.limpiarBusqueda,
        ),

        Expanded(
          child: controlador.cargando
              ? const Center(child: CircularProgressIndicator())
              : _contenido(sitios),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _contenido(List<Map<String, dynamic>> sitios) {
    if (sitios.isEmpty) {
      return InformacionSitios(
        buscando: controlador.busqueda.isNotEmpty,
        onRegistrar: _crearSitio,
      );
    }

    return RefreshIndicator(
      onRefresh: controlador.cargarDatos,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingLg,
          AppDimensions.spacingXs,
          AppDimensions.spacingLg,
          AppDimensions.spacingXl,
        ),
        itemCount: sitios.length,
        itemBuilder: (context, index) {
          final sitio = sitios[index];

          return TarjetaSitio(
            sitio: sitio,
            categoria: controlador.obtenerCategoria(sitio),
            activo: controlador.estaActivo(sitio),
            imagen: controlador.obtenerImagen(sitio),
            onEditar: () => _editarSitio(sitio),
            onEliminar: () => _eliminarSitio(sitio),
          );
        },
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    controlador.removeListener(_actualizar);
    controlador.dispose();
    super.dispose();
  }
}
