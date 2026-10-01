const Contenido = require('../../models/sitio/contenido');

// ======================================================
// OBTENER MULTIMEDIA DE UN SITIO
// ======================================================

const obtenerMultimedia = async (req, res) => {
  try {
    const multimedia = await Contenido.find({
      sitio: req.params.id,
      tipo: {
        $in: ['imagen', 'video', 'audio'],
      },
      activo: true,
    }).select(
      'tipo titulo descripcion url idioma activo'
    );

    return res.status(200).json(multimedia);
  } catch (error) {
    console.error(
      '❌ Error al obtener multimedia:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al obtener multimedia',
      error: error.message,
    });
  }
};

// ======================================================
// SUBIR IMAGEN
// ======================================================

const subirImagen = async (req, res) => {
  try {
    // --------------------------------------------------
    // VERIFICAR ARCHIVO
    // --------------------------------------------------

    if (!req.file) {
      return res.status(400).json({
        mensaje: 'Debes seleccionar una imagen.',
      });
    }

    // --------------------------------------------------
    // VERIFICAR SITIO ASOCIADO
    // --------------------------------------------------

    if (!req.usuario || !req.usuario.sitioId) {
      return res.status(403).json({
        mensaje:
          'La cuenta no tiene un sitio turístico asociado.',
      });
    }

    // --------------------------------------------------
    // CREAR CONTENIDO
    // --------------------------------------------------

    const contenido = await Contenido.create({
      sitio: req.usuario.sitioId,

      tipo: 'imagen',

      titulo:
        req.body.titulo?.trim() ||
        req.file.originalname,

      descripcion:
        req.body.descripcion?.trim() || '',

      url: req.file.path,

      idioma:
        req.body.idioma?.trim() || 'es',

      activo: true,
    });

    // --------------------------------------------------
    // RESPUESTA
    // --------------------------------------------------

    return res.status(201).json({
      mensaje: 'Imagen subida correctamente.',
      multimedia: contenido,
    });
  } catch (error) {
    console.error(
      '❌ Error al subir imagen:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al subir la imagen.',
      error: error.message,
    });
  }
};

// ======================================================
// ACTUALIZAR MULTIMEDIA
// ======================================================

const actualizarMultimedia = async (req, res) => {
  try {
    const contenido = await Contenido.findOne({
      _id: req.params.id,
      sitio: req.usuario.sitioId,
    });

    if (!contenido) {
      return res.status(404).json({
        mensaje:
          'Contenido multimedia no encontrado o no pertenece a este sitio',
      });
    }

    contenido.titulo =
      req.body.titulo ?? contenido.titulo;

    contenido.descripcion =
      req.body.descripcion ?? contenido.descripcion;

    contenido.url =
      req.body.url ?? contenido.url;

    contenido.idioma =
      req.body.idioma ?? contenido.idioma;

    contenido.activo =
      req.body.activo ?? contenido.activo;

    await contenido.save();

    return res.status(200).json({
      mensaje: 'Multimedia actualizada correctamente',
      multimedia: contenido,
    });
  } catch (error) {
    console.error(
      '❌ Error al actualizar multimedia:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al actualizar multimedia',
      error: error.message,
    });
  }
};

module.exports = {
  obtenerMultimedia,
  subirImagen,
  actualizarMultimedia,
};