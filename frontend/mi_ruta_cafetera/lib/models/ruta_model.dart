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
  });

  factory RutaModel.fromJson(
    Map<String, dynamic> json,
  ) {
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
      sitios:
          _extraerSitios(
        json['sitios'] ??
            json['puntos'] ??
            [],
      ),

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