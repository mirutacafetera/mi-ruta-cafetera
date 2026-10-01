class SitioDashboardModel {
  final String sitioId;
  final String nombreSitio;
  final bool activo;

  final int totalActividades;
  final int totalContenidos;
  final int totalReservas;
  final int totalResenas;

  final double promedioCalificacion;

  final int reservasPendientes;
  final int reservasConfirmadas;

  SitioDashboardModel({
    required this.sitioId,
    required this.nombreSitio,
    required this.activo,
    required this.totalActividades,
    required this.totalContenidos,
    required this.totalReservas,
    required this.totalResenas,
    required this.promedioCalificacion,
    required this.reservasPendientes,
    required this.reservasConfirmadas,
  });

  factory SitioDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SitioDashboardModel(
      sitioId: json['sitioId']?.toString() ?? '',
      nombreSitio: json['nombreSitio'] ?? '',
      activo: json['activo'] ?? false,

      totalActividades:
          json['totalActividades'] ?? 0,

      totalContenidos:
          json['totalContenidos'] ?? 0,

      totalReservas:
          json['totalReservas'] ?? 0,

      totalResenas:
          json['totalResenas'] ?? 0,

      promedioCalificacion:
          (json['promedioCalificacion'] ?? 0)
              .toDouble(),

      reservasPendientes:
          json['reservasPendientes'] ?? 0,

      reservasConfirmadas:
          json['reservasConfirmadas'] ?? 0,
    );
  }
}