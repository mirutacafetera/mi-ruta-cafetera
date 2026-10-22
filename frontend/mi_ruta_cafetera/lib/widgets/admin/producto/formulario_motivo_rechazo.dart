
import 'package:flutter/material.dart';


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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      _motivoController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: Colors.red,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text('Rechazar producto'),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Producto: ${widget.nombreProducto}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Indica por qué no se acepta esta solicitud.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motivoController,
                autofocus: true,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Motivo del rechazo',
                  hintText: 'Escribe el motivo...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().length < 3) {
                    return 'Escribe al menos 3 caracteres.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
          ),
          onPressed: _confirmarRechazo,
          icon: const Icon(Icons.close),
          label: const Text('Rechazar'),
        ),
      ],
    );
  }
}
