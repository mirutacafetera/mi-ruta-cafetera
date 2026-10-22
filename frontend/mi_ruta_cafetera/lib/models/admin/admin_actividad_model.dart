
class ActividadAdminModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String estadoPublicacion;
  final String motivoRechazo;
  final String imagenPrincipal;
  final List<String> imagenes;
  final String sitioId;
  final String nombreSitio;
  final String ciudad;
  final String departamento;
  final dynamic precio;
  final String horario;
  final String duracion;
  final DateTime? fechaCreacion;

  const ActividadAdminModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estadoPublicacion,
    this.motivoRechazo = '',
    this.imagenPrincipal = '',
    this.imagenes = const [],
    this.sitioId = '',
    this.nombreSitio = '',
    this.ciudad = '',
    this.departamento = '',
    this.precio,
    this.horario = '',
    this.duracion = '',
    this.fechaCreacion,
  });

  factory ActividadAdminModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final sitio = json['sitio'];
    final sitioJson = sitio is Map
        ? Map<String, dynamic>.from(sitio)
        : <String, dynamic>{};

    final listaImagenes = json['imagenes'];

    return ActividadAdminModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      estadoPublicacion:
          (json['estadoPublicacion'] ?? 'borrador').toString(),
      motivoRechazo: (json['motivoRechazo'] ?? '').toString(),
      imagenPrincipal: (json['imagenPrincipal'] ?? '').toString(),
      imagenes: listaImagenes is List
          ? listaImagenes
              .whereType<String>()
              .toList()
          : [],
      sitioId: sitio is Map
          ? (sitioJson['_id'] ?? sitioJson['id'] ?? '').toString()
          : (sitio ?? '').toString(),
      nombreSitio: (sitioJson['nombre'] ?? '').toString(),
      ciudad: (sitioJson['ciudad'] ?? '').toString(),
      departamento:
          (sitioJson['departamento'] ?? '').toString(),
      precio: json['precio'],
      horario: (json['horario'] ?? '').toString(),
      duracion: (json['duracion'] ?? '').toString(),
      fechaCreacion: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      ),
    );
  }

  List<String> get todasLasImagenes {
    return [
      if (imagenPrincipal.trim().isNotEmpty) imagenPrincipal,
      ...imagenes.where(
        (imagen) =>
            imagen.trim().isNotEmpty &&
            imagen != imagenPrincipal,
      ),
    ];
  }
}
