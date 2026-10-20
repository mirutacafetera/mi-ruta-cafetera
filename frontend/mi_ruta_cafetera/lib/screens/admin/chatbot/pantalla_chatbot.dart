
import 'package:flutter/material.dart';

import '../../../controllers/admin/chatbot/chatbot_controlador.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';
import '../../../widgets/admin/chatbot/campo_mensaje_chatbot.dart';
import '../../../widgets/admin/chatbot/indicador_escribiendo.dart';
import '../../../widgets/admin/chatbot/tarjeta_mensaje_chatbot.dart';

class PantallaChatbot extends StatefulWidget {
  const PantallaChatbot({super.key});

  @override
  State<PantallaChatbot> createState() => _PantallaChatbotState();
}

class _PantallaChatbotState extends State<PantallaChatbot> {
  final ChatbotControlador _controlador = ChatbotControlador();
  final TextEditingController _mensajeController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controlador.addListener(_desplazarAlFinal);
  }

  void _desplazarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: AppDimensions.animationNormal,
        ),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviarMensaje(String texto) async {
    if (texto.trim().isEmpty || _controlador.cargando) return;

    _mensajeController.clear();
    await _controlador.enviarMensaje(texto);
  }

  void _limpiarConversacion() {
    if (_controlador.cargando) return;

    _controlador.limpiarConversacion();
  }

  @override
  void dispose() {
    _controlador.removeListener(_desplazarAlFinal);
    _controlador.dispose();
    _mensajeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.smart_toy_rounded,
              size: AppDimensions.iconLg,
            ),
            SizedBox(width: AppDimensions.spacingSm),
            Expanded(
              child: Text('Chatbot IA'),
            ),
          ],
        ),
        actions: [
          AnimatedBuilder(
            animation: _controlador,
            builder: (context, _) {
              return IconButton(
                tooltip: 'Limpiar conversación',
                onPressed: _controlador.cargando ||
                        _controlador.mensajes.isEmpty
                    ? null
                    : _limpiarConversacion,
                icon: const Icon(Icons.delete_outline_rounded),
              );
            },
          ),
          const SizedBox(width: AppDimensions.spacingSm),
        ],
      ),
      body: Column(
        children: [
          _construirAvisoAdministrativo(),
          Expanded(
            child: AnimatedBuilder(
              animation: _controlador,
              builder: (context, _) {
                final mensajes = _controlador.mensajes;

                if (mensajes.isEmpty) {
                  return _construirBienvenida();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingLg,
                  ),
                  itemCount: mensajes.length +
                      (_controlador.cargando ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < mensajes.length) {
                      return TarjetaMensajeChatbot(
                        mensaje: mensajes[index],
                      );
                    }

                    return const IndicadorEscribiendo();
                  },
                );
              },
            ),
          ),
          CampoMensajeChatbot(
            controller: _mensajeController,
            cargando: _controlador.cargando,
            onEnviar: _enviarMensaje,
          ),
        ],
      ),
    );
  }

  Widget _construirAvisoAdministrativo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
        0,
      ),
      padding: const EdgeInsets.all(
        AppDimensions.spacingMd,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.admin_panel_settings_rounded,
            color: AppColors.primary,
            size: AppDimensions.iconMd,
          ),
          SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              'Asistente de IA exclusivo del panel administrativo.',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirBienvenida() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(
          AppDimensions.pageHorizontal,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 440,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusXxl,
                  ),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: AppColors.white,
                  size: 44,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              Text(
                '¡Hola, administrador!',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(
                height: AppDimensions.spacingSm,
              ),
              const Text(
                'Escribe un mensaje para comenzar a conversar '
                'con el asistente de inteligencia artificial.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(
                height: AppDimensions.spacingXl,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(
                  AppDimensions.spacingLg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius,
                  ),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: AppColors.secondary,
                        ),
                        SizedBox(
                          width: AppDimensions.spacingSm,
                        ),
                        Text(
                          'Puedes comenzar preguntando:',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: AppDimensions.spacingMd,
                    ),
                    Text(
                      '• ¿Cómo puedo mejorar la moderación '
                      'del contenido?\n'
                      '• Ayúdame a revisar una descripción '
                      'turística.\n'
                      '• ¿Qué debo verificar antes de publicar '
                      'una actividad?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
