class EstadisticaModel {
  final String tipo;
  final int cantidad;
  final String descripcion;
  final DateTime? fecha;

  const EstadisticaModel({
    required this.tipo,
    required this.cantidad,
    this.descripcion = '',
    this.fecha,
  });

  factory EstadisticaModel.fromJson(Map<String, dynamic> json) {
    return EstadisticaModel(
      tipo: json['tipo']?.toString() ?? '',
      cantidad: _convertirNumero(json['cantidad']),
      descripcion: json['descripcion']?.toString() ?? '',
      fecha: DateTime.tryParse(json['fecha']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo,
      'cantidad': cantidad,
      'descripcion': descripcion,
      if (fecha != null) 'fecha': fecha!.toIso8601String(),
    };
  }

  static int _convertirNumero(dynamic valor) {
    if (valor is num) {
      return valor.toInt();
    }

    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }
}

class ResumenEstadisticasModel {
  final int usuarios;
  final int resenas;
  final int reservas;
  final int reportes;
  final int reportesPendientes;
  final int reportesEnRevision;
  final int reportesResueltos;

  const ResumenEstadisticasModel({
    this.usuarios = 0,
    this.resenas = 0,
    this.reservas = 0,
    this.reportes = 0,
    this.reportesPendientes = 0,
    this.reportesEnRevision = 0,
    this.reportesResueltos = 0,
  });

  factory ResumenEstadisticasModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ResumenEstadisticasModel(
      usuarios: _convertirNumero(json['usuarios']),
      resenas: _convertirNumero(json['resenas']),
      reservas: _convertirNumero(json['reservas']),
      reportes: _convertirNumero(json['reportes']),
      reportesPendientes: _convertirNumero(
        json['reportesPendientes'],
      ),
      reportesEnRevision: _convertirNumero(
        json['reportesEnRevision'],
      ),
      reportesResueltos: _convertirNumero(
        json['reportesResueltos'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarios': usuarios,
      'resenas': resenas,
      'reservas': reservas,
      'reportes': reportes,
      'reportesPendientes': reportesPendientes,
      'reportesEnRevision': reportesEnRevision,
      'reportesResueltos': reportesResueltos,
    };
  }

  static int _convertirNumero(dynamic valor) {
    if (valor is num) {
      return valor.toInt();
    }

    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }
}