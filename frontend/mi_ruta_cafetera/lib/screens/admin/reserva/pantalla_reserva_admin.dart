
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
import '../../../widgets/admin/reserva/resumen_reservas.dart';

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
    final consulta = busqueda.toLowerCase().trim();

    return controller.reservas.where((reserva) {
      final coincideBusqueda =
          reserva.nombreUsuario.toLowerCase().contains(consulta) ||
          reserva.nombreSitio.toLowerCase().contains(consulta) ||
          reserva.nombreActividad.toLowerCase().contains(consulta);

      final coincideEstado = estadoSeleccionado == 'Todas' ||
          reserva.estado.trim().toLowerCase() ==
              estadoSeleccionado.toLowerCase();

      return coincideBusqueda && coincideEstado;
    }).toList();
  }

  int _contarEstado(String estado) {
    return controller.reservas.where((reserva) {
      return reserva.estado.trim().toLowerCase() == estado;
    }).length;
  }

  void limpiarBusqueda() {
    busquedaController.clear();
    setState(() => busqueda = '');
  }

  Future<void> abrirDetalle(ReservaAdminModel reserva) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final actual = controller.reservas.firstWhere(
              (item) => item.id == reserva.id,
              orElse: () => reserva,
            );

            return Dialog(
              backgroundColor: AppColors.creamLight,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 32,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
                side: const BorderSide(
                  color: Color(0xFFB58A70),
                  width: 1.3,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 370,
                  maxHeight: 620,
                ),
                child: DetalleReservaAdmin(
                  reserva: actual,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _construirListaReservas(
    List<ReservaAdminModel> reservas,
  ) {
    if (controller.cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 55),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (reservas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 45),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_busy_rounded,
                color: AppColors.secondary,
                size: 42,
              ),
              const SizedBox(height: 10),
              Text(
                'No se encontraron reservas',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: reservas.map((reserva) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            12,
            0,
            12,
            14,
          ),
          child: TarjetaReservaAdmin(
            reserva: reserva,
            onTap: () => abrirDetalle(reserva),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final reservas = reservasFiltradas;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: controller.cargarReservas,
            color: AppColors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                EncabezadoLista(
                  titulo: '',
                  descripcion: 'reservas registradas',
                  textoNuevo: '',
                  cantidad: controller.reservas.length,
                  cargando: false,
                  mostrarBotonNuevo: false,
                  onActualizar: controller.cargarReservas,
                  onNuevo: () {},
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                ResumenReservas(
                  todas: controller.reservas.length,
                  pendientes: _contarEstado('pendiente'),
                  confirmadas: _contarEstado('confirmada'),
                  rechazadas: _contarEstado('rechazada'),
                  canceladas: _contarEstado('cancelada'),
                  completadas: _contarEstado('completada'),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                BarraBusqueda(
                  valor: busqueda,
                  textoAyuda:
                      'Buscar usuario, sitio o actividad...',
                  controller: busquedaController,
                  onChanged: (valor) {
                    setState(() => busqueda = valor);
                  },
                  onLimpiar: limpiarBusqueda,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                FiltroEstadoReserva(
                  estadoSeleccionado: estadoSeleccionado,
                  onChanged: (estado) {
                    setState(() => estadoSeleccionado = estado);
                  },
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                if (controller.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.pageHorizontalSmall,
                      vertical: AppDimensions.spacingSm,
                    ),
                    child: Text(
                      controller.error!,
                      style: const TextStyle(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppDimensions.spacingSm,
                    bottom: AppDimensions.spacingXxl,
                  ),
                  child: _construirListaReservas(reservas),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
