import 'package:flutter/material.dart';

import '../../../config/api_config.dart';
import '../../../controllers/admin/cuenta_sitio/cuenta_sitio_controller.dart';
import '../../../models/admin/cuenta_sitio_model.dart';
import '../../../models/admin/sitio_admin_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/cuenta_sitio/filtros_cuenta_sitio.dart';
import '../../../widgets/admin/cuenta_sitio/resumen_cuenta_sitio.dart';
import '../../../widgets/admin/cuenta_sitio/tarjeta_cuenta_sitio.dart';
import '../../../widgets/admin/cuenta_sitio/formulario_cuenta_sitio.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';

class PantallaCuentasSitio extends StatefulWidget {
  final String token;

  const PantallaCuentasSitio({
    super.key,
    required this.token,
  });

  @override
  State<PantallaCuentasSitio> createState() =>
      _PantallaCuentasSitioState();
}

class _PantallaCuentasSitioState extends State<PantallaCuentasSitio> {
  late final CuentaSitioController _controller;
  final TextEditingController _busquedaController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CuentaSitioController();
    _cargarDatos();
  }

  @override
  void dispose() {
    _controller.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    await _controller.cargarDatos(token: widget.token);
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> _abrirFormulario({
    required SitioAdminModel sitio,
    CuentaSitioModel? cuenta,
  }) async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: FormularioCuentaSitio(
              cuenta: cuenta,
              cargando: _controller.guardando,
              onGuardar: (datos) async {
                try {
                  if (cuenta == null) {
                    await _controller.crearCuenta(
                      sitioId: sitio.id,
                      nombre: datos['nombre']!,
                      apellido: datos['apellido']!,
                      correo: datos['correo']!,
                      password: datos['password']!,
                      telefono: datos['telefono']!,
                    );
                  } else {
                    await _controller.actualizarCuenta(
                      cuentaId: cuenta.id,
                      nombre: datos['nombre']!,
                      apellido: datos['apellido']!,
                      correo: datos['correo']!,
                      telefono: datos['telefono']!,
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  _mostrarMensaje('No se pudo guardar: $e');
                }
              },
            ),
          ),
        );
      },
    );

    if (resultado == true && mounted) {
      _mostrarMensaje(
        cuenta == null
            ? 'Cuenta creada correctamente'
            : 'Cuenta actualizada correctamente',
      );
    }
  }

  Future<void> _cambiarEstado(CuentaSitioModel cuenta) async {
    final nuevoEstado = !cuenta.activo;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          nuevoEstado ? 'Activar cuenta' : 'Desactivar cuenta',
        ),
        content: Text(
          nuevoEstado
              ? '¿Deseas activar esta cuenta?'
              : '¿Deseas desactivar esta cuenta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _controller.cambiarEstado(
        cuentaId: cuenta.id,
        activo: nuevoEstado,
      );
      _mostrarMensaje(
        nuevoEstado ? 'Cuenta activada' : 'Cuenta desactivada',
      );
    } catch (e) {
      _mostrarMensaje('No se pudo cambiar el estado: $e');
    }
  }

  Future<void> _eliminarSitio(SitioAdminModel sitio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar sitio turístico'),
        content: Text(
          '¿Deseas eliminar "${sitio.nombre}" y su cuenta asociada? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _controller.eliminarSitioYCuenta(sitioId: sitio.id);
      _mostrarMensaje('Sitio turístico eliminado');
    } catch (e) {
      _mostrarMensaje('No se pudo eliminar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final sitios = _controller.sitiosFiltrados;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                EncabezadoLista(
                  titulo: 'Cuentas de sitios',
                  descripcion: 'sitios turísticos',
                  textoNuevo: 'Crear cuenta',
                  cantidad: _controller.totalSitios,
                  cargando: _controller.cargando,
                  onActualizar: _cargarDatos,
                  onNuevo: () {
                    final disponibles = _controller.sitios
                        .where(
                          (sitio) =>
                              _controller.cuentaDeSitio(sitio.id) == null,
                        )
                        .toList();

                    if (disponibles.isEmpty) {
                      _mostrarMensaje(
                        'Todos los sitios tienen una cuenta asociada',
                      );
                      return;
                    }

                    _seleccionarSitio(disponibles);
                  },
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _cargarDatos,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingXl,
                      ),
                      children: [
                        if (_controller.error != null)
                          Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.spacingMd,
                            ),
                            child: Text(
                              _controller.error!,
                              style: const TextStyle(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ResumenCuentaSitio(
                          totalSitios: _controller.totalSitios,
                          conCuenta: _controller.totalConCuenta,
                          sinCuenta: _controller.totalSinCuenta,
                          activas: _controller.cuentasActivas,
                          inactivas: _controller.cuentasInactivas,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pageHorizontalSmall,
                          ),
                          child: BarraBusqueda(
                            valor: _controller.busqueda,
                            textoAyuda: 'Buscar sitio o cuenta...',
                            controller: _busquedaController,
                            onChanged: _controller.cambiarBusqueda,
                            onLimpiar: () {
                              _busquedaController.clear();
                              _controller.cambiarBusqueda('');
                            },
                          ),
                        ),
                        FiltrosCuentaSitio(
                          filtroSeleccionado: _controller.filtro,
                          onChanged: _controller.cambiarFiltro,
                        ),
                        if (_controller.cargando && _controller.sitios.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(
                              AppDimensions.spacingXxl,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (sitios.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(
                              AppDimensions.spacingXxl,
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(
                                  height: AppDimensions.spacingMd,
                                ),
                                Text(
                                  _controller.sitios.isEmpty
                                      ? 'No hay sitios turísticos registrados'
                                      : 'No se encontraron resultados',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...sitios.map((sitio) {
                            final cuenta =
                                _controller.cuentaDeSitio(sitio.id);

                            return TarjetaCuentaSitio(
                              sitio: sitio,
                              cuenta: cuenta,
                              onCrearCuenta: () => _abrirFormulario(
                                sitio: sitio,
                              ),
                              onEditar: cuenta == null
                                  ? null
                                  : () => _abrirFormulario(
                                        sitio: sitio,
                                        cuenta: cuenta,
                                      ),
                              onCambiarEstado: cuenta == null
                                  ? null
                                  : () => _cambiarEstado(cuenta),
                              onEliminar: () => _eliminarSitio(sitio),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _seleccionarSitio(
    List<SitioAdminModel> disponibles,
  ) async {
    final sitio = await showDialog<SitioAdminModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar sitio'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: disponibles.length,
            itemBuilder: (context, index) {
              final sitio = disponibles[index];

              return ListTile(
                leading: const Icon(
                  Icons.landscape_outlined,
                  color: AppColors.primary,
                ),
                title: Text(sitio.nombre),
                subtitle: Text(sitio.ciudad),
                onTap: () => Navigator.pop(context, sitio),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (sitio != null && mounted) {
      await _abrirFormulario(sitio: sitio);
    }
  }
}