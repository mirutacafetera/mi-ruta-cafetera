class AdminProductoModel {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String imagenPrincipal;
  final List<String> imagenes;
  final bool activo;
  final String estadoPublicacion;
  final String motivoRechazo;
  final String sitioNombre;
  final String ciudad;
  final String departamento;
  final DateTime? createdAt;

  const AdminProductoModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.imagenPrincipal,
    required this.imagenes,
    required this.activo,
    required this.estadoPublicacion,
    required this.motivoRechazo,
    required this.sitioNombre,
    required this.ciudad,
    required this.departamento,
    required this.createdAt,
  });

  factory AdminProductoModel.fromJson(Map<String, dynamic> json) {
    final sitio = json['sitio'];
    final sitioMap = sitio is Map
        ? Map<String, dynamic>.from(sitio)
        : <String, dynamic>{};

    final imagenesJson = json['imagenes'];

    return AdminProductoModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      precio: _parsePrecio(json['precio']),
      categoria: (json['categoria'] ?? '').toString(),
      imagenPrincipal: (json['imagenPrincipal'] ?? '').toString(),
      imagenes: imagenesJson is List
          ? imagenesJson
                .map((imagen) => imagen.toString())
                .where((imagen) => imagen.isNotEmpty)
                .toList()
          : <String>[],
      activo: json['activo'] == true,
      estadoPublicacion: (json['estadoPublicacion'] ?? 'pendiente_revision')
          .toString(),
      motivoRechazo: (json['motivoRechazo'] ?? '').toString(),
      sitioNombre: (sitioMap['nombre'] ?? 'Sitio turístico').toString(),
      ciudad: (sitioMap['ciudad'] ?? '').toString(),
      departamento: (sitioMap['departamento'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }

  static double _parsePrecio(dynamic valor) {
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString() ?? '') ?? 0;
  }
}
