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

  // ============================================================
  // UBICACIÓN PARA FLUTTER MAP
  // ============================================================

  LatLng get ubicacion {
    return LatLng(
      latitud,
      longitud,
    );
  }

    // ============================================================
  // VALIDAR COORDENADAS
  // ============================================================

  bool get tieneCoordenadas {
    return latitud != 0.0 &&
        longitud != 0.0;
  }

  // ============================================================
  // DATOS DE CATEGORÍA
  // ============================================================

  String get categoriaId {
    return categoria?.id.trim() ?? '';
  }

  String get categoriaNombre {
    return categoria?.nombre.trim() ?? '';
  }

  // ============================================================
  // JSON → MODELO
  // ============================================================

  factory SitioTuristicoModel.fromJson(
    Map<String, dynamic> json,
  ) {
    CategoriaModel? categoria;

    final dynamic categoriaJson = json['categoria'];

    if (categoriaJson is Map<String, dynamic>) {
      categoria = CategoriaModel.fromJson(
        categoriaJson,
      );
    } else if (categoriaJson is Map) {
      categoria = CategoriaModel.fromJson(
        Map<String, dynamic>.from(
          categoriaJson,
        ),
      );
    } else if (categoriaJson != null) {
      // Si el backend solamente devuelve el ID de la categoría,
      // dejamos una categoría mínima para conservar la relación.
      categoria = CategoriaModel(
        id: _stringValue(categoriaJson),
        nombre: '',
        descripcion: '',
        icono: '',
        activo: true,
        estado: true,
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
        fallback: 'Sin descripción disponible.',
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

      latitud: _doubleValue(
        json['latitud'],
      ),

      longitud: _doubleValue(
        json['longitud'],
      ),

      etiquetas: _stringList(
        json['etiquetas'],
      ),

      // MongoDB actualmente puede manejar "activo"
      // o "estado", por eso aceptamos ambos.
      activo: _bool(
        json['activo'] ?? json['estado'],
        fallback: true,
      ),
    );
  }

  // ============================================================
  // CONVERSIÓN SEGURA A STRING
  // ============================================================

  static String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    // Soporte para ObjectId serializado como:
    // { "$oid": "..." }
    if (value is Map) {
      final dynamic oid = value[r'$oid'];

      if (oid != null) {
        final String texto = oid.toString().trim();

        if (texto.isNotEmpty) {
          return texto;
        }
      }
    }

    final String texto = value.toString().trim();

    if (texto.isEmpty) {
      return fallback;
    }

    return texto;
  }

  // ============================================================
  // CONVERSIÓN SEGURA A DOUBLE
  // ============================================================

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

    // Soporte para valores MongoDB serializados
    // como objetos que contienen "$numberDouble".
    if (value is Map) {
      final dynamic numberDouble = value[r'$numberDouble'];

      if (numberDouble != null) {
        return double.tryParse(
              numberDouble.toString(),
            ) ??
            0.0;
      }

      final dynamic numberInt = value[r'$numberInt'];

      if (numberInt != null) {
        return double.tryParse(
              numberInt.toString(),
            ) ??
            0.0;
      }
    }

    return 0.0;
  }

  // ============================================================
  // LISTA DE ETIQUETAS
  // ============================================================

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
          (item) => item.toString().trim(),
        )
        .where(
          (item) => item.isNotEmpty,
        )
        .toList();
  }

  // ============================================================
  // CONVERSIÓN SEGURA A BOOLEAN
  // ============================================================

  static bool _bool(
    dynamic value, {
    bool fallback = false,
  }) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      return value.toLowerCase().trim() == 'true';
    }

    if (value is num) {
      return value != 0;
    }

    return fallback;
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'SitioTuristicoModel('
        'id: $id, '
        'nombre: $nombre, '
        'categoria: $categoriaNombre, '
        'latitud: $latitud, '
        'longitud: $longitud'
        ')';
  }
}