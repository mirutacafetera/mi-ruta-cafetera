// ============================================================
// AVATAR CAFETERO
// ============================================================
//
// Configuración del avatar ilustrado del usuario.
//
// Los identificadores deben coincidir EXACTAMENTE con
// AVATAR_OPCIONES del backend (models/usuario/usuario.js),
// que es quien valida lo que se guarda.
//
// `usar` indica si el usuario eligió mostrar su avatar. Mientras
// sea false se sigue mostrando la foto de Google (si existe) o
// el ícono de persona. La foto de Google nunca se reemplaza.
// ============================================================

class AvatarCafeteroModel {
  final bool usar;
  final String piel;
  final String peinado;
  final String colorPelo;
  final String ropa;
  final String sombrero;
  final String accesorio;
  final String fondo;

  const AvatarCafeteroModel({
    this.usar = false,
    this.piel = 'trigo',
    this.peinado = 'corto',
    this.colorPelo = 'castano',
    this.ropa = 'verde',
    this.sombrero = 'ninguno',
    this.accesorio = 'ninguno',
    this.fondo = 'montanas',
  });

  // ------------------------------------------------------------
  // OPCIONES DISPONIBLES (espejo del backend)
  // ------------------------------------------------------------

  static const List<String> pieles = [
    'clara',
    'trigo',
    'canela',
    'morena',
    'oscura',
  ];

  static const List<String> peinados = [
    'corto',
    'ondulado',
    'trenza',
    'cola',
    'rizado',
    'calvo',
  ];

  static const List<String> coloresPelo = [
    'negro',
    'castano',
    'cafe',
    'rubio',
    'gris',
  ];

  static const List<String> ropas = [
    'verde',
    'cafe',
    'crema',
    'naranja',
  ];

  static const List<String> sombreros = [
    'ninguno',
    'aguadeno',
    'paja',
    'gorra',
  ];

  static const List<String> accesorios = [
    'ninguno',
    'canasto',
    'taza',
    'gafas',
    'mochila',
  ];

  static const List<String> fondos = [
    'montanas',
    'cafetal',
    'amanecer',
    'tatacoa',
  ];

  // ------------------------------------------------------------
  // ETIQUETAS PARA LA INTERFAZ
  // ------------------------------------------------------------

  static const Map<String, String> etiquetas = {
    // piel
    'clara': 'Clara',
    'trigo': 'Trigo',
    'canela': 'Canela',
    'morena': 'Morena',
    'oscura': 'Oscura',
    // peinado
    'corto': 'Corto',
    'ondulado': 'Ondulado',
    'trenza': 'Trenza',
    'cola': 'Cola',
    'rizado': 'Rizado',
    'calvo': 'Sin cabello',
    // color de pelo
    'negro': 'Negro',
    'castano': 'Castaño',
    'cafe': 'Café',
    'rubio': 'Rubio',
    'gris': 'Canoso',
    // ropa
    'verde': 'Verde',
    'crema': 'Crema',
    'naranja': 'Naranja',
    // sombrero
    'ninguno': 'Ninguno',
    'aguadeno': 'Aguadeño',
    'paja': 'Paja',
    'gorra': 'Gorra',
    // accesorio
    'canasto': 'Canasto de café',
    'taza': 'Taza de café',
    'gafas': 'Gafas',
    'mochila': 'Mochila',
    // fondo
    'montanas': 'Montañas',
    'cafetal': 'Cafetal',
    'amanecer': 'Amanecer',
    'tatacoa': 'Tatacoa',
  };

  static String etiqueta(String id) => etiquetas[id] ?? id;

  // ------------------------------------------------------------
  // JSON
  // ------------------------------------------------------------

  static String _valido(
    dynamic valor,
    List<String> permitidos,
    String porDefecto,
  ) {
    final texto = (valor ?? '').toString();
    return permitidos.contains(texto) ? texto : porDefecto;
  }

  /// Interpreta lo que envía el backend. Los campos ausentes o
  /// desconocidos se sustituyen por el valor inicial.
  factory AvatarCafeteroModel.fromJson(Map<String, dynamic> json) {
    const base = AvatarCafeteroModel();

    return AvatarCafeteroModel(
      usar: json['usar'] == true,
      piel: _valido(json['piel'], pieles, base.piel),
      peinado: _valido(json['peinado'], peinados, base.peinado),
      colorPelo: _valido(json['colorPelo'], coloresPelo, base.colorPelo),
      ropa: _valido(json['ropa'], ropas, base.ropa),
      sombrero: _valido(json['sombrero'], sombreros, base.sombrero),
      accesorio: _valido(json['accesorio'], accesorios, base.accesorio),
      fondo: _valido(json['fondo'], fondos, base.fondo),
    );
  }

  /// Devuelve null cuando el valor recibido no es un objeto.
  static AvatarCafeteroModel? desdeDinamico(dynamic valor) {
    if (valor is Map) {
      return AvatarCafeteroModel.fromJson(
        Map<String, dynamic>.from(valor),
      );
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'usar': usar,
      'piel': piel,
      'peinado': peinado,
      'colorPelo': colorPelo,
      'ropa': ropa,
      'sombrero': sombrero,
      'accesorio': accesorio,
      'fondo': fondo,
    };
  }

  AvatarCafeteroModel copyWith({
    bool? usar,
    String? piel,
    String? peinado,
    String? colorPelo,
    String? ropa,
    String? sombrero,
    String? accesorio,
    String? fondo,
  }) {
    return AvatarCafeteroModel(
      usar: usar ?? this.usar,
      piel: piel ?? this.piel,
      peinado: peinado ?? this.peinado,
      colorPelo: colorPelo ?? this.colorPelo,
      ropa: ropa ?? this.ropa,
      sombrero: sombrero ?? this.sombrero,
      accesorio: accesorio ?? this.accesorio,
      fondo: fondo ?? this.fondo,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AvatarCafeteroModel &&
        other.usar == usar &&
        other.piel == piel &&
        other.peinado == peinado &&
        other.colorPelo == colorPelo &&
        other.ropa == ropa &&
        other.sombrero == sombrero &&
        other.accesorio == accesorio &&
        other.fondo == fondo;
  }

  @override
  int get hashCode => Object.hash(
        usar,
        piel,
        peinado,
        colorPelo,
        ropa,
        sombrero,
        accesorio,
        fondo,
      );
}
