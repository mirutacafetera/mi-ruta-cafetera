import 'package:flutter/foundation.dart';

import '../usuario/avatar_cafetero_model.dart';

class UsuarioAdmin {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String ciudad;
  final String fotoPerfil;
  final bool activo;
  final bool correoVerificado;
  final DateTime? creadoEn;
  final DateTime? eliminadoAt;
  final AvatarCafeteroModel? avatar;

  final String? tipoEliminacion;
  final String? usuarioNombreEliminado;
  final String? usuarioCorreoEliminado;
  final String? responsableNombre;
  final String? responsableId;
  final DateTime? fechaEliminacion;
  final String? motivoEliminacion;

  const UsuarioAdmin({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.ciudad,
    required this.fotoPerfil,
    required this.activo,
    required this.correoVerificado,
    this.creadoEn,
    this.eliminadoAt,
    this.avatar,
    this.tipoEliminacion,
    this.usuarioNombreEliminado,
    this.usuarioCorreoEliminado,
    this.responsableNombre,
    this.responsableId,
    this.fechaEliminacion,
    this.motivoEliminacion,
  });

  String get nombreCompleto => '$nombre $apellido'.trim();

  bool get eliminado => eliminadoAt != null || fechaEliminacion != null;

  String get correoMostrado {
    if (eliminado &&
        usuarioCorreoEliminado != null &&
        usuarioCorreoEliminado!.trim().isNotEmpty) {
      return usuarioCorreoEliminado!.trim();
    }

    return correo;
  }

  bool get correoAnonimizado =>
      correo.endsWith('@anonimo.invalid');

  String get estado {
    if (eliminado) return 'Eliminado';
    if (!activo) return 'Inactivo';
    return 'Activo';
  }

  factory UsuarioAdmin.fromJson(Map<String, dynamic> json) {
    final eliminacion = json['eliminacion'] is Map
        ? Map<String, dynamic>.from(json['eliminacion'] as Map)
        : <String, dynamic>{};

    final foto = json['fotoPerfil']?.toString().trim() ?? '';

    final avatarRecibido = AvatarCafeteroModel.desdeDinamico(
      json['avatar'],
    );

    debugPrint('USUARIO ADMIN: ${json['correo']}');
    debugPrint('CORREO ORIGINAL: ${eliminacion['usuarioCorreo']}');
    debugPrint('FOTO PERFIL: ${foto.isEmpty ? "(vacía)" : foto}');
    debugPrint('AVATAR RECIBIDO: ${json['avatar']}');
    debugPrint('AVATAR ACTIVADO: ${avatarRecibido?.usar}');

    return UsuarioAdmin(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      ciudad: json['ciudad']?.toString() ?? '',
      fotoPerfil: foto,
      activo: json['activo'] == true,
      correoVerificado: json['correoVerificado'] == true ||
          json['correoVerificado']?.toString() == 'true',
      creadoEn: DateTime.tryParse(
        json['createdAt']?.toString() ?? '',
      ),
      eliminadoAt: DateTime.tryParse(
        json['eliminadoAt']?.toString() ?? '',
      ),
      avatar: avatarRecibido,
      tipoEliminacion: eliminacion['tipo']?.toString(),
      usuarioNombreEliminado:
          eliminacion['usuarioNombre']?.toString(),
      usuarioCorreoEliminado:
          eliminacion['usuarioCorreo']?.toString(),
      responsableNombre:
          eliminacion['responsableNombre']?.toString(),
      responsableId: eliminacion['responsableId']?.toString(),
      fechaEliminacion: DateTime.tryParse(
        eliminacion['fecha']?.toString() ?? '',
      ),
      motivoEliminacion: eliminacion['motivo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'ciudad': ciudad,
      'fotoPerfil': fotoPerfil,
      'activo': activo,
      'correoVerificado': correoVerificado,
      'createdAt': creadoEn?.toIso8601String(),
      'eliminadoAt': eliminadoAt?.toIso8601String(),
      'avatar': avatar?.toJson(),
      'eliminacion': {
        'tipo': tipoEliminacion,
        'usuarioNombre': usuarioNombreEliminado,
        'usuarioCorreo': usuarioCorreoEliminado,
        'responsableNombre': responsableNombre,
        'responsableId': responsableId,
        'fecha': fechaEliminacion?.toIso8601String(),
        'motivo': motivoEliminacion,
      },
    };
  }

  UsuarioAdmin copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? correo,
    String? telefono,
    String? ciudad,
    String? fotoPerfil,
    bool? activo,
    bool? correoVerificado,
    DateTime? creadoEn,
    DateTime? eliminadoAt,
    AvatarCafeteroModel? avatar,
    String? tipoEliminacion,
    String? usuarioNombreEliminado,
    String? usuarioCorreoEliminado,
    String? responsableNombre,
    String? responsableId,
    DateTime? fechaEliminacion,
    String? motivoEliminacion,
  }) {
    return UsuarioAdmin(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      ciudad: ciudad ?? this.ciudad,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      activo: activo ?? this.activo,
      correoVerificado: correoVerificado ?? this.correoVerificado,
      creadoEn: creadoEn ?? this.creadoEn,
      eliminadoAt: eliminadoAt ?? this.eliminadoAt,
      avatar: avatar ?? this.avatar,
      tipoEliminacion: tipoEliminacion ?? this.tipoEliminacion,
      usuarioNombreEliminado:
          usuarioNombreEliminado ?? this.usuarioNombreEliminado,
      usuarioCorreoEliminado:
          usuarioCorreoEliminado ?? this.usuarioCorreoEliminado,
      responsableNombre:
          responsableNombre ?? this.responsableNombre,
      responsableId: responsableId ?? this.responsableId,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      motivoEliminacion: motivoEliminacion ?? this.motivoEliminacion,
    );
  }
}