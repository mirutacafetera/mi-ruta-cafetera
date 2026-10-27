
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../fondo_admin.dart';

class FormularioMotivoRechazo extends StatefulWidget {
  final String nombreProducto;

  const FormularioMotivoRechazo({
    super.key,
    required this.nombreProducto,
  });

  static Future<String?> mostrar(
    BuildContext context, {
    required String nombreProducto,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => FormularioMotivoRechazo(
        nombreProducto: nombreProducto,
      ),
    );
  }

  @override
  State<FormularioMotivoRechazo> createState() =>
      _FormularioMotivoRechazoState();
}

class _FormularioMotivoRechazoState
    extends State<FormularioMotivoRechazo> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  void _confirmarRechazo() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(_motivoController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return FondoAdmin(
      child: Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF3E7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.adminBorder),
              boxShadow: [
                BoxShadow(
                  color: AppColors.coffeeDark.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _encabezado(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xEEFAF3E7),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(22),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _producto(),
                          const SizedBox(height: 24),
                          _tituloMotivo(),
                          const SizedBox(height: 12),
                          _campoMotivo(),
                          const SizedBox(height: 18),
                          _notaInformativa(),
                          const SizedBox(height: 24),
                          _acciones(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      color: AppColors.primary,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.orangeSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.rate_review_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rechazar producto',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Revisión de solicitud',
                  style: TextStyle(
                    color: Color(0xFFE6F0E8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _producto() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8C5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.secondary,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRODUCTO SELECCIONADO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.nombreProducto,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tituloMotivo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motivo del rechazo',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Explica por qué no se aprueba este producto. '
          'La razón quedará registrada en la revisión.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _campoMotivo() {
    return TextFormField(
      controller: _motivoController,
      autofocus: true,
      minLines: 4,
      maxLines: 5,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Escribe aquí la razón...',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        filled: true,
        fillColor: const Color(0xFFFFFCF7),
        contentPadding: const EdgeInsets.all(15),
        alignLabelWithHint: true,
        border: _borde(),
        enabledBorder: _borde(),
        focusedBorder: _borde(AppColors.secondary),
        errorBorder: _borde(AppColors.error),
        focusedErrorBorder: _borde(AppColors.error),
        counterStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
      validator: (valor) {
        if (valor == null || valor.trim().length < 3) {
          return 'Escribe al menos 3 caracteres.';
        }
        return null;
      },
    );
  }

  OutlineInputBorder _borde([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(
        color: color ?? AppColors.adminBorder,
        width: color == null ? 1 : 1.5,
      ),
    );
  }

  Widget _notaInformativa() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.secondary,
            size: 19,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'El motivo ayudará a explicar la decisión '
              'al responsable del producto.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _acciones() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: const Color(0xFFFFFCF7),
              minimumSize: const Size(0, 46),
              side: const BorderSide(
                color: AppColors.adminBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: _confirmarRechazo,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
            ),
            label: const Text(
              'Rechazar',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
