import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapaScreen extends StatefulWidget {
  const MapaScreen({Key? key}) : super(key: key);

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  List<Marker> _markers = [];
  bool _cargando = true;

  // Detecta si corre en Web o en Emulador Android
  String get _apiUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api/sitiosturisticos';
    } else {
      return 'http://10.0.2.2:3000/api/sitiosturisticos';
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarSitiosDesdeMongo();
  }

  Future<void> _cargarSitiosDesdeMongo() async {
    setState(() => _cargando = true);
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> datos = json.decode(response.body);

        final List<Marker> marcadoresCargados = datos.map((sitio) {
          final double lat = double.tryParse(sitio['latitud'].toString()) ?? 0.0;
          final double lng = double.tryParse(sitio['longitud'].toString()) ?? 0.0;
          final String nombre = sitio['nombre'] ?? 'Sin nombre';
          final String descripcion = sitio['descripcion'] ?? '';

          return Marker(
            point: LatLng(lat, lng),
            width: 45,
            height: 45,
            child: GestureDetector(
              onTap: () => _mostrarDetallesSitio(nombre, descripcion),
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 45,
              ),
            ),
          );
        }).toList();

        setState(() {
          _markers = marcadoresCargados;
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint('Error al consultar sitios: $e');
      setState(() => _cargando = false);
    }
  }

  void _mostrarDetallesSitio(String nombre, String descripcion) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nombre,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(descripcion),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Ruta Cafetera'),
        backgroundColor: const Color(0xFF6F4E37),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarSitiosDesdeMongo,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(2.1959, -75.6278), // Garzón, Huila
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mirutacafetera.app',
              ),
              // Renderiza los pines traídos de MongoDB
              MarkerLayer(markers: _markers),
            ],
          ),
          if (_cargando)
            Positioned(
              top: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}