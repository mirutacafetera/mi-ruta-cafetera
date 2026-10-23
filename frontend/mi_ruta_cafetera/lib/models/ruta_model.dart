// ============================================================
// PARADA DE UNA RUTA PREDEFINIDA (ITINERARIO)
// ============================================================
//
// Viene de la API (campo `paradas` de la ruta). [duracionMin] es
// el tiempo planificado de la ACTIVIDAD en el sitio; el tiempo de
// desplazamiento por carretera se calcula aparte y no se guarda.
// ============================================================
class ParadaRutaModel {
  final String sitioId;
  final int orden;
  final String tipoActividad;
  final String descripcion;
  final int? duracionMin;
  final String indicaciones;
  final bool requiereReserva;

  const ParadaRutaModel({
    required this.sitioId,
    required this.orden,
    this.tipoActividad = 'visita',
    this.descripcion = '',
    this.duracionMin,
    this.indicaciones = '',
    this.requiereReserva = false,
  });

  factory ParadaRutaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final duracion = json['duracionMin'];

    return ParadaRutaModel(
      sitioId: RutaModel._extraerId(json['sitio']),
      orden: (json['orden'] is num)
          ? (json['orden'] as num).toInt()
          : 0,
      tipoActividad:
          (json['tipoActividad'] ?? 'visita').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      duracionMin: duracion is num ? duracion.toInt() : null,
      indicaciones: (json['indicaciones'] ?? '').toString(),
      requiereReserva: json['requiereReserva'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sitio': sitioId,
      'orden': orden,
      'tipoActividad': tipoActividad,
      'descripcion': descripcion,
      'duracionMin': duracionMin,
      'indicaciones': indicaciones,
      'requiereReserva': requiereReserva,
    };
  }
}

class RutaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String tipo;
  final List<String> sitios;

  // Estos valores pueden venir del backend si existen.
  // También se conservan para compatibilidad con RutaCard.
  final double distanciaKm;
  final double duracionMinutos;

  final String? usuarioId;
  final bool activa;
  final DateTime? creadaEn;
  final DateTime? venceEn;

  // Itinerario de las rutas predefinidas (vacío en las demás).
  final List<ParadaRutaModel> paradas;
  final String tipoExperiencia;
  final int? duracionPlanificadaMin;

  const RutaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.sitios,
    required this.distanciaKm,
    required this.duracionMinutos,
    required this.usuarioId,
    required this.activa,
    required this.creadaEn,
    required this.venceEn,
    this.paradas = const [],
    this.tipoExperiencia = '',
    this.duracionPlanificadaMin,
  });

  factory RutaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final paradas = _extraerParadas(json['paradas']);
    final sitiosIds = _extraerSitios(
      json['sitios'] ??
          json['puntos'] ??
          [],
    );

    return RutaModel(
      id: _extraerId(
        json['_id'] ?? json['id'],
      ),
      nombre:
          (json['nombre'] ??
                  'Ruta personalizada')
              .toString(),
      descripcion:
          (json['descripcion'] ?? '')
              .toString(),
      tipo:
          (json['tipo'] ??
                  'personalizada')
              .toString(),
      sitios: sitiosIds.isNotEmpty
          ? sitiosIds
          : paradas.map((p) => p.sitioId).toList(),

      distanciaKm:
          _numeroADouble(
        json['distanciaKm'] ??
            json['distancia'] ??
            0,
      ),

      duracionMinutos:
          _numeroADouble(
        json['duracionMinutos'] ??
            json['duracion'] ??
            0,
      ),

      usuarioId:
          _extraerUsuarioId(
        json['usuarioId'] ??
            json['usuario'],
      ),

      activa:
          _extraerBooleano(
        json['activa'] ??
            json['activo'],
        valorPorDefecto: true,
      ),

      creadaEn:
          _fechaDesdeJson(
        json['creadaEn'] ??
            json['createdAt'],
      ),

      venceEn:
          _fechaDesdeJson(
        json['venceEn'] ??
            json['expiraEn'] ??
            json['expiresAt'],
      ),
      paradas: paradas,
      tipoExperiencia:
          (json['tipoExperiencia'] ?? '').toString(),
      duracionPlanificadaMin:
          json['duracionPlanificadaMin'] is num
              ? (json['duracionPlanificadaMin'] as num)
                  .toInt()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipo': tipo,
      'sitios': sitios,
      'distanciaKm': distanciaKm,
      'duracionMinutos': duracionMinutos,
      'usuarioId': usuarioId,
      'activa': activa,
      'creadaEn':
          creadaEn?.toIso8601String(),
      'venceEn':
          venceEn?.toIso8601String(),
      'paradas':
          paradas.map((p) => p.toJson()).toList(),
      'tipoExperiencia': tipoExperiencia,
      'duracionPlanificadaMin': duracionPlanificadaMin,
    };
  }

  // ============================================================
  // EXTRAER ID
  // ============================================================

  static String _extraerId(
    dynamic valor,
  ) {
    if (valor == null) {
      return '';
    }

    if (valor is Map) {
      final id =
          valor['_id'] ??
          valor['id'] ??
          valor[r'$oid'];

      return id?.toString() ?? '';
    }

    return valor.toString();
  }

  // ============================================================
  // EXTRAER PARADAS
  // ============================================================
  static List<ParadaRutaModel> _extraerParadas(
    dynamic valor,
  ) {
    if (valor is! List) {
      return const <ParadaRutaModel>[];
    }

    final paradas = <ParadaRutaModel>[];

    for (final item in valor) {
      if (item is! Map) {
        continue;
      }

      final parada = ParadaRutaModel.fromJson(
        Map<String, dynamic>.from(item),
      );

      if (parada.sitioId.isNotEmpty) {
        paradas.add(parada);
      }
    }

    paradas.sort((a, b) => a.orden.compareTo(b.orden));

    return paradas;
  }

  // ============================================================
  // EXTRAER SITIOS
  // ============================================================

  static List<String> _extraerSitios(
    dynamic valor,
  ) {
    if (valor is! List) {
      return <String>[];
    }

    final resultado = <String>[];

    for (final item in valor) {
      if (item == null) {
        continue;
      }

      if (item is Map) {
        final id =
            item['_id'] ??
            item['id'] ??
            item['sitioId'] ??
            item[r'$oid'];

        if (id != null) {
          final idTexto =
              id.toString().trim();

          if (idTexto.isNotEmpty) {
            resultado.add(idTexto);
          }
        }

        continue;
      }

      final idTexto =
          item.toString().trim();

      if (idTexto.isNotEmpty) {
        resultado.add(idTexto);
      }
    }

    return resultado;
  }

  // ============================================================
  // EXTRAER USUARIO
  // ============================================================

  static String? _extraerUsuarioId(
    dynamic valor,
  ) {
    if (valor == null) {
      return null;
    }

    if (valor is Map) {
      final id =
          valor['_id'] ??
          valor['id'] ??
          valor['usuarioId'] ??
          valor[r'$oid'];

      if (id == null) {
        return null;
      }

      final texto =
          id.toString().trim();

      return texto.isEmpty
          ? null
          : texto;
    }

    final texto =
        valor.toString().trim();

    return texto.isEmpty
        ? null
        : texto;
  }

  // ============================================================
  // EXTRAER BOOLEANO
  // ============================================================

  static bool _extraerBooleano(
    dynamic valor, {
    required bool valorPorDefecto,
  }) {
    if (valor is bool) {
      return valor;
    }

    if (valor is num) {
      return valor != 0;
    }

    if (valor is String) {
      final texto =
          valor.trim().toLowerCase();

      if (texto == 'true' ||
          texto == '1' ||
          texto == 'activo' ||
          texto == 'activa') {
        return true;
      }

      if (texto == 'false' ||
          texto == '0' ||
          texto == 'inactivo' ||
          texto == 'inactiva') {
        return false;
      }
    }

    return valorPorDefecto;
  }

  // ============================================================
  // NÚMEROS
  // ============================================================

  static double _numeroADouble(
    dynamic valor,
  ) {
    if (valor is num) {
      return valor.toDouble();
    }

    return double.tryParse(
          valor?.toString() ?? '',
        ) ??
        0;
  }

  // ============================================================
  // FECHAS
  // ============================================================

  static DateTime? _fechaDesdeJson(
    dynamic valor,
  ) {
    if (valor == null) {
      return null;
    }

    if (valor is DateTime) {
      return valor;
    }

    if (valor is Map) {
      final fecha =
          valor[r'$date'] ??
          valor['date'];

      if (fecha != null) {
        return DateTime.tryParse(
          fecha.toString(),
        );
      }
    }

    return DateTime.tryParse(
      valor.toString(),
    );
  }
}
