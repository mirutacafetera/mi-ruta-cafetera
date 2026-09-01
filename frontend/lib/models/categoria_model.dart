class CategoriaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final bool estado;

  const CategoriaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.estado,
  });

  factory CategoriaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoriaModel(
      id: _stringValue(
        json['_id'] ?? json['id'],
      ),
      nombre: _stringValue(
        json['nombre'],
        fallback: 'Sin categoría',
      ),
      descripcion: _stringValue(
        json['descripcion'],
      ),
      icono: _stringValue(
        json['icono'],
        fallback: 'location_on',
      ),
      estado: _boolValue(
        json['estado'],
        fallback: true,
      ),
    );
  }

  static String _stringValue(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final texto = value.toString().trim();

    return texto.isEmpty ? fallback : texto;
  }

  static bool _boolValue(
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

  @override
  String toString() {
    return 'CategoriaModel(id: $id, nombre: $nombre)';
  }
}