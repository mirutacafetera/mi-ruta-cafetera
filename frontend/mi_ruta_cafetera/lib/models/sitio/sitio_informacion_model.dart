class SitioInformacionModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String ciudad;
  final String departamento;
  final double latitud;
  final double longitud;
  final String categoria;
  final List<String> etiquetas;
  final bool activo;
  final String telefono;
  final List<String> correos;
  final String sitioWeb;
  final String imagen;
  final List<String> imagenes;
  final String horario;
  final double precioDesde;

  SitioInformacionModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.ciudad,
    required this.departamento,
    required this.latitud,
    required this.longitud,
    required this.categoria,
    required this.etiquetas,
    required this.activo,
    required this.telefono,
    required this.correos,
    required this.sitioWeb,
    required this.imagen,
    required this.imagenes,
    required this.horario,
    required this.precioDesde,
  });

  factory SitioInformacionModel.fromJson(Map<String, dynamic> json) {
    final categoriaData = json['categoria'];

    String categoriaNombre = '';

    if (categoriaData is Map<String, dynamic>) {
      categoriaNombre =
          categoriaData['nombre']?.toString() ??
          categoriaData['name']?.toString() ??
          '';
    } else if (categoriaData != null) {
      categoriaNombre = categoriaData.toString();
    }

    return SitioInformacionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      ciudad: json['ciudad']?.toString() ?? '',
      departamento: json['departamento']?.toString() ?? '',
      latitud: _toDouble(json['latitud']),
      longitud: _toDouble(json['longitud']),
      categoria: categoriaNombre,
      etiquetas: _toStringList(json['etiquetas']),
      activo: json['activo'] == true,
      telefono: json['telefono']?.toString() ?? '',
      correos: _toStringList(json['correos']),
      sitioWeb: json['sitioWeb']?.toString() ?? '',
      imagen: json['imagen']?.toString() ?? '',
      imagenes: _toStringList(json['imagenes']),
      horario: json['horario']?.toString() ?? '',
      precioDesde: _toDouble(json['precioDesde']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'ciudad': ciudad,
      'departamento': departamento,
      'latitud': latitud,
      'longitud': longitud,
      'telefono': telefono,
      'correos': correos.join(', '),
      'sitioWeb': sitioWeb,
      'horario': horario,
      'precioDesde': precioDesde,
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }

    return [];
  }
}