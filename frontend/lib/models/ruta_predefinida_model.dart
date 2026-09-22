import 'package:flutter/material.dart';

class RutaPredefinidaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final IconData icono;
  final Color color;
  final List<String> municipios;
  final List<String> categorias;
  final bool esCorredorRegional;

  const RutaPredefinidaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    this.municipios = const [],
    this.categorias = const [],
    this.esCorredorRegional = false,
  });
}