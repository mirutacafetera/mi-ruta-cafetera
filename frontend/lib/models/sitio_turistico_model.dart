import 'package:latlong2/latlong.dart';

import 'categoria_model.dart';

class SitioTuristicoModel {
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

  const SitioTuristicoModel({
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
  });

  LatLng get ubicacion {
    return LatLng(
      latitud,
      longitud,
    );
  }

  factory SitioTuristicoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    CategoriaModel? categoria;

    final categoriaJson =
        json['categoria'];

    if (categoriaJson
        is Map<String, dynamic>) {
      categoria =
          CategoriaModel.fromJson(
        categoriaJson,
      );
    } else if (categoriaJson is Map) {
      categoria =
          CategoriaModel.fromJson(
        Map<String, dynamic>.from(
          categoriaJson,
        ),
      );
    }

    return SitioTuristicoModel(
      id: _stringValue(
        json['_id'] ?? json['id'],
      ),

      nombre: _stringValue(
        json['nombre'],
        fallback: 'Sin nombre',
      ),

      descripcion: _stringValue(
        json['descripcion'],
        fallback:
            'Sin descripción disponible.',
      ),

      categoria: categoria,

      direccion: _stringValue(
        json['direccion'],
      ),

      ciudad: _stringValue(
        json['ciudad'],
        fallback: 'Garzón',
      ),

      departamento: _stringValue(
        json['departamento'],
        fallback: 'Huila',
      ),

      latitud:
          _doubleValue(json['latitud']),

      longitud:
          _doubleValue(json['longitud']),

      etiquetas:
          _stringList(json['etiquetas']),

      // ==================================================
      // Mongo usa "activo"
      // ==================================================
      activo:
          json['activo'] is bool
              ? json['activo'] as bool
              : json['estado'] is bool
                  ? json['estado'] as bool
                  : true,
    );
  }

  static String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final valueString =
        value.toString().trim();

    if (valueString.isEmpty) {
      return fallback;
    }

    return valueString;
  }

  static double _doubleValue(
    dynamic value,
  ) {
    if (value == null) {
      return 0.0;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  static List<String> _stringList(
    dynamic value,
  ) {
    if (value is! List) {
      return [];
    }

    return value
        .where(
          (item) => item != null,
        )
        .map(
          (item) => item
              .toString()
              .trim(),
        )
        .where(
          (item) => item.isNotEmpty,
        )
        .toList();
  }
}