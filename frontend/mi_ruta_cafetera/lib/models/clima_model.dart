import 'package:flutter/material.dart';

/// Clima actual obtenido de Open-Meteo.
///
/// Solo contiene datos reales devueltos por el servicio.
class ClimaModel {
  final double temperatura;
  final int codigo;
  final bool esDeDia;
  final double precipitacion;

  /// Probabilidad de lluvia de la hora actual (0-100).
  /// Es null si el servicio no la entregó.
  final int? probabilidadLluvia;

  const ClimaModel({
    required this.temperatura,
    required this.codigo,
    required this.esDeDia,
    required this.precipitacion,
    required this.probabilidadLluvia,
  });

  // ============================================================
  // OPEN-METEO → MODELO
  // ============================================================

  factory ClimaModel.fromOpenMeteo(Map<String, dynamic> json) {
    final actual = json['current'];

    if (actual is! Map) {
      throw const FormatException(
        'La respuesta del clima no tiene datos actuales.',
      );
    }

    final temperatura = _numero(actual['temperature_2m']);

    if (temperatura == null) {
      throw const FormatException(
        'La respuesta del clima no incluye la temperatura.',
      );
    }

    return ClimaModel(
      temperatura: temperatura,
      codigo: (_numero(actual['weather_code']) ?? 0).round(),
      esDeDia: _numero(actual['is_day']) != 0,
      precipitacion: _numero(actual['precipitation']) ?? 0,
      probabilidadLluvia: _probabilidadActual(json, actual),
    );
  }

  static double? _numero(dynamic valor) {
    if (valor is num) {
      return valor.toDouble();
    }

    return double.tryParse(valor?.toString() ?? '');
  }

  // Busca la probabilidad de lluvia de la hora actual en la
  // serie horaria ("2026-10-09T19:00" vs "2026-10-09T19:30").
  static int? _probabilidadActual(
    Map<String, dynamic> json,
    Map actual,
  ) {
    final horario = json['hourly'];
    final horaActual = actual['time']?.toString();

    if (horario is! Map || horaActual == null) {
      return null;
    }

    final tiempos = horario['time'];
    final probabilidades = horario['precipitation_probability'];

    if (tiempos is! List || probabilidades is! List) {
      return null;
    }

    final prefijo = horaActual.length >= 13
        ? horaActual.substring(0, 13)
        : horaActual;

    final indice = tiempos.indexWhere(
      (tiempo) => tiempo.toString().startsWith(prefijo),
    );

    if (indice < 0 || indice >= probabilidades.length) {
      return null;
    }

    return _numero(probabilidades[indice])?.round();
  }

  // ============================================================
  // DERIVADOS
  // ============================================================

  /// Códigos WMO de lluvia, llovizna, chubascos y tormenta.
  bool get lluvia {
    const codigosLluvia = {
      51, 53, 55, 56, 57,
      61, 63, 65, 66, 67,
      80, 81, 82,
      95, 96, 99,
    };

    return codigosLluvia.contains(codigo) || precipitacion > 0;
  }

  String get descripcion {
    switch (codigo) {
      case 0:
        return esDeDia ? 'Despejado' : 'Noche despejada';
      case 1:
        return 'Mayormente despejado';
      case 2:
        return 'Parcialmente nublado';
      case 3:
        return 'Nublado';
      case 45:
      case 48:
        return 'Niebla';
      case 51:
      case 53:
      case 55:
        return 'Llovizna';
      case 56:
      case 57:
        return 'Llovizna helada';
      case 61:
        return 'Lluvia ligera';
      case 63:
        return 'Lluvia moderada';
      case 65:
        return 'Lluvia fuerte';
      case 66:
      case 67:
        return 'Lluvia helada';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return 'Nieve';
      case 80:
      case 81:
      case 82:
        return 'Chubascos';
      case 95:
        return 'Tormenta';
      case 96:
      case 99:
        return 'Tormenta con granizo';
      default:
        return 'Clima variable';
    }
  }

  IconData get icono {
    if (codigo == 0 || codigo == 1) {
      return esDeDia
          ? Icons.wb_sunny_rounded
          : Icons.nights_stay_rounded;
    }

    if (codigo == 2) {
      return esDeDia
          ? Icons.wb_cloudy_rounded
          : Icons.cloud_queue_rounded;
    }

    if (codigo == 3) {
      return Icons.cloud_rounded;
    }

    if (codigo == 45 || codigo == 48) {
      return Icons.foggy;
    }

    if (codigo >= 95) {
      return Icons.thunderstorm_rounded;
    }

    if (lluvia) {
      return Icons.water_drop_rounded;
    }

    return Icons.cloud_rounded;
  }

  // ============================================================
  // CONTEXTO PARA LA IA
  // ============================================================

  Map<String, dynamic> toJsonIa() {
    return {
      'temperatura': temperatura,
      'lluvia': lluvia,
      if (probabilidadLluvia != null)
        'probabilidadLluvia': probabilidadLluvia,
      'descripcion': descripcion,
    };
  }
}