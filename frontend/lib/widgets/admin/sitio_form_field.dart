import 'package:flutter/material.dart';

class SitioFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obligatorio;
  final bool obscureText;

  const SitioFormField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.obligatorio = false,
    this.obscureText = false,
  });

  static const Color verdePrincipal = Color(0xFF31572C);
  static const Color cafe = Color(0xFF795548);
  static const Color grisTexto = Color(0xFF6B6B6B);
  static const Color grisBorde = Color(0xFFE1E1E1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: obscureText ? 1 : maxLines,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF333333),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: grisTexto,
            fontSize: 14,
          ),
          floatingLabelStyle: const TextStyle(
            color: verdePrincipal,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: cafe,
                  size: 21,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: grisBorde,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: grisBorde,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: verdePrincipal,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2,
            ),
          ),
        ),
        validator: obligatorio
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }

                return null;
              }
            : null,
      ),
    );
  }
}