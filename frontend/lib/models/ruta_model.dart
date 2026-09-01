import 'package:flutter/material.dart';

class RutaModel {
  final String id;
  final String nombre;
  final String descripcion;

  final IconData icono;
  final Color color;

  final List<String> categorias;
  final List<String> municipios;

  final bool esCorredorRegional;

  const RutaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    this.categorias = const [],
    this.municipios = const [],
    this.esCorredorRegional = false,
  });
}