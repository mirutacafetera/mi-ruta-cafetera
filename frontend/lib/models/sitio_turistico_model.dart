import 'package:latlong2/latlong.dart';

class SitioTuristicoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String ciudad;
  final String departamento;

  final double latitud;
  final double longitud;

  final CategoriaReferencia? categoria;

  final bool activo;

  const SitioTuristicoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.ciudad,
    required this.departamento,
    required this.latitud,
    required this.longitud,
    required this.categoria,
    required this.activo,
  });

  bool get tieneCoordenadas {
    return latitud >= -90 &&
        latitud <= 90 &&
        longitud >= -180 &&
        longitud <= 180 &&
        !(latitud == 0 && longitud == 0);
  }

  LatLng get ubicacion {
    return LatLng(
      latitud,
      longitud,
    );
  }

  String get categoriaId {
    return categoria?.id ?? '';
  }

  String get categoriaNombre {
    return categoria?.nombre ?? '';
  }

  factory SitioTuristicoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final dynamic categoriaJson =
        json['categoria'] ??
        json['categoriaId'] ??
        json['categoria_id'];

    CategoriaReferencia? categoria;

    if (categoriaJson is Map) {
      categoria = CategoriaReferencia.fromJson(
        Map<String, dynamic>.from(categoriaJson),
      );
    } else if (categoriaJson != null) {
      categoria = CategoriaReferencia(
        id: categoriaJson.toString(),
        nombre: '',
      );
    }

    return SitioTuristicoModel(
      id: _string(
        json['_id'] ?? json['id'],
      ),
      nombre: _string(
        json['nombre'],
        fallback: 'Sin nombre',
      ),
      descripcion: _string(
        json['descripcion'],
        fallback: 'Sin descripción',
      ),
      direccion: _string(
        json['direccion'],
      ),
      ciudad: _string(
        json['ciudad'],
        fallback: 'Garzón',
      ),
      departamento: _string(
        json['departamento'],
        fallback: 'Huila',
      ),
      latitud: _double(
        json['latitud'],
      ),
      longitud: _double(
        json['longitud'],
      ),
      categoria: categoria,
      activo: _bool(
        json['activo'],
        fallback: true,
      ),
    );
  }

  static String _string(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final texto = value.toString().trim();

    return texto.isEmpty ? fallback : texto;
  }

  static double _double(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    if (value is Map) {
      final dynamic interno =
          value[r'$numberDouble'] ??
          value['value'];

      if (interno is num) {
        return interno.toDouble();
      }

      if (interno != null) {
        return double.tryParse(
              interno.toString(),
            ) ??
            0;
      }
    }

    return 0;
  }

  static bool _bool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase() == 'true';
    }

    return fallback;
  }
}

class CategoriaReferencia {
  final String id;
  final String nombre;

  const CategoriaReferencia({
    required this.id,
    required this.nombre,
  });

  factory CategoriaReferencia.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoriaReferencia(
      id: _string(
        json['_id'] ?? json['id'],
      ),
      nombre: _string(
        json['nombre'],
      ),
    );
  }

  static String _string(
    dynamic value,
  ) {
    return value?.toString().trim() ?? '';
  }
}