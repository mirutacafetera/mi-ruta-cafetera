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

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
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
        fallback: 'location_on',
      ),
      estado: json['estado'] is bool
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

    final valueString = value.toString().trim();

    if (valueString.isEmpty) {
      return fallback;
    }

    return valueString;
  }
}