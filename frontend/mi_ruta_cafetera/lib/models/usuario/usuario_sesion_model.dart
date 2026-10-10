import 'dart:convert';

class UsuarioSesionModel {
  final String token;

  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String ciudad;
  final String fotoPerfil;

  const UsuarioSesionModel({
    required this.token,
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.ciudad,
    required this.fotoPerfil,
  });

  // ============================================================
  // RESPUESTA DEL BACKEND → MODELO
  // ============================================================
  //
  // Sirve para /usuarios/login y /usuarios/login-google,
  // que devuelven: { token, usuario: { id, nombre, ... } }
  // ============================================================

  factory UsuarioSesionModel.fromRespuesta({
    required String token,
    required Map<String, dynamic> usuario,
  }) {
    return UsuarioSesionModel(
      token: token,
      id: (usuario['id'] ?? usuario['_id'] ?? '').toString(),
      nombre: (usuario['nombre'] ?? '').toString(),
      apellido: (usuario['apellido'] ?? '').toString(),
      correo: (usuario['correo'] ?? '').toString(),
      telefono: (usuario['telefono'] ?? '').toString(),
      ciudad: (usuario['ciudad'] ?? '').toString(),
      fotoPerfil: (usuario['fotoPerfil'] ?? '').toString(),
    );
  }

  // ============================================================
  // JSON LOCAL
  // ============================================================

  factory UsuarioSesionModel.fromJson(Map<String, dynamic> json) {
    return UsuarioSesionModel(
      token: (json['token'] ?? '').toString(),
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      apellido: (json['apellido'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      telefono: (json['telefono'] ?? '').toString(),
      ciudad: (json['ciudad'] ?? '').toString(),
      fotoPerfil: (json['fotoPerfil'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'ciudad': ciudad,
      'fotoPerfil': fotoPerfil,
    };
  }

  // ============================================================
  // MAPA COMPATIBLE CON HomeUsuarioScreen
  // ============================================================
  //
  // HomeUsuarioScreen recibe `usuario` como Map<String, dynamic>.
  // Se conserva esa firma para no modificar la pantalla.
  // ============================================================

  Map<String, dynamic> toUsuarioMap() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'ciudad': ciudad,
      'fotoPerfil': fotoPerfil,
    };
  }

  String get nombreCompleto {
    return '$nombre $apellido'.trim();
  }

  // ============================================================
  // EXPIRACIÓN DEL JWT
  // ============================================================
  //
  // Lee el campo "exp" del payload sin verificar la firma.
  // La verificación real la hace siempre el backend; esto solo
  // evita restaurar una sesión que ya se sabe caducada.
  // ============================================================

  bool get expirada {
    try {
      final partes = token.split('.');

      if (partes.length != 3) {
        return true;
      }

      final payload = utf8.decode(
        base64Url.decode(
          base64Url.normalize(partes[1]),
        ),
      );

      final datos = jsonDecode(payload);

      if (datos is! Map || datos['exp'] == null) {
        return false;
      }

      final exp = int.tryParse(datos['exp'].toString());

      if (exp == null) {
        return false;
      }

      final vence = DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
      );

      return DateTime.now().isAfter(vence);
    } catch (_) {
      return true;
    }
  }
}