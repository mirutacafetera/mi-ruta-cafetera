import 'sitio_turistico_model.dart';

/// Categoría real devuelta por el backend (para los chips).
class IaCategoria {
  final String id;
  final String nombre;

  const IaCategoria({
    required this.id,
    required this.nombre,
  });

  factory IaCategoria.fromJson(Map<String, dynamic> json) {
    return IaCategoria(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
    );
  }
}

/// Actividad real y aprobada de un sitio.
class IaActividad {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String horario;
  final String duracion;

  const IaActividad({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.horario,
    required this.duracion,
  });

  factory IaActividad.fromJson(Map<String, dynamic> json) {
    final precio = json['precio'];

    return IaActividad(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      precio: precio is num ? precio.toDouble() : 0,
      horario: (json['horario'] ?? '').toString(),
      duracion: (json['duracion'] ?? '').toString(),
    );
  }
}

class IaRecomendacion {
  final SitioTuristicoModel sitio;
  final double? distanciaKm;
  final double precioDesde;
  final String horario;
  final bool esFavorito;
  final IaActividad? actividad;

  /// True solo si el sitio tiene una actividad real y aprobada.
  final bool reservable;

  final String motivo;
  final String momentoSugerido;

  const IaRecomendacion({
    required this.sitio,
    required this.distanciaKm,
    required this.precioDesde,
    required this.horario,
    required this.esFavorito,
    required this.actividad,
    required this.reservable,
    required this.motivo,
    required this.momentoSugerido,
  });

  factory IaRecomendacion.fromJson(Map<String, dynamic> json) {
    final sitioJson = Map<String, dynamic>.from(
      json['sitio'] as Map,
    );

    // El backend envía la categoría como nombre; el modelo
    // existente la espera como objeto.
    final modelo = SitioTuristicoModel.fromJson({
      ...sitioJson,
      '_id': sitioJson['id'],
      'categoria': {
        '_id': '',
        'nombre': sitioJson['categoria'] ?? '',
      },
      'activo': true,
    });

    final actividadJson = json['actividad'];
    final distancia = sitioJson['distanciaKm'];
    final precio = sitioJson['precioDesde'];

    return IaRecomendacion(
      sitio: modelo,
      distanciaKm: distancia is num ? distancia.toDouble() : null,
      precioDesde: precio is num ? precio.toDouble() : 0,
      horario: (sitioJson['horario'] ?? '').toString(),
      esFavorito: sitioJson['esFavorito'] == true,
      actividad: actividadJson is Map
          ? IaActividad.fromJson(
              Map<String, dynamic>.from(actividadJson),
            )
          : null,
      reservable:
          json['reservable'] == true && actividadJson is Map,
      motivo: (json['motivo'] ?? '').toString(),
      momentoSugerido:
          (json['momentoSugerido'] ?? '').toString(),
    );
  }
}

class IaRespuesta {
  final String saludo;

  /// "groq" si respondió la IA, "catalogo" si fue el respaldo.
  final String fuente;

  final List<IaCategoria> categorias;
  final List<IaRecomendacion> recomendaciones;

  const IaRespuesta({
    required this.saludo,
    required this.fuente,
    required this.categorias,
    required this.recomendaciones,
  });

  bool get esRespaldo => fuente != 'groq';

  factory IaRespuesta.fromJson(Map<String, dynamic> json) {
    final categorias = json['categorias'];
    final recomendaciones = json['recomendaciones'];

    return IaRespuesta(
      saludo: (json['saludo'] ?? '').toString(),
      fuente: (json['fuente'] ?? '').toString(),
      categorias: categorias is List
          ? categorias
              .whereType<Map>()
              .map(
                (item) => IaCategoria.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
      recomendaciones: recomendaciones is List
          ? recomendaciones
              .whereType<Map>()
              .map(
                (item) => IaRecomendacion.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
    );
  }
}