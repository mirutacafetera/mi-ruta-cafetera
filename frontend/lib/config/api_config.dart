class ApiConfig {
  static const String baseUrl =
      'http://localhost:3000/api';

  static String get sitiosUrl =>
      '$baseUrl/sitiosturisticos';

  static String get categoriasSitiosUrl =>
      '$baseUrl/categorias-sitios';
}