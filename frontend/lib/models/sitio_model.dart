import 'package:latlong2/latlong.dart';

class SitioTuristico {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String direccion;
  final String ciudad;
  final String departamento;
  final LatLng ubicacion;
  final String telefono;
  final String correo;
  final String sitioWeb;
  final String imagen;
  final List<String> imagenes;
  final String horario;
  final double precioDesde;
  final bool activo;

  SitioTuristico({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.direccion,
    required this.ciudad,
    required this.departamento,
    required this.ubicacion,
    required this.telefono,
    required this.correo,
    required this.sitioWeb,
    required this.imagen,
    required this.imagenes,
    required this.horario,
    required this.precioDesde,
    required this.activo,
  });

  /// Función auxiliar para convertir números o Strings a double de manera segura
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory SitioTuristico.fromJson(Map<String, dynamic> json) {
    // 1. Manejo flexible para la categoría (populada o solo ID/texto)
    String categoriaNombre = '';
    if (json['categoria'] != null) {
      if (json['categoria'] is Map) {
        categoriaNombre = json['categoria']['nombre'] ?? '';
      } else {
        categoriaNombre = json['categoria'].toString();
      }
    }

    // 2. Extraer Latitud buscando en múltiples variantes posibles del JSON
    double lat = _parseDouble(
      json['latitud'] ?? 
      json['lat'] ?? 
      json['latitude'] ?? 
      (json['ubicacion'] is Map ? json['ubicacion']['lat'] : null)
    );

    // 3. Extraer Longitud buscando en múltiples variantes posibles del JSON
    double lng = _parseDouble(
      json['longitud'] ?? 
      json['lng'] ?? 
      json['longitude'] ?? 
      (json['ubicacion'] is Map ? json['ubicacion']['lng'] : null)
    );

    // 4. Extraer lista de imágenes
    List<String> listaImagenes = [];
    if (json['imagenes'] != null && json['imagenes'] is List) {
      listaImagenes = List<String>.from(
        (json['imagenes'] as List).map((item) => item.toString()),
      );
    }

    return SitioTuristico(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      categoria: categoriaNombre,
      direccion: json['direccion']?.toString() ?? '',
      ciudad: json['ciudad']?.toString() ?? 'Garzón',
      departamento: json['departamento']?.toString() ?? 'Huila',
      ubicacion: LatLng(lat, lng),
      telefono: json['telefono']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      sitioWeb: json['sitioWeb']?.toString() ?? json['web']?.toString() ?? '',
      imagen: json['imagen']?.toString() ?? json['imagenUrl']?.toString() ?? '',
      imagenes: listaImagenes,
      horario: json['horario']?.toString() ?? '',
      precioDesde: _parseDouble(json['precioDesde'] ?? json['precio']),
      activo: json['activo'] is bool ? json['activo'] : true,
    );
  }
}