import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../models/sitio_model.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  List<SitioTuristico> sitios = [];
  bool isLoading = true;

  // Modifica la URL según tu entorno de ejecución:
  // - Emulador Android: 'http://10.0.2.2:3000/api/sitios' (o tu ruta configurada en Express)
  // - Dispositivo físico: IP local (ej: 'http://192.168.1.X:3000/api/sitios')
  final String apiUrl = 'http://10.0.2.2:3000/api/sitios';

  @override
  void initState() {
    super.initState();
    _cargarSitios();
  }

  Future<void> _cargarSitios() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // Parsear y filtrar solo los sitios que estén activos
          sitios = data
              .map((item) => SitioTuristico.fromJson(item))
              .where((sitio) => sitio.activo)
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar datos del servidor');
      }
    } catch (e) {
      print('Error de conexión con la API: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Centro del mapa por defecto (Garzón, Huila)
    final LatLng centroInicial = const LatLng(2.1959, -75.6278);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Ruta Cafetera'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _cargarSitios();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: centroInicial,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.mirutacafetera.app',
                ),
                MarkerLayer(
                  markers: sitios.map((sitio) {
                    return Marker(
                      point: sitio.ubicacion,
                      width: 45,
                      height: 45,
                      child: GestureDetector(
                        onTap: () => _mostrarTarjetaDetalle(context, sitio),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 42,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }

  void _mostrarTarjetaDetalle(BuildContext context, SitioTuristico sitio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen si existe
              if (sitio.imagen.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    sitio.imagen,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              if (sitio.imagen.isNotEmpty) const SizedBox(height: 12),

              // Nombre y Ubicación
              Text(
                sitio.nombre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                '${sitio.ciudad}, ${sitio.departamento}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 8),

              // Categoría y Precio
              Row(
                children: [
                  if (sitio.categoria.isNotEmpty)
                    Chip(
                      label: Text(sitio.categoria),
                      backgroundColor: Colors.brown.shade50,
                    ),
                  const Spacer(),
                  if (sitio.precioDesde > 0)
                    Text(
                      'Desde: \$${sitio.precioDesde.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                sitio.descripcion,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}