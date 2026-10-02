import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/sitio/sitio_contenido_model.dart';
import '../../services/sitio/sitio_contenido_service.dart';
import '../../services/sitio/sitio_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SitioContenidoScreen extends StatefulWidget {
  const SitioContenidoScreen({super.key});

  @override
  State<SitioContenidoScreen> createState() => _SitioContenidoScreenState();
}

class _SitioContenidoScreenState extends State<SitioContenidoScreen> {
  final SitioContenidoService _contenidoService =
      SitioContenidoService();

  final SitioSesionService _sesionService =
      SitioSesionService();

  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _tituloController =
      TextEditingController();

  final TextEditingController _descripcionController =
      TextEditingController();

  List<SitioContenidoModel> _contenidos = [];

  XFile? _imagenPrincipalSeleccionada;
  List<XFile> _imagenesSeleccionadas = [];

  bool _cargando = true;
  bool _guardando = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarContenidos();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // =========================================================
  // CARGAR CONTENIDOS
  // =========================================================

  Future<void> _cargarContenidos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      final contenidos =
          await _contenidoService.obtenerMisContenidos(
        token: sesion.token,
      );

      if (!mounted) return;

      setState(() {
        _contenidos = contenidos;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // =========================================================
  // PREPARAR FORMULARIO NUEVO
  // =========================================================

  void _mostrarFormularioNuevo() {
    _tituloController.clear();
    _descripcionController.clear();

    setState(() {
      _imagenPrincipalSeleccionada = null;
      _imagenesSeleccionadas = [];
    });

    showDialog(
      context: context,
      builder: (_) => _dialogoFormulario(
        tituloDialogo: 'Nuevo contenido',
        textoBoton: 'Crear contenido',
        contenidoExistente: null,
        onGuardar: _crearContenido,
      ),
    );
  }

  // =========================================================
  // PREPARAR FORMULARIO EDITAR
  // =========================================================

  void _mostrarFormularioEditar(
    SitioContenidoModel contenido,
  ) {
    _tituloController.text = contenido.titulo;
    _descripcionController.text = contenido.descripcion;

    setState(() {
      _imagenPrincipalSeleccionada = null;
      _imagenesSeleccionadas = [];
    });

    showDialog(
      context: context,
      builder: (_) => _dialogoFormulario(
        tituloDialogo: 'Editar contenido',
        textoBoton: 'Guardar cambios',
        contenidoExistente: contenido,
        onGuardar: () => _actualizarContenido(contenido),
      ),
    );
  }

  // =========================================================
  // SELECCIONAR IMAGEN PRINCIPAL
  // =========================================================

  Future<void> _seleccionarImagenPrincipal() async {
    try {
      final imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null || !mounted) return;

      setState(() {
        _imagenPrincipalSeleccionada = imagen;
      });
    } catch (error) {
      _mostrarMensaje(
        'No fue posible seleccionar la imagen.',
        esError: true,
      );
    }
  }

  // =========================================================
  // SELECCIONAR GALERÍA
  // =========================================================

  Future<void> _seleccionarGaleria() async {
    try {
      final imagenes = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (imagenes.isEmpty || !mounted) return;

      setState(() {
        _imagenesSeleccionadas = [
          ..._imagenesSeleccionadas,
          ...imagenes,
        ];
      });
    } catch (error) {
      _mostrarMensaje(
        'No fue posible seleccionar las imágenes.',
        esError: true,
      );
    }
  }

  // =========================================================
  // ELIMINAR SELECCIÓN DE GALERÍA
  // =========================================================

  void _eliminarImagenSeleccionada(int index) {
    setState(() {
      _imagenesSeleccionadas.removeAt(index);
    });
  }

  // =========================================================
  // FORMULARIO
  // =========================================================

  Widget _dialogoFormulario({
    required String tituloDialogo,
    required String textoBoton,
    required SitioContenidoModel? contenidoExistente,
    required Future<bool> Function() onGuardar,
  }) {
    final esEdicion = contenidoExistente != null;

    return StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        return AlertDialog(
          title: Text(
            tituloDialogo,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SizedBox(
            width: 650,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =====================================================
                  // TÍTULO
                  // =====================================================

                  TextField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText:
                          'Ej. Experiencia del café especial',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingMd,
                  ),

                  // =====================================================
                  // DESCRIPCIÓN
                  // =====================================================

                  TextField(
                    controller: _descripcionController,
                    minLines: 5,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText:
                          'Describe la experiencia turística...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingXl,
                  ),

                  // =====================================================
                  // IMAGEN PRINCIPAL
                  // =====================================================

                  const Text(
                    'Imagen principal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Será la imagen principal que representará este contenido.',
                  ),

                  const SizedBox(height: 12),

                  _construirSelectorImagenPrincipal(
                    contenidoExistente,
                    setDialogState,
                  ),

                  const SizedBox(
                    height: AppDimensions.spacingXl,
                  ),

                  // =====================================================
                  // GALERÍA
                  // =====================================================

                  const Text(
                    'Galería de imágenes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    esEdicion
                        ? 'Puedes agregar nuevas imágenes al carrusel.'
                        : 'Selecciona las imágenes que formarán el carrusel.',
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _guardando
                        ? null
                        : () async {
                            await _seleccionarGaleria();
                            setDialogState(() {});
                          },
                    icon: const Icon(
                      Icons.photo_library_outlined,
                    ),
                    label: const Text(
                      'Seleccionar imágenes',
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_imagenesSeleccionadas.isNotEmpty)
                    _construirGaleriaSeleccionada(
                      setDialogState,
                    ),

                  if (esEdicion &&
                      contenidoExistente.imagenes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Imágenes actuales',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _construirGaleriaExistente(
                      contenidoExistente.imagenes,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _guardando
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: _guardando
                  ? null
                  : () async {
                      setDialogState(() {
                        _guardando = true;
                      });

                      final resultado = await onGuardar();

                      if (!mounted) return;

                      setDialogState(() {
                        _guardando = false;
                      });

                      if (resultado &&
                          dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(textoBoton),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // SELECTOR IMAGEN PRINCIPAL
  // =========================================================

  Widget _construirSelectorImagenPrincipal(
    SitioContenidoModel? contenido,
    StateSetter setDialogState,
  ) {
    final imagenNueva = _imagenPrincipalSeleccionada;

    if (imagenNueva != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _vistaPreviaImagen(
            imagenNueva,
            alto: 210,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _guardando
                    ? null
                    : () async {
                        await _seleccionarImagenPrincipal();
                        setDialogState(() {});
                      },
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Cambiar'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _guardando
                    ? null
                    : () {
                        setState(() {
                          _imagenPrincipalSeleccionada = null;
                        });
                        setDialogState(() {});
                      },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Quitar'),
              ),
            ],
          ),
        ],
      );
    }

    if (contenido != null &&
        contenido.imagenPrincipal.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusMd,
            ),
            child: Image.network(
              contenido.imagenPrincipal,
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _marcoImagenVacia(
                  alto: 210,
                  icono: Icons.broken_image_outlined,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _guardando
                ? null
                : () async {
                    await _seleccionarImagenPrincipal();
                    setDialogState(() {});
                  },
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Reemplazar imagen principal'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _marcoImagenVacia(
          alto: 180,
          icono: Icons.image_outlined,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _guardando
              ? null
              : () async {
                  await _seleccionarImagenPrincipal();
                  setDialogState(() {});
                },
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Seleccionar imagen principal'),
        ),
      ],
    );
  }

  // =========================================================
  // GALERÍA SELECCIONADA
  // =========================================================

  Widget _construirGaleriaSeleccionada(
    StateSetter setDialogState,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _imagenesSeleccionadas.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, index) {
        final imagen = _imagenesSeleccionadas[index];

        return Stack(
          fit: StackFit.expand,
          children: [
            _vistaPreviaImagen(
              imagen,
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _guardando
                      ? null
                      : () {
                          _eliminarImagenSeleccionada(index);
                          setDialogState(() {});
                        },
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =========================================================
  // GALERÍA EXISTENTE
  // =========================================================

  Widget _construirGaleriaExistente(
    List<String> imagenes,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imagenes.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusSm,
          ),
          child: Image.network(
            imagenes[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return _marcoImagenVacia(
                icono: Icons.broken_image_outlined,
              );
            },
          ),
        );
      },
    );
  }

  // =========================================================
  // VISTA PREVIA XFILE
  // =========================================================

  Widget _vistaPreviaImagen(
    XFile imagen, {
    double? alto,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AppDimensions.radiusMd,
      ),
      child: SizedBox(
        width: double.infinity,
        height: alto,
        child: FutureBuilder(
          future: imagen.readAsBytes(),
          builder: (_, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData) {
              return _marcoImagenVacia(
                alto: alto,
                icono: Icons.broken_image_outlined,
              );
            }

            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  // =========================================================
  // MARCO IMAGEN VACÍA
  // =========================================================

  Widget _marcoImagenVacia({
    double? alto,
    IconData icono = Icons.image_outlined,
  }) {
    return Container(
      width: double.infinity,
      height: alto,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMd,
        ),
      ),
      child: Icon(
        icono,
        size: 42,
      ),
    );
  }

  // =========================================================
  // CREAR
  // =========================================================

  Future<bool> _crearContenido() async {
    if (_tituloController.text.trim().length < 2) {
      _mostrarMensaje(
        'El título es obligatorio.',
        esError: true,
      );
      return false;
    }

    if (_descripcionController.text.trim().length < 10) {
      _mostrarMensaje(
        'La descripción debe tener al menos 10 caracteres.',
        esError: true,
      );
      return false;
    }

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      final contenido =
          await _contenidoService.crearContenido(
        token: sesion.token,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
      );

      if (_imagenPrincipalSeleccionada != null ||
          _imagenesSeleccionadas.isNotEmpty) {
        await _contenidoService.subirImagenesContenido(
          token: sesion.token,
          contenidoId: contenido.id,
          imagenPrincipal: _imagenPrincipalSeleccionada,
          imagenes: _imagenesSeleccionadas,
        );
      }

      await _cargarContenidos();

      if (!mounted) return false;

      _mostrarMensaje(
        'Contenido creado correctamente.',
      );

      return true;
    } catch (error) {
      if (!mounted) return false;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );

      return false;
    }
  }

  // =========================================================
  // ACTUALIZAR
  // =========================================================

  Future<bool> _actualizarContenido(
    SitioContenidoModel contenido,
  ) async {
    if (_tituloController.text.trim().length < 2) {
      _mostrarMensaje(
        'El título es obligatorio.',
        esError: true,
      );
      return false;
    }

    if (_descripcionController.text.trim().length < 10) {
      _mostrarMensaje(
        'La descripción debe tener al menos 10 caracteres.',
        esError: true,
      );
      return false;
    }

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      await _contenidoService.actualizarContenido(
        token: sesion.token,
        contenidoId: contenido.id,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        imagenPrincipal: contenido.imagenPrincipal,
        imagenes: contenido.imagenes,
        audioGuias: contenido.audioGuias,
      );

      if (_imagenPrincipalSeleccionada != null ||
          _imagenesSeleccionadas.isNotEmpty) {
        await _contenidoService.subirImagenesContenido(
          token: sesion.token,
          contenidoId: contenido.id,
          imagenPrincipal: _imagenPrincipalSeleccionada,
          imagenes: _imagenesSeleccionadas,
        );
      }

      await _cargarContenidos();

      if (!mounted) return false;

      _mostrarMensaje(
        'Contenido actualizado correctamente.',
      );

      return true;
    } catch (error) {
      if (!mounted) return false;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );

      return false;
    }
  }

