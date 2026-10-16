import 'package:flutter/material.dart';

import '../../../controllers/admin/reserva/reserva_admin_controller.dart';
import '../../../models/admin/reserva_admin_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/sitio_turistico/encabezado_lista.dart';
import '../../../widgets/admin/sitio_turistico/barra_busqueda.dart';
import '../../../widgets/admin/reserva/tarjeta_reserva_admin.dart';
import '../../../widgets/admin/reserva/filtro_estado_reserva.dart';
import '../../../widgets/admin/reserva/detalle_reserva_admin.dart';

class PantallaReservaAdmin extends StatefulWidget {
  const PantallaReservaAdmin({super.key});

  @override
  State<PantallaReservaAdmin> createState() =>
      _PantallaReservaAdminState();
}

class _PantallaReservaAdminState extends State<PantallaReservaAdmin> {
  late final ReservaAdminController controller;
  final TextEditingController busquedaController =
      TextEditingController();

  String busqueda = '';
  String estadoSeleccionado = 'Todas';

  @override
  void initState() {
    super.initState();
    controller = ReservaAdminController();
    controller.cargarReservas();
  }

  @override
  void dispose() {
    controller.dispose();
    busquedaController.dispose();
    super.dispose();
  }

  List<ReservaAdminModel> get reservasFiltradas {
    return controller.reservas.where((reserva) {
      final consulta = busqueda.toLowerCase().trim();

      final coincideBusqueda = reserva.nombreUsuario
              .toLowerCase()
              .contains(consulta) ||
          reserva.nombreSitio.toLowerCase().contains(consulta) ||
          reserva.nombreActividad.toLowerCase().contains(consulta);

      final coincideEstado = estadoSeleccionado == 'Todas' ||
          reserva.estado.toLowerCase() ==
              estadoSeleccionado.toLowerCase();

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  void limpiarBusqueda() {
    busquedaController.clear();
    setState(() => busqueda = '');
  }

  Future<void> abrirDetalle(ReservaAdminModel reserva) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final actual = controller.reservas.firstWhere(
              (item) => item.id == reserva.id,
              orElse: () => reserva,
            );

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: DetalleReservaAdmin(
                  reserva: actual,
                  guardando: controller.guardando,
                  onCambiarEstado: (estado) async {
                    final exito = await controller.actualizarEstado(
                      id: actual.id,
                      estado: estado,
                    );

                    if (!mounted || !context.mounted) return;

                    if (exito) {
                      Navigator.pop(context);
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Estado actualizado correctamente'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            controller.error ?? 'No se pudo actualizar',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final reservas = reservasFiltradas;

        return Scaffold(
          body: Column(
            children: [
              EncabezadoLista(
                titulo: 'Reservas',
                descripcion: 'reservas registradas',
                textoNuevo: '',
                cantidad: controller.reservas.length,
                cargando: controller.cargando,
                mostrarBotonNuevo: false,
                onActualizar: controller.cargarReservas,
                onNuevo: () {},
              ),
              BarraBusqueda(
                valor: busqueda,
                textoAyuda: 'Buscar usuario, sitio o actividad...',
                controller: busquedaController,
                onChanged: (valor) {
                  setState(() => busqueda = valor);
                },
                onLimpiar: limpiarBusqueda,
              ),
              FiltroEstadoReserva(
                estadoSeleccionado: estadoSeleccionado,
                onChanged: (estado) {
                  setState(() => estadoSeleccionado = estado);
                },
              ),
              if (controller.error != null)
                Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingMd),
                  child: Text(
                    controller.error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              Expanded(
                child: controller.cargando
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : reservas.isEmpty
                        ? const Center(
                            child: Text('No se encontraron reservas'),
                          )
                        : RefreshIndicator(
                            onRefresh: controller.cargarReservas,
                            child: ListView.builder(
                              padding: EdgeInsets.all(
                                AppDimensions.spacingMd,
                              ),
                              itemCount: reservas.length,
                              itemBuilder: (context, index) {
                                final reserva = reservas[index];

                                return TarjetaReservaAdmin(
                                  reserva: reserva,
                                  onTap: () => abrirDetalle(reserva),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}