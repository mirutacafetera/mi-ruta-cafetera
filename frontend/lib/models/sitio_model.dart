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

  factory SitioTuristico.fromJson(Map<String, dynamic> json) {
    // Manejo flexible para categoria (si Express hace .populate('categoria') o si envía solo el ID)
    String categoriaNombre = '';
    if (json['categoria'] != null) {
      if (json['categoria'] is Map) {
        categoriaNombre = json['categoria']['nombre'] ?? '';
      } else {
        categoriaNombre = json['categoria'].toString();
      }
    }

    // Extraer latitud y longitud directamente de la BD
    final double lat = (json['latitud'] as num?)?.toDouble() ?? 0.0;
    final double lng = (json['longitud'] as num?)?.toDouble() ?? 0.0;

    return SitioTuristico(
      id: json['_id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: categoriaNombre,
      direccion: json['direccion'] ?? '',
      ciudad: json['ciudad'] ?? 'Garzón',
      departamento: json['departamento'] ?? 'Huila',
      ubicacion: LatLng(lat, lng),
      telefono: json['telefono'] ?? '',
      correo: json['correo'] ?? '',
      sitioWeb: json['sitioWeb'] ?? '',
      imagen: json['imagen'] ?? '',
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'])
          : [],
      horario: json['horario'] ?? '',
      precioDesde: (json['precioDesde'] as num?)?.toDouble() ?? 0.0,
      activo: json['activo'] ?? true,
    );
  }
}