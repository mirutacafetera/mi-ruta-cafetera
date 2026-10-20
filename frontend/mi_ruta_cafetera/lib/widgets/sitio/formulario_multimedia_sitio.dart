
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
        backgroundColor: esError
            ? AppColors.sitioError
            : AppColors.sitioPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.sitioSurface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(
        AppDimensions.sitioPagePadding,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 650,
          maxHeight: 850,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppDimensions.sitioPanelCardPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: AppDimensions.sitioHeaderIconSize,
                    height: AppDimensions.sitioHeaderIconSize,
                    decoration: BoxDecoration(
                      color: AppColors.sitioSurfaceGreen,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.sitioPrimary,
                    ),
                  ),
                  const SizedBox(
                    width: AppDimensions.sitioPanelCardGap,
                  ),
                  Expanded(
                    child: Text(
                      'Agregar fotografía',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            color: AppColors.sitioTextPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: _subiendo ? null : _cancelar,
                    tooltip: 'Cerrar',
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.sitioTextSecondary,
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(
                height: AppDimensions.sitioSectionGapCompact,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _construirSelector(),
                      if (_imagenBytes != null) ...[
                        const SizedBox(
                          height: AppDimensions.sitioPanelCardGap,
                        ),
                        _construirVistaPrevia(),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: AppDimensions.sitioSectionGapCompact,
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
        AppDimensions.sitioPanelCardRadius,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 28,
          horizontal: AppDimensions.sitioPanelCardPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.sitioSurfaceSoft,
          borderRadius: BorderRadius.circular(
            AppDimensions.sitioPanelCardRadius,
          ),
          border: Border.all(
            color: AppColors.sitioBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.sitioSurfaceGreen,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.add_photo_alternate_rounded,
                color: AppColors.sitioPrimary,
                size: 32,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Agregar fotografía',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.sitioTextPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Selecciona una imagen para mostrar tu sitio turístico.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.sitioTextSecondary,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _subiendo ? null : _seleccionarImagen,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.sitioPrimary,
                side: const BorderSide(
                  color: AppColors.sitioPrimary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.sitioFormRadius,
                  ),
                ),
              ),
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
        AppDimensions.sitioPanelCardGap,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurface,
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioPanelCardRadius,
        ),
        border: Border.all(
          color: AppColors.sitioBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppDimensions.sitioFormRadius,
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
            height: AppDimensions.sitioFormFieldGap,
          ),
          TextField(
            controller: _tituloController,
            enabled: !_subiendo,
            decoration: _decoracionCampo(
              etiqueta: 'Título',
              sugerencia: 'Ej. Entrada principal del sitio',
              icono: Icons.title_rounded,
            ),
          ),
          const SizedBox(
            height: AppDimensions.sitioFormFieldGap,
          ),
          TextField(
            controller: _descripcionController,
            enabled: !_subiendo,
            maxLines: 3,
            decoration: _decoracionCampo(
              etiqueta: 'Descripción',
              sugerencia: 'Describe brevemente esta fotografía',
              icono: Icons.description_outlined,
              alinearEtiqueta: true,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoracionCampo({
    required String etiqueta,
    required String sugerencia,
    required IconData icono,
    bool alinearEtiqueta = false,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: sugerencia,
      prefixIcon: Icon(
        icono,
        color: AppColors.sitioTextSecondary,
      ),
      alignLabelWithHint: alinearEtiqueta,
      filled: true,
      fillColor: AppColors.sitioSurfaceSoft,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioFormRadius,
        ),
        borderSide: const BorderSide(
          color: AppColors.sitioBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioFormRadius,
        ),
        borderSide: const BorderSide(
          color: AppColors.sitioBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.sitioFormRadius,
        ),
        borderSide: const BorderSide(
          color: AppColors.sitioPrimary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _construirAcciones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _subiendo ? null : _cancelar,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.sitioTextSecondary,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          child: const Text('Cancelar'),
        ),
        const SizedBox(
          width: AppDimensions.sitioPanelCardGap,
        ),
        Flexible(
          child: ElevatedButton.icon(
            onPressed: _subiendo ? null : _subir,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sitioPrimary,
              foregroundColor: AppColors.sitioTextOnPrimary,
              disabledBackgroundColor: AppColors.sitioBorder,
              disabledForegroundColor: AppColors.sitioTextSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppDimensions.sitioFormRadius,
                ),
              ),
            ),
            icon: _subiendo
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.sitioTextOnPrimary,
                    ),
                  )
                : const Icon(Icons.cloud_upload_rounded),
            label: Text(
              _subiendo
                  ? 'Subiendo fotografía...'
                  : 'Subir fotografía',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
