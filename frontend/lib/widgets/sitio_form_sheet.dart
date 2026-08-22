import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SitioFormSheet extends StatefulWidget {
  final Map<String, dynamic>? sitio;
  final List<Map<String, dynamic>> categorias;

  const SitioFormSheet({super.key, this.sitio, this.categorias = const []});

  bool get esEdicion => sitio != null;

  @override
  State<SitioFormSheet> createState() => _SitioFormSheetState();
}

class _SitioFormSheetState extends State<SitioFormSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  String? _categoriaSeleccionada;

  final List<File> _imagenesNuevas = [];
  final List<String> _fotosExistentes = [];

  final List<String> _videos = [];

  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    final sitio = widget.sitio;

    if (sitio != null) {
      _nombreController.text = sitio['nombre']?.toString() ?? '';

      _descripcionController.text = sitio['descripcion']?.toString() ?? '';

      _direccionController.text = sitio['direccion']?.toString() ?? '';

      final ubicacion = sitio['ubicacion'];

      if (ubicacion is Map) {
        _latitudController.text = ubicacion['latitud']?.toString() ?? '';

        _longitudController.text = ubicacion['longitud']?.toString() ?? '';
      }

      final categoria = sitio['categoria'];

      if (categoria is Map) {
        _categoriaSeleccionada = categoria['_id']?.toString();
      } else if (categoria != null) {
        _categoriaSeleccionada = categoria.toString();
      }

      final fotos = sitio['fotos'];

      if (fotos is List) {
        _fotosExistentes.addAll(fotos.map((foto) => foto.toString()));
      }

      final videos = sitio['videos'];

      if (videos is List) {
        _videos.addAll(videos.map((video) => video.toString()));
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _direccionController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();

    super.dispose();
  }

  // =====================================================
  // SELECCIONAR IMAGEN
  // =====================================================

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? imagen = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (imagen == null) return;

      setState(() {
        _imagenesNuevas.add(File(imagen.path));
      });
    } catch (e) {
      _mostrarMensaje('No se pudo seleccionar la imagen');
    }
  }

  // =====================================================
  // ELIMINAR IMAGEN NUEVA
  // =====================================================

  void _eliminarImagenNueva(int index) {
    setState(() {
      _imagenesNuevas.removeAt(index);
    });
  }

  // =====================================================
  // ELIMINAR FOTO EXISTENTE
  // =====================================================

  void _eliminarFotoExistente(int index) {
    setState(() {
      _fotosExistentes.removeAt(index);
    });
  }

  // =====================================================
  // AGREGAR VIDEO
  // =====================================================

  void _agregarVideo() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar video'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'URL del video',
              hintText: 'https://...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final url = controller.text.trim();

                if (url.isNotEmpty) {
                  setState(() {
                    _videos.add(url);
                  });
                }

                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  // =====================================================
  // ELIMINAR VIDEO
  // =====================================================

  void _eliminarVideo(int index) {
    setState(() {
      _videos.removeAt(index);
    });
  }

  // =====================================================
  // GUARDAR
  // =====================================================

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      // ==================================================
      // FOTOS
      // ==================================================
      //
      // Cloudinary fue eliminado.
      //
      // Por ahora conservamos únicamente las fotos
      // que ya estaban guardadas en el sitio.
      //
      final List<String> fotos = [..._fotosExistentes];

      // ==================================================
      // DATOS DEL SITIO
      // ==================================================

      final datos = {
        'nombre': _nombreController.text.trim(),

        'descripcion': _descripcionController.text.trim(),

        'categoria': _categoriaSeleccionada,

        'direccion': _direccionController.text.trim(),

        'ubicacion': {
          'latitud': double.tryParse(_latitudController.text.trim()) ?? 0,

          'longitud': double.tryParse(_longitudController.text.trim()) ?? 0,
        },

        'fotos': fotos,

        'videos': _videos,
      };

      debugPrint('DATOS DEL SITIO: $datos');

      if (!mounted) return;

      Navigator.pop(context, datos);
    } catch (e) {
      _mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // =====================================================
  // MOSTRAR MENSAJE
  // =====================================================

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.esEdicion;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================
                // ENCABEZADO
                // =========================================
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        esEdicion
                            ? 'Editar sitio turístico'
                            : 'Nuevo sitio turístico',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =========================================
                // NOMBRE
                // =========================================
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.place),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del sitio';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // =========================================
                // DESCRIPCIÓN
                // =========================================
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa una descripción';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // =========================================
                // CATEGORÍA
                // =========================================
                DropdownButtonFormField<String>(
                  value: _categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: widget.categorias.map((categoria) {
                    final id = categoria['_id']?.toString();

                    final nombre =
                        categoria['nombre']?.toString() ?? 'Sin nombre';

                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(nombre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoriaSeleccionada = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecciona una categoría';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // =========================================
                // DIRECCIÓN
                // =========================================
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),

                const SizedBox(height: 15),

                // =========================================
                // UBICACIÓN
                // =========================================
                const Text(
                  'Ubicación',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Latitud',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: TextFormField(
                        controller: _longitudController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Longitud',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // =========================================
                // FOTOGRAFÍAS
                // =========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fotografías',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    TextButton.icon(
                      onPressed: _seleccionarImagen,
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Agregar'),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                if (_fotosExistentes.isEmpty && _imagenesNuevas.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 45,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 8),

                        Text('No hay fotografías agregadas'),
                      ],
                    ),
                  ),

                if (_fotosExistentes.isNotEmpty || _imagenesNuevas.isNotEmpty)
                  SizedBox(
                    height: 115,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // =================================
                        // FOTOS EXISTENTES
                        // =================================
                        ...List.generate(_fotosExistentes.length, (index) {
                          return _fotoExistente(_fotosExistentes[index], index);
                        }),

                        // =================================
                        // FOTOS NUEVAS
                        // =================================
                        ...List.generate(_imagenesNuevas.length, (index) {
                          return _fotoNueva(_imagenesNuevas[index], index);
                        }),

                        // =================================
                        // BOTÓN AGREGAR
                        // =================================
                        GestureDetector(
                          onTap: _seleccionarImagen,
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, size: 35),
                                Text('Agregar'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 25),

                // =========================================
                // VIDEOS
                // =========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Videos',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    TextButton.icon(
                      onPressed: _agregarVideo,
                      icon: const Icon(Icons.video_library),
                      label: const Text('Agregar'),
                    ),
                  ],
                ),

                if (_videos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'No hay videos agregados.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                ...List.generate(_videos.length, (index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.video_library),
                      title: Text(
                        _videos[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          _eliminarVideo(index);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 25),

                // =========================================
                // GUARDAR
                // =========================================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_guardando ? 'Guardando...' : 'Guardar sitio'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // FOTO NUEVA
  // =====================================================

  Widget _fotoNueva(File imagen, int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              imagen,
              width: 100,
              height: 115,
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            right: 3,
            top: 3,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                onPressed: () {
                  _eliminarImagenNueva(index);
                },
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // FOTO EXISTENTE
  // =====================================================

  Widget _fotoExistente(String url, int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 100,
              height: 115,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 115,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),

          Positioned(
            right: 3,
            top: 3,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                onPressed: () {
                  _eliminarFotoExistente(index);
                },
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
