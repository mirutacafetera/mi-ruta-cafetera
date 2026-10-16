import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../controllers/admin/resena/resena_admin_controller.dart';
import '../../../widgets/admin/usuario/resumen_usuarios.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';
import '../../../widgets/admin/resena/filtros_resenas.dart';
import '../../../widgets/admin/resena/tarjeta_resena.dart';

class PantallaResenasAdmin extends StatefulWidget {
  const PantallaResenasAdmin({super.key});

  @override
  State<PantallaResenasAdmin> createState() => _PantallaResenasAdminState();
}

class _PantallaResenasAdminState extends State<PantallaResenasAdmin> {
  final _controller = ResenaAdminController();
  final _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_actualizar);
    _controller.cargarResenas();
  }

  void _actualizar() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_actualizar);
    _controller.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _eliminarResena(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar reseña'),
        content: const Text('¿Deseas eliminar esta reseña?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final resultado = await _controller.eliminarResena(id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultado ? 'Reseña eliminada' : 'No se pudo eliminar la reseña',
        ),
      ),
    );
  }

  Future<void> _cambiarEstado(dynamic resena) async {
    final resultado = await _controller.cambiarEstado(resena);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultado ? 'Estado actualizado' : 'No se pudo actualizar el estado',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EncabezadoLista(
          titulo: 'Reseñas',
          descripcion: 'reseñas registradas',
          textoNuevo: '',
          cantidad: _controller.totalResenas,
          cargando: _controller.cargando,
          mostrarBotonNuevo: false,
          onActualizar: _controller.cargarResenas,
          onNuevo: () {},
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pageHorizontalSmall,
          ),
          child: ResumenUsuarios(
            tarjetas: [
              ResumenTarjeta(
                titulo: 'Total de reseñas',
                cantidad: _controller.totalResenas,
                icono: Icons.rate_review_rounded,
                color: AppColors.primary,
              ),
              ResumenTarjeta(
                titulo: 'Reseñas activas',
                cantidad: _controller.resenasActivas,
                icono: Icons.check_circle_rounded,
                color: AppColors.primary,
              ),
              ResumenTarjeta(
                titulo: 'Reseñas inactivas',
                cantidad: _controller.resenasInactivas,
                icono: Icons.cancel_rounded,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
        BarraBusqueda(
          valor: _controller.busqueda,
          controller: _busquedaController,
          textoAyuda: 'Buscar usuario, sitio o comentario',
          onChanged: _controller.cambiarBusqueda,
          onLimpiar: () {
            _busquedaController.clear();
            _controller.cambiarBusqueda('');
          },
        ),
        FiltrosResenas(
          filtroSeleccionado: _controller.filtroEstado,
          onChanged: _controller.cambiarFiltro,
        ),
        Expanded(
          child: _controller.cargando
              ? const Center(child: CircularProgressIndicator())
              : _controller.error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_controller.error!),
                          const SizedBox(height: AppDimensions.spacingSm),
                          FilledButton(
                            onPressed: _controller.cargarResenas,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : _controller.resenasFiltradas.isEmpty
                      ? const Center(
                          child: Text('No se encontraron reseñas'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacingLg,
                          ),
                          itemCount: _controller.resenasFiltradas.length,
                          itemBuilder: (context, index) {
                            final resena =
                                _controller.resenasFiltradas[index];

                            return TarjetaResena(
                              resena: resena,
                              onCambiarEstado: () => _cambiarEstado(resena),
                              onEliminar: () => _eliminarResena(resena.id),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}