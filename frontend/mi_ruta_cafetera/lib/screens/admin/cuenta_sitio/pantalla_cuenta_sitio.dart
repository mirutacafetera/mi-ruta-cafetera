
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  static const Color _bordeCafe = Color(0xFFB58A70);
  static const Color _fondoCampo = Color(0xFFFFFBF6);
  static const Color _verde = AppColors.primary;
  static const Color _naranja = AppColors.secondary;

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
  // VENTANA DE VERIFICACIÓN DEL CORREO
  // =====================================================

  Future<bool?> _mostrarDialogoVerificacion({
    required String correo,
  }) async {
    final codigoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool verificando = false;

    try {
      return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                backgroundColor: AppColors.creamLight,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  side: const BorderSide(
                    color: _bordeCafe,
                    width: 1.2,
                  ),
                ),
                titlePadding: const EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  8,
                ),
                contentPadding: const EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  8,
                ),
                actionsPadding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16,
                ),
                title: Column(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: _naranja.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _naranja.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.mark_email_read_outlined,
                        color: _naranja,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Verificar correo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Hemos enviado un código de verificación '
                        'al correo electrónico del sitio.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        correo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: codigoController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 9,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Código de verificación',
                          hintText: '000000',
                          counterText: '',
                          filled: true,
                          fillColor: _fondoCampo,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: _naranja,
                          ),
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                            borderSide: const BorderSide(
                              color: _bordeCafe,
                              width: 1.6,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                            borderSide: const BorderSide(
                              color: _bordeCafe,
                              width: 1.2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.cardRadius,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Ingresa el código recibido';
                          }

                          if (valor.trim().length != 6) {
                            return 'El código debe tener 6 dígitos';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'El código tiene una vigencia de 10 minutos.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: verificando
                        ? null
                        : () {
                            Navigator.pop(dialogContext, false);
                          },
                    child: const Text(
                      'Ahora no',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: verificando
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() {
                              verificando = true;
                            });

                            try {
                              await _controller.verificarCorreo(
                                correo: correo,
                                codigo: codigoController.text.trim(),
                              );

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext, true);
                              }
                            } catch (e) {
                              if (dialogContext.mounted) {
                                setDialogState(() {
                                  verificando = false;
                                });

                                _mostrarMensaje(
                                  'No se pudo verificar el correo: $e',
                                );
                              }
                            }
                          },
                    icon: verificando
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified_outlined),
                    label: Text(
                      verificando ? 'Verificando...' : 'Verificar correo',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _verde,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          _verde.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius,
                        ),
                        side: const BorderSide(
                          color: _bordeCafe,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      codigoController.dispose();
    }
  }

  // =====================================================
  // ABRIR FORMULARIO
  // =====================================================

  Future<void> _abrirFormulario({
    required SitioAdminModel sitio,
    CuentaSitioModel? cuenta,
  }) async {
    String? correoCreado;

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
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

                  correoCreado = datos['correo']!.trim();
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
      ),
    );

    if (resultado == true && mounted) {
      await _cargarDatos();

      if (cuenta == null && correoCreado != null) {
        _mostrarMensaje(
          'Cuenta creada. Se envió un código a $correoCreado',
        );

        final verificada = await _mostrarDialogoVerificacion(
          correo: correoCreado!,
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
