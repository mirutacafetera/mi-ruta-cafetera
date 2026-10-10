import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

typedef SubirMultimediaCallback = Future<bool> Function({
  required XFile imagen,
  required String titulo,
  required String descripcion,
});

class FormularioMultimediaSitio extends StatefulWidget {
  final SubirMultimediaCallback onSubir;

  const FormularioMultimediaSitio({
    super.key,
    required this.onSubir,
  });

  @override
  State<FormularioMultimediaSitio> createState() =>
      _FormularioMultimediaSitioState();
}

class _FormularioMultimediaSitioState
    extends State<FormularioMultimediaSitio> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _tituloController =
      TextEditingController();
  final TextEditingController _descripcionController =
      TextEditingController();

  XFile? _imagen;
  Uint8List? _imagenBytes;
  bool _subiendo = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    if (_subiendo) return;

    try {
      final imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (imagen == null || !mounted) return;

      final bytes = await imagen.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imagen = imagen;
        _imagenBytes = bytes;
      });
    } catch (_) {
      _mostrarMensaje(
        'No fue posible seleccionar la imagen.',
        esError: true,
      );
    }
  }

  Future<void> _subir() async {
    if (_imagen == null) {
      _mostrarMensaje(
        'Primero selecciona una imagen.',
        esError: true,
      );
      return;
    }

    setState(() {
      _subiendo = true;
    });

    try {
      final resultado = await widget.onSubir(
        imagen: _imagen!,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
      );

      if (!mounted) return;

      if (resultado) {
        Navigator.of(context).pop();
        return;
      }
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    }

    if (!mounted) return;

    setState(() {
      _subiendo = false;
    });
  }

  void _cancelar() {
    if (_subiendo) return;

    Navigator.of(context).pop();
  }

  void _mostrarMensaje(
    String mensaje, {
    bool esError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
            esError ? AppColors.error : AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 650,
          maxHeight: 850,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.spacingLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGreen,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(
                    width: AppDimensions.spacingMd,
                  ),
                  const Expanded(
                    child: Text(
                      'Agregar fotografía',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _subiendo ? null : _cancelar,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _construirSelector(),
                      if (_imagenBytes != null) ...[
                        const SizedBox(
                          height: AppDimensions.spacingMd,
                        ),
                        _construirVistaPrevia(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingLg,
              ),
              _construirAcciones(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirSelector() {
    return InkWell(
      onTap: _subiendo ? null : _seleccionarImagen,
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusLg,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spacingXl,
          horizontal: AppDimensions.spacingLg,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusLg,
          ),
          border: Border.all(
            color: AppColors.primary.withValues(
              alpha: 0.25,
            ),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                color: AppColors.primary,
                size: 31,
              ),
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            const Text(
              'Agregar fotografía',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Selecciona una imagen para mostrar tu sitio turístico.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            OutlinedButton.icon(
              onPressed:
                  _subiendo ? null : _seleccionarImagen,
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Seleccionar imagen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirVistaPrevia() {
    return Container(
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLg,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.memory(
                _imagenBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          TextField(
            controller: _tituloController,
            enabled: !_subiendo,
            decoration: const InputDecoration(
              labelText: 'Título',
              hintText: 'Ej. Entrada principal del sitio',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(
            height: AppDimensions.spacingMd,
          ),
          TextField(
            controller: _descripcionController,
            enabled: !_subiendo,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText:
                  'Describe brevemente esta fotografía',
              prefixIcon: Icon(
                Icons.description_outlined,
              ),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAcciones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _subiendo ? null : _cancelar,
          child: const Text('Cancelar'),
        ),
        const SizedBox(
          width: AppDimensions.spacingSm,
        ),
        ElevatedButton.icon(
          onPressed: _subiendo ? null : _subir,
          icon: _subiendo
              ? const SizedBox(
                  width: AppDimensions.iconSm,
                  height: AppDimensions.iconSm,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.cloud_upload_rounded,
                ),
          label: Text(
            _subiendo
                ? 'Subiendo fotografía...'
                : 'Subir fotografía',
          ),
        ),
      ],
    );
  }
}