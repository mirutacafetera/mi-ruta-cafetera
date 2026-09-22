class CategoriaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;

  // Se conservan ambos conceptos para compatibilidad
  // con el código anterior y el actualizado.
  final bool activo;
  final bool estado;

  const CategoriaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.activo,
    required this.estado,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    final bool estadoValue = _boolValue(
      json['estado'] ?? json['activo'],
      fallback: true,
    );

    final bool activoValue = _boolValue(
      json['activo'] ?? json['estado'],
      fallback: true,
    );

    return CategoriaModel(
      id: _stringValue(
        json['_id'] ?? json['id'],
        fallback: '',
      ),
      nombre: _stringValue(
        json['nombre'],
        fallback: 'Sin categoría',
      ),
      descripcion: _stringValue(
        json['descripcion'],
        fallback: '',
      ),
      icono: _stringValue(
        json['icono'],
        fallback: '',
      ),
      activo: activoValue,
      estado: estadoValue,
    );
  }

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
        final texto = oid.toString().trim();

        if (texto.isNotEmpty) {
          return texto;
        }
      }
    }

    final texto = value.toString().trim();

    if (texto.isEmpty) {
      return fallback;
    }

    return texto;
  }

  static bool _boolValue(
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

  @override
  String toString() {
    return 'CategoriaModel(id: $id, nombre: $nombre)';
  }
}