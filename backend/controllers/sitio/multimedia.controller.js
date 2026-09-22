const Contenido = require('../../models/sitio/contenido');


// ======================================================
// OBTENER MULTIMEDIA DE UN SITIO
// ======================================================

const obtenerMultimedia = async (req, res) => {
  try {

    const multimedia = await Contenido.find(
      {
        sitio: req.params.id,

        tipo: {
          $in: ['imagen', 'video', 'audio']
        },

        activo: true
      },
      {
        _id: 1,
        tipo: 1,
        titulo: 1,
        descripcion: 1,
        url: 1,
        idioma: 1,
        activo: 1
      }
    );

    res.status(200).json(multimedia);

  } catch (error) {

    res.status(500).json({
      mensaje: 'Error al obtener multimedia',
      error: error.message
    });

  }
};


// ======================================================
// ACTUALIZAR MULTIMEDIA
// ======================================================

const actualizarMultimedia = async (req, res) => {
  try {

    const {
      tipo,
      titulo,
      descripcion,
      url,
      idioma,
      activo
    } = req.body;


    const multimedia = await Contenido.findByIdAndUpdate(
      req.params.id,
      {
        tipo,
        titulo,
        descripcion,
        url,
        idioma,
        activo
      },
      {
        new: true,
        runValidators: true
      }
    );


    if (!multimedia) {

      return res.status(404).json({
        mensaje: 'Multimedia no encontrada'
      });

    }


    res.status(200).json({
      mensaje: 'Multimedia actualizada correctamente',
      multimedia
    });


  } catch (error) {

    res.status(500).json({
      mensaje: 'Error al actualizar multimedia',
      error: error.message
    });

  }
};


module.exports = {
  obtenerMultimedia,
  actualizarMultimedia
};