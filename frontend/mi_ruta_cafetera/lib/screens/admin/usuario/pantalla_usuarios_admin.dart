import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../controllers/admin/usuario/usuario_admin_controller.dart';
import '../../../models/admin/usuario_admin.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import '../../../widgets/admin/usuario/tarjeta_usuario.dart';
import '../../../widgets/admin/usuario/filtros_usuarios.dart';
import '../../../widgets/admin/usuario/resumen_usuarios.dart';

class PantallaUsuariosAdmin extends StatefulWidget {
  const PantallaUsuariosAdmin({super.key});

  @override
  State<PantallaUsuariosAdmin> createState() =>
      _PantallaUsuariosAdminState();
}

class _PantallaUsuariosAdminState extends State<PantallaUsuariosAdmin> {
  late final UsuarioAdminController _controller;
  final TextEditingController _busquedaController =
      TextEditingController();

  bool _actualizandoLista = false;

  @override
  void initState() {
    super.initState();
    _controller = UsuarioAdminController()..cargarUsuarios();
  }

  @override
  void dispose() {
    _controller.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _recargar() async {
    if (_actualizandoLista || _controller.cargando) return;

    setState(() => _actualizandoLista = true);

    try {
      await _controller.cargarUsuarios();
    } finally {
      if (mounted) {
        setState(() => _actualizandoLista = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final usuarios = _controller.usuariosFiltrados;
            final cargando =
                _actualizandoLista || _controller.cargando;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _recargar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(
                  AppDimensions.pageHorizontalSmall,
                ),
                children: [
                  EncabezadoLista(
                    titulo: '',
                    descripcion: 'usuarios registrados',
                    textoNuevo: '',
                    cantidad: _controller.totalUsuarios,
                    cargando: _actualizandoLista,
                    onActualizar: _recargar,
                    onNuevo: () {},
                    mostrarBotonNuevo: false,
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingLg,
                  ),

                  ResumenUsuarios(
                    tarjetas: [
                      ResumenTarjeta(
                        titulo: 'Todos',
                        cantidad: _controller.totalUsuarios,
                        icono: Icons.groups_rounded,
                        color: AppColors.primary,
                      ),
                      ResumenTarjeta(
                        titulo: 'Usuarios activos',
                        cantidad: _controller.usuariosActivos,
                        icono: Icons.person_rounded,
                        color: AppColors.success,
                      ),
                      ResumenTarjeta(
                        titulo: 'Usuarios inactivos',
                        cantidad: _controller.usuariosInactivos,
                        icono: Icons.person_off_rounded,
                        color: AppColors.error,
                      ),
                      ResumenTarjeta(
                        titulo: 'Cuentas eliminadas',
                        cantidad: _controller.usuariosEliminados,
                        icono: Icons.delete_forever_rounded,
                        color: Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingLg,
                  ),

                  BarraBusqueda(
                    controller: _busquedaController,
                    valor: _busquedaController.text,
                    textoAyuda: 'Buscar por nombre o correo...',
                    onChanged: _controller.buscar,
                    onLimpiar: () {
                      _busquedaController.clear();
                      _controller.buscar('');
                      setState(() {});
                    },
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingMd,
                  ),

                  FiltrosUsuarios(
                    filtroSeleccionado: _controller.filtroEstado,
                    onFiltroSeleccionado:
                        _controller.filtrarPorEstado,
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingLg,
                  ),

                  if (cargando)
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.45,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Usuarios registrados',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${usuarios.length} resultados',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: AppDimensions.spacingMd,
                    ),

                    if (_controller.error != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMd,
                        ),
                        child: Text(
                          _controller.error!,
                          style: const TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                      ),

                    if (usuarios.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(
                          AppDimensions.spacingXxl,
                        ),
                        child: Center(
                          child: Text(
                            'No se encontraron usuarios.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )
                    else
                      ...usuarios.map(
                        (usuario) => TarjetaUsuario(
                          usuario: usuario,
                          onCambiarEstado: () =>
                              _confirmarCambioEstado(usuario),
                          onEliminar: () =>
                              _confirmarEliminacion(usuario),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmarCambioEstado(
    UsuarioAdmin usuario,
  ) async {
    final accion = usuario.activo ? 'desactivar' : 'activar';

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${accion[0].toUpperCase()}${accion.substring(1)} usuario',
        ),
        content: Text(
          '¿Seguro que deseas $accion la cuenta de '
          '${usuario.nombreCompleto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(accion.toUpperCase()),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    final correcto =
        await _controller.cambiarEstadoUsuario(usuario);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          correcto
              ? 'Estado del usuario actualizado correctamente.'
              : _controller.error ??
                  'No se pudo actualizar el usuario.',
        ),
      ),
    );
  }

  Future<void> _confirmarEliminacion(
    UsuarioAdmin usuario,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Deseas eliminar permanentemente la cuenta de '
          '${usuario.nombreCompleto}?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmado != true || !mounted) return;

    final correcto =
        await _controller.eliminarUsuario(usuario.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          correcto
              ? 'Usuario eliminado correctamente.'
              : _controller.error ??
                  'No se pudo eliminar el usuario.',
        ),
      ),
    );
  }
}