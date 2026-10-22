import 'package:flutter/material.dart';

import '../../../controllers/admin/sitio/lista_sitios.dart';
import '../../../models/admin/sitio_admin_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import '../../../widgets/admin/sitio_turistico/detalle_sitio_turistico.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';
import '../../../widgets/admin/sitio_turistico/sitios_tarjetas/informacion_sitios.dart';
import '../../../widgets/admin/sitio_turistico/sitios_tarjetas/tarjeta_sitio.dart';
import 'formulario_sitio.dart';

class PantallaListaSitios extends StatefulWidget {
  const PantallaListaSitios({super.key});

  @override
  State<PantallaListaSitios> createState() =>
      _PantallaListaSitiosState();
}

class _PantallaListaSitiosState extends State<PantallaListaSitios> {
  late final ListaSitios controlador;
  bool actualizando = false;

  @override
  void initState() {
    super.initState();
    controlador = ListaSitios();
    controlador.addListener(_actualizar);
    controlador.cargarDatos();
  }

  void _actualizar() {
    if (mounted) setState(() {});
  }

  Future<void> _actualizarSitios() async {
    if (actualizando) return;

    setState(() => actualizando = true);

    try {
      await controlador.cargarDatos();
    } catch (_) {
      if (mounted) {
        _mostrarMensaje(
          'No fue posible actualizar los sitios.',
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => actualizando = false);
      }
    }
  }

  Future<void> _crearSitio() async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormularioSitio(
        categorias: controlador.categorias,
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      await controlador.cargarDatos();
      if (!mounted) return;
      _mostrarMensaje('Sitio turístico creado correctamente.');
    }
  }

  Future<void> _editarSitio(SitioAdminModel sitio) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormularioSitio(
        sitio: sitio.toJson(),
        categorias: controlador.categorias,
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      await controlador.cargarDatos();
      if (!mounted) return;
      _mostrarMensaje('Sitio turístico actualizado correctamente.');
    }
  }

  Future<void> _mostrarDetalle(SitioAdminModel sitio) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              controller: scrollController,
              child: DetalleSitioTuristico(sitio: sitio),
            ),
          );
        },
      ),
    );
  }

  Future<void> _eliminarSitio(SitioAdminModel sitio) async {
    final id = controlador.obtenerId(sitio);

    if (id == null || id.isEmpty) {
      _mostrarMensaje(
        'No se encontró el ID del sitio.',
        error: true,
      );
      return;
    }

    final nombre = sitio.nombre.isEmpty ? 'este sitio' : sitio.nombre;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar sitio'),
        content: Text('¿Seguro que deseas eliminar "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await controlador.eliminarSitio(id);
      if (!mounted) return;
      _mostrarMensaje('Sitio eliminado correctamente.');
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje(
        'Error al eliminar el sitio: $e',
        error: true,
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final sitios = controlador.sitiosFiltrados;

    return Stack(
      children: [
        Column(
          children: [
            EncabezadoLista(
              titulo: '',
              descripcion: 'sitios registrados',
              textoNuevo: '',
              cantidad: controlador.sitios.length,
              cargando: controlador.cargando,
              mostrarBotonNuevo: false,
              onActualizar: _actualizarSitios,
              onNuevo: _crearSitio,
            ),
            BarraBusqueda(
              valor: controlador.busqueda,
              textoAyuda:
                  'Buscar por nombre, ciudad, dirección o categoría...',
              onChanged: controlador.buscar,
              onLimpiar: controlador.limpiarBusqueda,
            ),
            Expanded(
              child: actualizando
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _actualizarSitios,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 90),
                        children: [
                          if (sitios.isEmpty)
                            InformacionSitios(
                              buscando: controlador.busqueda.isNotEmpty,
                              onRegistrar: _crearSitio,
                            )
                          else
                            ...sitios.map(
                              (sitio) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.spacingLg,
                                  vertical: AppDimensions.spacingXs,
                                ),
                                child: TarjetaSitio(
                                  sitio: sitio.toJson(),
                                  categoria:
                                      controlador.obtenerCategoria(sitio),
                                  activo: controlador.estaActivo(sitio),
                                  imagen: controlador.obtenerImagen(sitio),
                                  onEditar: () => _editarSitio(sitio),
                                  onEliminar: () => _eliminarSitio(sitio),
                                  onTap: () => _mostrarDetalle(sitio),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
        Positioned(
          right: AppDimensions.spacingLg,
          bottom: AppDimensions.spacingXl,
          child: Material(
            color: AppColors.secondary,
            elevation: 5,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _crearSitio,
              child: const SizedBox(
                width: 54,
                height: 54,
                child: Icon(
                  Icons.add,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controlador.removeListener(_actualizar);
    controlador.dispose();
    super.dispose();
  }
}