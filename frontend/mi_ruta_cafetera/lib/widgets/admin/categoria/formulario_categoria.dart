import 'package:flutter/material.dart';

import '../../../controllers/admin/categoria/categoria_controller.dart';
import '../../../models/categoria_model.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import 'constantes_categoria.dart';
import 'selector_iconos_categoria.dart';

class FormularioCategoria extends StatefulWidget {
  final CategoriaModel? categoria;
  final CategoriaController controller;

  const FormularioCategoria({
    super.key,
    this.categoria,
    required this.controller,
  });

  @override
  State<FormularioCategoria> createState() =>
      _FormularioCategoriaState();
}

class _FormularioCategoriaState extends State<FormularioCategoria> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nombre;
  late final TextEditingController descripcion;
  late String icono;
  late bool activo;

  bool guardando = false;
  String? error;

  @override
  void initState() {
    super.initState();

    nombre = TextEditingController(
      text: widget.categoria?.nombre ?? '',
    );

    descripcion = TextEditingController(
      text: widget.categoria?.descripcion ?? '',
    );

    final guardado = widget.categoria?.icono;

    icono = iconosCategoria.containsKey(guardado)
        ? guardado!
        : 'location_on';

    activo = widget.categoria?.estado ?? true;
  }

  @override
  void dispose() {
    nombre.dispose();
    descripcion.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (guardando || !formKey.currentState!.validate()) return;

    setState(() {
      guardando = true;
      error = null;
    });

    try {
      await widget.controller.guardarCategoria(
        id: widget.categoria?.id,
        nombre: nombre.text.trim(),
        descripcion: descripcion.text.trim(),
        icono: icono,
        estado: activo,
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        guardando = false;
        error = widget.controller.error ?? 'No se pudo guardar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: blancoTarjeta,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      title: Text(
        widget.categoria == null
            ? 'Nueva categoría'
            : 'Editar categoría',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombre,
                  enabled: !guardando,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty
                          ? 'Escribe el nombre'
                          : null,
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                TextFormField(
                  controller: descripcion,
                  enabled: !guardando,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                SelectorIconosCategoria(
                  iconos: iconosCategoria,
                  colores: coloresIconosCategoria,
                  seleccionado: icono,
                  habilitado: !guardando,
                  onSeleccionar: (v) => setState(() => icono = v),
                ),
                if (widget.categoria != null)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Categoría activa'),
                    value: activo,
                    onChanged: guardando
                        ? null
                        : (v) => setState(() => activo = v),
                  ),
                if (error != null) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: guardando
              ? null
              : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: verdeEncabezado,
            foregroundColor: Colors.white,
          ),
          onPressed: guardando ? null : guardar,
          child: guardando
              ? const SizedBox(
                  width: AppDimensions.iconSm,
                  height: AppDimensions.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}