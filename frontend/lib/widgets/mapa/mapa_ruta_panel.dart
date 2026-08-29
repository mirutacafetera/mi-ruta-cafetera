import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';

/// ============================================================
/// PANEL RESPONSIVE DE RUTA
/// ============================================================
///
/// Este widget NO calcula rutas.
/// No consulta APIs.
/// No modifica servicios.
///
/// Su única responsabilidad es mostrar visualmente:
/// - nombre de la ruta
/// - cantidad de sitios
/// - sitios seleccionados
/// - estado de cálculo
/// - distancia
/// - duración
/// - mensaje
///
/// La lógica continúa perteneciendo a MapaScreen.
/// ============================================================

class MapaRutaPanel extends StatelessWidget {
  final String titulo;

  final List<SitioTuristicoModel> sitios;

  final String distancia;

  final String duracion;

  final String mensaje;

  final bool calculando;

  final Color colorRuta;

  final VoidCallback onCerrar;

  final VoidCallback? onGenerarRuta;

  final bool mostrarBotonGenerar;

  const MapaRutaPanel({
    super.key,
    required this.titulo,
    required this.sitios,
    required this.distancia,
    required this.duracion,
    required this.mensaje,
    required this.calculando,
    required this.colorRuta,
    required this.onCerrar,
    this.onGenerarRuta,
    this.mostrarBotonGenerar = false,
  });

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final ancho = mediaQuery.size.width;
    final alto = mediaQuery.size.height;

    final bool pantallaPequena = ancho < 600;
    final bool pantallaMuyPequena = alto < 650;

    final double margenHorizontal =
        pantallaPequena ? 10 : 16;

    final double margenInferior =
        pantallaMuyPequena ? 8 : 14;

    final double radio =
        pantallaPequena ? 18 : 22;

    final double padding =
        pantallaPequena ? 12 : 16;

    final double maxAltura =
        pantallaPequena
            ? alto * 0.32
            : alto * 0.38;

    return Positioned(
      left: margenHorizontal,
      right: margenHorizontal,
      bottom: margenInferior,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxAltura,
        ),
        child: Material(
          elevation: 10,
          color: Colors.white,
          borderRadius: BorderRadius.circular(radio),
          clipBehavior: Clip.antiAlias,
          child: _contenido(
            context,
            pantallaPequena,
            pantallaMuyPequena,
            padding,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTENIDO
  // ============================================================

  Widget _contenido(
    BuildContext context,
    bool pantallaPequena,
    bool pantallaMuyPequena,
    double padding,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cabecera(
              pantallaPequena,
            ),

            const SizedBox(height: 8),

            if (sitios.isNotEmpty)
              _recorrido(
                pantallaPequena,
              ),

            if (calculando) ...[
              const SizedBox(height: 8),
              _estadoCalculando(),
            ],

            if (!calculando &&
                distancia.isNotEmpty &&
                duracion.isNotEmpty) ...[
              const SizedBox(height: 10),
              _resumenRuta(
                pantallaPequena,
              ),
            ],

            if (mensaje.trim().isNotEmpty) ...[
              const SizedBox(height: 7),
              _mensaje(),
            ],

            if (mostrarBotonGenerar &&
                onGenerarRuta != null) ...[
              const SizedBox(height: 10),
              _botonGenerar(
                pantallaPequena,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CABECERA
  // ============================================================

  Widget _cabecera(
    bool pantallaPequena,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: pantallaPequena ? 40 : 46,
          height: pantallaPequena ? 40 : 46,
          decoration: BoxDecoration(
            color: colorRuta,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${sitios.length}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: pantallaPequena ? 15 : 17,
            ),
          ),
        ),

        SizedBox(
          width: pantallaPequena ? 9 : 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize:
                      pantallaPequena ? 15 : 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3E2A20),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                sitios.isEmpty
                    ? 'Sin sitios seleccionados'
                    : '${sitios.length} '
                        '${sitios.length == 1 ? 'sitio' : 'sitios'} seleccionados',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize:
                      pantallaPequena ? 11 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 4),

        IconButton(
          tooltip: 'Cerrar ruta',
          visualDensity: VisualDensity.compact,
          onPressed: onCerrar,
          icon: Icon(
            Icons.close,
            size: pantallaPequena ? 21 : 23,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RECORRIDO
  // ============================================================

  Widget _recorrido(
    bool pantallaPequena,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: pantallaPequena ? 9 : 12,
        vertical: pantallaPequena ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.route,
                size: pantallaPequena ? 17 : 19,
                color: colorRuta,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  'Recorrido',
                  style: TextStyle(
                    fontSize:
                        pantallaPequena ? 11 : 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            _textoRecorrido(),
            maxLines: pantallaPequena ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize:
                  pantallaPequena ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3E2A20),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXTO DEL RECORRIDO
  // ============================================================

  String _textoRecorrido() {
    if (sitios.isEmpty) {
      return '';
    }

    return sitios
        .map(
          (sitio) {
            final ciudad = sitio.ciudad.trim();

            if (ciudad.isNotEmpty) {
              return ciudad;
            }

            return sitio.nombre;
          },
        )
        .join(' → ');
  }

  // ============================================================
  // ESTADO CALCULANDO
  // ============================================================

  Widget _estadoCalculando() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: const LinearProgressIndicator(
            minHeight: 4,
          ),
        ),

        const SizedBox(height: 7),

        Row(
          children: [
            const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: Text(
                'Calculando recorrido por carretera...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // RESUMEN DE RUTA
  // ============================================================

  Widget _resumenRuta(
    bool pantallaPequena,
  ) {
    return Row(
      children: [
        Expanded(
          child: _datoRuta(
            icono: Icons.route,
            valor: distancia,
            titulo: 'Distancia',
            color: colorRuta,
            pantallaPequena: pantallaPequena,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _datoRuta(
            icono: Icons.access_time,
            valor: duracion,
            titulo: 'Tiempo estimado',
            color: colorRuta,
            pantallaPequena: pantallaPequena,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DATO INDIVIDUAL
  // ============================================================

  Widget _datoRuta({
    required IconData icono,
    required String valor,
    required String titulo,
    required Color color,
    required bool pantallaPequena,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: pantallaPequena ? 9 : 12,
        vertical: pantallaPequena ? 8 : 10,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icono,
            size: pantallaPequena ? 19 : 21,
            color: color,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                        pantallaPequena ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color:
                        const Color(0xFF30251F),
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  titulo,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:
                        pantallaPequena ? 9 : 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MENSAJE
  // ============================================================

  Widget _mensaje() {
    return Text(
      mensaje,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade700,
        height: 1.25,
      ),
    );
  }

  // ============================================================
  // BOTÓN GENERAR
  // ============================================================

  Widget _botonGenerar(
    bool pantallaPequena,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onGenerarRuta,
        icon: Icon(
          Icons.route,
          size: pantallaPequena ? 18 : 20,
        ),
        label: Text(
          'GENERAR RUTA (${sitios.length} sitios)',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize:
                pantallaPequena ? 12 : 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorRuta,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(
            double.infinity,
            pantallaPequena ? 42 : 46,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: pantallaPequena ? 9 : 11,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }
}