  // =========================================================
  // ENVIAR A REVISIÓN
  // =========================================================

  Future<void> _enviarRevision(
    SitioContenidoModel contenido,
  ) async {
    if (contenido.estadoPublicacion ==
        'pendiente_revision') {
      return;
    }

    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      await _contenidoService.enviarContenidoRevision(
        token: sesion.token,
        contenidoId: contenido.id,
      );

      await _cargarContenidos();

      if (!mounted) return;

      _mostrarMensaje(
        'Contenido enviado a revisión correctamente.',
      );
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    }
  }

  // =========================================================
  // ACTIVAR / DESACTIVAR
  // =========================================================

  Future<void> _cambiarEstado(
    SitioContenidoModel contenido,
  ) async {
    try {
      final sesion = await _sesionService.obtenerSesion();

      if (sesion == null || sesion.token.isEmpty) {
        throw Exception('No hay una sesión activa.');
      }

      if (contenido.activo) {
        await _contenidoService.desactivarContenido(
          token: sesion.token,
          contenidoId: contenido.id,
        );
      } else {
        await _contenidoService.activarContenido(
          token: sesion.token,
          contenidoId: contenido.id,
        );
      }

      await _cargarContenidos();

      if (!mounted) return;

      _mostrarMensaje(
        contenido.activo
            ? 'Contenido desactivado.'
            : 'Contenido activado.',
      );
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        error.toString().replaceFirst('Exception: ', ''),
        esError: true,
      );
    }
  }

  // =========================================================
  // TARJETA
  // =========================================================

  Widget _construirTarjeta(
    SitioContenidoModel contenido,
  ) {
    final estado = contenido.estadoPublicacion;

    return Card(
      margin: const EdgeInsets.only(
        bottom: AppDimensions.spacingMd,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imagenPrincipal(contenido),
                const SizedBox(
                  width: AppDimensions.spacingMd,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        contenido.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        contenido.descripcion,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      _estadoChip(estado),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                if (contenido.imagenes.isNotEmpty)
                  Chip(
                    avatar: const Icon(
                      Icons.photo_library_outlined,
                      size: 18,
                    ),
                    label: Text(
                      '${contenido.imagenes.length} imágenes',
                    ),
                  ),
                if (contenido.audioGuias.isNotEmpty)
                  Chip(
                    avatar: const Icon(
                      Icons.headphones_outlined,
                      size: 18,
                    ),
                    label: Text(
                      '${contenido.audioGuias.length} audio-guías',
                    ),
                  ),
              ],
            ),

            if (contenido.motivoRechazo.isNotEmpty &&
                estado == 'rechazado') ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Motivo del rechazo: '
                  '${contenido.motivoRechazo}',
                ),
              ),
            ],

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      estado == 'pendiente_revision'
                          ? null
                          : () {
                              _mostrarFormularioEditar(
                                contenido,
                              );
                            },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar'),
                ),

                if (estado != 'pendiente_revision')
                  ElevatedButton.icon(
                    onPressed: () {
                      _enviarRevision(contenido);
                    },
                    icon: const Icon(
                      Icons.send_outlined,
                    ),
                    label: const Text(
                      'Enviar a revisión',
                    ),
                  ),

                OutlinedButton.icon(
                  onPressed: () {
                    _cambiarEstado(contenido);
                  },
                  icon: Icon(
                    contenido.activo
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  label: Text(
                    contenido.activo
                        ? 'Desactivar'
                        : 'Activar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // IMAGEN PRINCIPAL DE TARJETA
  // =========================================================

  Widget _imagenPrincipal(
    SitioContenidoModel contenido,
  ) {
    if (contenido.imagenPrincipal.isEmpty) {
      return Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.image_outlined,
          size: 40,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        contenido.imagenPrincipal,
        width: 120,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 120,
            height: 100,
            color: AppColors.surfaceVariant,
            child: const Icon(
              Icons.broken_image_outlined,
              size: 40,
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // ESTADO
  // =========================================================

  Widget _estadoChip(String estado) {
    late String texto;
    late IconData icono;

    switch (estado) {
      case 'aprobado':
        texto = 'Aprobado';
        icono = Icons.check_circle_outline;
        break;

      case 'pendiente_revision':
        texto = 'Pendiente de revisión';
        icono = Icons.hourglass_top_outlined;
        break;

      case 'rechazado':
        texto = 'Rechazado';
        icono = Icons.cancel_outlined;
        break;

      default:
        texto = 'Borrador';
        icono = Icons.edit_note_outlined;
    }

    return Chip(
      avatar: Icon(
        icono,
        size: 18,
      ),
      label: Text(texto),
    );
  }

  // =========================================================
  // ESTADO VACÍO
  // =========================================================

  Widget _estadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes contenido turístico',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea contenido para presentar las experiencias '
              'de tu sitio a los visitantes.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _mostrarFormularioNuevo,
              icon: const Icon(Icons.add),
              label: const Text('Crear contenido'),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MENSAJES
  // =========================================================

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

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        AppDimensions.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contenido turístico',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Administra la información que quieres '
                      'presentar sobre las experiencias de tu sitio.',
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _mostrarFormularioNuevo,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo contenido'),
              ),
            ],
          ),

          const SizedBox(
            height: AppDimensions.spacingLg,
          ),

          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _cargarContenidos,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _contenidos.isEmpty
                        ? _estadoVacio()
                        : RefreshIndicator(
                            onRefresh: _cargarContenidos,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(
                                bottom: 24,
                              ),
                              itemCount: _contenidos.length,
                              itemBuilder: (_, index) {
                                return _construirTarjeta(
                                  _contenidos[index],
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}