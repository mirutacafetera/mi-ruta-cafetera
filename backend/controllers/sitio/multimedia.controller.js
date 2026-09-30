const Contenido = require('../../models/sitio/contenido');


// =====================================================
// OBTENER MULTIMEDIA
// =====================================================

const obtenerMultimedia = async (req, res) => {
  try {

    const multimedia = await Contenido.find({
      sitio: req.params.id,
      tipo: {
        $in: [
          'imagen',
          'video',
          'audio'
        ]
      },
      activo: true
    }).select(
      'tipo titulo descripcion url idioma activo'
    );

    res.json(multimedia);

  } catch (error) {

    res.status(500).json({
      mensaje: 'Error al obtener multimedia',
      error: error.message
    });

  }
};


// =====================================================
// ACTUALIZAR MULTIMEDIA
// =====================================================

const actualizarMultimedia = async (req, res) => {
  try {

    // -------------------------------------------------
    // BUSCAR EL CONTENIDO
    // -------------------------------------------------

    const contenido =
      await Contenido.findOne({
        _id: req.params.id,
        sitio: req.usuario.sitioId
      });

    // -------------------------------------------------
    // COMPROBAR PROPIEDAD
    // -------------------------------------------------

    if (!contenido) {
      return res.status(404).json({
        mensaje:
          'Contenido multimedia no encontrado o no pertenece a este sitio'
      });
    }

    // -------------------------------------------------
    // ACTUALIZAR CAMPOS PERMITIDOS
    // -------------------------------------------------

    contenido.tipo = req.body.tipo;
    contenido.titulo = req.body.titulo;
    contenido.descripcion = req.body.descripcion;
    contenido.url = req.body.url;
    contenido.idioma = req.body.idioma;
    contenido.activo = req.body.activo;

    await contenido.save();

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    res.json({
      mensaje: 'Multimedia actualizada correctamente',
      multimedia: contenido
    });

  } catch (error) {

    res.status(500).json({
      mensaje: 'Error al actualizar multimedia',
      error: error.message
    });

  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  obtenerMultimedia,
  actualizarMultimedia
};