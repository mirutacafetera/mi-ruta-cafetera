import 'package:flutter/material.dart';

import '../../../controllers/admin/cuenta_sitio/cuenta_sitio_controller.dart';
import '../../../models/admin/cuenta_sitio_model.dart';
import '../../../models/admin/sitio_admin_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/cuenta_sitio/filtros_cuenta_sitio.dart';
import '../../../widgets/admin/cuenta_sitio/resumen_cuenta_sitio.dart';
import '../../../widgets/admin/cuenta_sitio/tarjeta_cuenta_sitio.dart';
import '../../../widgets/admin/cuenta_sitio/formulario_cuenta_sitio.dart';
import '../../../widgets/admin/cuenta_sitio/selector_sitio_cuenta.dart';
import '../../../widgets/admin/cuenta_sitio/verificar_codigo_cuenta_sitio.dart';
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

  bool _actualizando = false;

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

  // =====================================================
  // CARGAR DATOS
  // =====================================================

  Future<void> _cargarDatos() async {
    if (_actualizando) return;

    setState(() => _actualizando = true);

    try {
      await _controller.cargarDatos(token: widget.token);
    } catch (e) {
      _mostrarMensaje('No se pudieron actualizar los datos: $e');
    } finally {
      if (mounted) {
        setState(() => _actualizando = false);
      }
    }
  }

  // =====================================================
  // MOSTRAR MENSAJES
  // =====================================================

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // =====================================================
  // DIÁLOGO REUTILIZABLE PARA VERIFICAR CÓDIGOS
  // =====================================================

  Future<bool?> _mostrarDialogoCodigo({
    required String correo,
    required String titulo,
    required String descripcion,
    required String textoBoton,
    required Future<void> Function(String codigo) onVerificar,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => VerificarCodigoCuentaSitio(
        correo: correo,
        titulo: titulo,
        descripcion: descripcion,
        textoBoton: textoBoton,
        onVerificar: onVerificar,
      ),
    );
  }

  // =====================================================
  // ABRIR FORMULARIO
  // =====================================================

  Future<void> _abrirFormulario({
    required SitioAdminModel sitio,
    CuentaSitioModel? cuenta,
  }) async {
    String? correoCreado;

    // Variable final para conservar la referencia de la cuenta.
    final CuentaSitioModel? cuentaActual = cuenta;

    final resultado = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (contextFormulario) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(contextFormulario).viewInsets.bottom,
          ),
          child: FormularioCuentaSitio(
            cuenta: cuentaActual,
            cargando: _controller.guardando,
            onGuardar: (datos) async {
              try {
                // =========================================
                // CREAR CUENTA
                // =========================================

                if (cuentaActual == null) {
                  await _controller.crearCuenta(
                    sitioId: sitio.id,
                    nombre: datos['nombre']!,
                    apellido: datos['apellido']!,
                    correo: datos['correo']!,
                    password: datos['password']!,
                    telefono: datos['telefono']!,
                  );

                  correoCreado = datos['correo']!.trim();

                  if (contextFormulario.mounted) {
                    Navigator.of(contextFormulario).pop(true);
                  }

                  return;
                }

                // Desde aquí la cuenta existe.
                final cuentaEdicion = cuentaActual;

                // =========================================
                // EDITAR CUENTA
                // =========================================

                final correoNuevo = datos['correo']!.trim();
                final correoOriginal = cuentaEdicion.correo.trim();
                final passwordNuevo = datos['password'] ?? '';

                final correoCambio = correoNuevo.toLowerCase() !=
                    correoOriginal.toLowerCase();

                final passwordCambio = passwordNuevo.isNotEmpty;

                if (correoCambio && !passwordCambio) {
                  throw Exception(
                    'Para cambiar el correo debes ingresar una contraseña. '
                    'Puedes escribir la contraseña actual.',
                  );
                }

                // =========================================
                // SOLICITAR CÓDIGO DE AUTORIZACIÓN
                // =========================================

                if (correoCambio || passwordCambio) {
                  final respuesta =
                      await _controller.solicitarCodigoCambioCuenta(
                    cuentaId: cuentaEdicion.id,
                    correo: correoCambio ? correoNuevo : null,
                    password: passwordCambio ? passwordNuevo : null,
                  );

                  final correoDestino =
                      respuesta['correoDestino']?.toString() ??
                          (correoCambio ? correoNuevo : correoOriginal);

                  if (!contextFormulario.mounted) return;

                  // Cierra el formulario.
                  // La pantalla principal permanece debajo.
                  Navigator.of(contextFormulario).pop({
                    'tipo': 'autorizar',
                    'datos': Map<String, String>.from(datos),
                    'correoDestino': correoDestino,
                  });

                  return;
                }

                // =========================================
                // ACTUALIZAR SOLO DATOS PERSONALES
                // =========================================

                await _controller.actualizarCuenta(
                  cuentaId: cuentaEdicion.id,
                  nombre: datos['nombre']!,
                  apellido: datos['apellido']!,
                  correo: correoNuevo,
                  telefono: datos['telefono']!,
                );

                if (contextFormulario.mounted) {
                  Navigator.of(contextFormulario).pop(true);
                }
              } catch (e) {
                _mostrarMensaje('No se pudo guardar: $e');
              }
            },
          ),
        ),
      ),
    );

    if (!mounted) return;

    // =====================================================
    // MOSTRAR AUTORIZACIÓN SOBRE LA PANTALLA PRINCIPAL
    // =====================================================

    if (resultado is Map && resultado['tipo'] == 'autorizar') {
      // Comprobamos que realmente sea una edición.
      final cuentaEdicion = cuentaActual;

      if (cuentaEdicion == null) return;

      final datos = Map<String, String>.from(
        resultado['datos'] as Map,
      );

      final correoDestino =
          resultado['correoDestino']?.toString() ?? '';

      // El formulario ya está cerrado.
      // El diálogo aparece encima de Cuentas de sitios turísticos.
      final verificado = await _mostrarDialogoCodigo(
        correo: correoDestino,
        titulo: 'Autorizar cambios',
        descripcion:
            'Hemos enviado un código de autorización para '
            'confirmar los cambios de acceso de la cuenta.',
        textoBoton: 'Confirmar cambios',
        onVerificar: (codigo) async {
          await _controller.verificarCodigoCambioCuenta(
            cuentaId: cuentaEdicion.id,
            codigo: codigo,
          );
        },
      );

      if (verificado != true || !mounted) return;

      try {
        // El correo y la contraseña ya fueron autorizados.
        // Ahora se actualizan los demás datos de la cuenta.

        await _controller.actualizarCuenta(
          cuentaId: cuentaEdicion.id,
          nombre: datos['nombre']!,
          apellido: datos['apellido']!,
          correo: datos['correo']!,
          telefono: datos['telefono']!,
        );

        await _cargarDatos();

        if (mounted) {
          _mostrarMensaje('Cuenta actualizada correctamente');
        }
      } catch (e) {
        _mostrarMensaje('No se pudo guardar: $e');
      }

      return;
    }

    // =====================================================
    // RESULTADO DE CREAR O ACTUALIZAR CUENTA
    // =====================================================

    if (resultado == true && mounted) {
      await _cargarDatos();

      // =========================================
      // VERIFICAR CORREO DE CUENTA RECIÉN CREADA
      // =========================================

      if (cuentaActual == null && correoCreado != null) {
        _mostrarMensaje(
          'Cuenta creada. Se envió un código a $correoCreado',
        );

        final verificada = await _mostrarDialogoCodigo(
          correo: correoCreado!,
          titulo: 'Verificar correo',
          descripcion:
              'Hemos enviado un código de verificación '
              'al correo electrónico del sitio.',
          textoBoton: 'Verificar correo',
          onVerificar: (codigo) async {
            await _controller.verificarCorreo(
              correo: correoCreado!,
              codigo: codigo,
            );
          },
        );

        if (!mounted) return;

        if (verificada == true) {
          _mostrarMensaje('¡Correo verificado correctamente!');
        } else {
          _mostrarMensaje(
            'La cuenta quedó pendiente de verificación del correo.',
          );
        }
      } else {
        _mostrarMensaje('Cuenta actualizada correctamente');
      }
    }
  }

  // =====================================================
  // CAMBIAR ESTADO
  // =====================================================

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

  // =====================================================
  // ELIMINAR SITIO
  // =====================================================

  Future<void> _eliminarSitio(SitioAdminModel sitio) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar sitio turístico'),
        content: Text(
          '¿Deseas eliminar "${sitio.nombre}" y su cuenta asociada? '
          'Esta acción no se puede deshacer.',
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

  // =====================================================
  // CREAR CUENTA
  // =====================================================

  Future<void> _crearCuenta() async {
    final disponibles = _controller.sitios
        .where((sitio) => _controller.cuentaDeSitio(sitio.id) == null)
        .toList();

    if (disponibles.isEmpty) {
      _mostrarMensaje('Todos los sitios tienen una cuenta asociada');
      return;
    }

    await _seleccionarSitio(disponibles);
  }

  Future<void> _seleccionarSitio(
    List<SitioAdminModel> disponibles,
  ) async {
    final sitio = await SelectorSitioCuenta.mostrar(
      context: context,
      sitios: disponibles,
    );

    if (sitio != null && mounted) {
      await _abrirFormulario(sitio: sitio);
    }
  }

  // =====================================================
  // INTERFAZ PRINCIPAL
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final sitios = _controller.sitiosFiltrados;

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: _crearCuenta,
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.add_rounded, size: 32),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 90),
                children: [
                  EncabezadoLista(
                    titulo: '',
                    descripcion: 'sitios turísticos',
                    textoNuevo: '',
                    cantidad: _controller.totalSitios,
                    cargando: _actualizando || _controller.cargando,
                    mostrarBotonNuevo: false,
                    onActualizar: _cargarDatos,
                    onNuevo: () {},
                  ),

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

                  if (_actualizando)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
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
        );
      },
    );
  }
}