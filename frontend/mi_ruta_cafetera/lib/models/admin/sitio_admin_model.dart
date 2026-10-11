
import '../categoria_model.dart';

class SitioAdminModel {
  final String id;
  final String nombre;
  final String descripcion;
  final CategoriaModel? categoria;
  final String direccion;
  final String ciudad;
  final String departamento;
  final double latitud;
  final double longitud;
  final List<String> etiquetas;
  final bool activo;
  final String telefono;
  final String correos;
  final String sitioWeb;
  final String imagen;
  final List<String> imagenes;
  final String horario;
  final double precioDesde;

  const SitioAdminModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.direccion,
    required this.ciudad,
    required this.departamento,
    required this.latitud,
    required this.longitud,
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

  factory SitioAdminModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic categoriaData = json['categoria'];

    CategoriaModel? categoria;

    if (categoriaData is Map) {
      categoria = CategoriaModel.fromJson(
        Map<String, dynamic>.from(categoriaData),
      );
    } else if (categoriaData != null) {
      final categoriaId = _stringValue(categoriaData);

      if (categoriaId.isNotEmpty) {
        categoria = CategoriaModel(
          id: categoriaId,
          nombre: '',
          descripcion: '',
          icono: '',
          activo: true,
          estado: true,
        );
      }
    }

    return SitioAdminModel(
      id: _stringValue(json['_id'] ?? json['id']),
      nombre: _stringValue(json['nombre']),
      descripcion: _stringValue(json['descripcion']),
      categoria: categoria,
      direccion: _stringValue(json['direccion']),
      ciudad: _stringValue(
        json['ciudad'],
        fallback: 'Garzón',
      ),
      departamento: _stringValue(
        json['departamento'],
        fallback: 'Huila',
      ),
      latitud: _toDouble(json['latitud']),
      longitud: _toDouble(json['longitud']),
      etiquetas: _toStringList(json['etiquetas']),
      activo: _toBool(json['activo'] ?? json['estado']),
      telefono: _stringValue(json['telefono']),
      correos: _stringValue(json['correos']),
      sitioWeb: _stringValue(json['sitioWeb']),
      imagen: _stringValue(json['imagen']),
      imagenes: _toStringList(json['imagenes']),
      horario: _stringValue(json['horario']),
      precioDesde: _toDouble(json['precioDesde']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria == null
          ? null
          : {
              'id': categoria!.id,
              'nombre': categoria!.nombre,
              'descripcion': categoria!.descripcion,
              'icono': categoria!.icono,
              'activo': categoria!.activo,
              'estado': categoria!.estado,
            },
      'direccion': direccion,
      'ciudad': ciudad,
      'departamento': departamento,
      'latitud': latitud,
      'longitud': longitud,
      'etiquetas': etiquetas,
      'activo': activo,
      'telefono': telefono,
      'correos': correos,
      'sitioWeb': sitioWeb,
      'imagen': imagen,
      'imagenes': imagenes,
      'horario': horario,
      'precioDesde': precioDesde,
    };
  }

  static String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    if (value is Map && value[r'$oid'] != null) {
      return value[r'$oid'].toString();
    }

    final texto = value.toString().trim();

    return texto.isEmpty ? fallback : texto;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is Map) {
      value = value[r'$numberDouble'] ?? value[r'$numberInt'];
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }

    return [];
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      return value.toLowerCase().trim() == 'true';
    }

    return true;
  }

  @override
  String toString() {
    return 'SitioAdminModel(id: $id, nombre: $nombre)';
  }
}
