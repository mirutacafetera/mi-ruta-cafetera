const SitioTuristico = require('../../models/sitio/contenido');

const obtenerMultimedia = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findById(req.params.id);

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.json({
      fotos: sitio.fotos || [],
      videos: sitio.videos || [],
      audioguia: sitio.audioguia || ''
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener multimedia',
      error: error.message
    });
  }
};


const actualizarMultimedia = async (req, res) => {
  try {
    const {
      fotos,
      videos,
      audioguia
    } = req.body;

    const sitio = await SitioTuristico.findByIdAndUpdate(
      req.params.id,
      {
        fotos,
        videos,
        audioguia
      },
      {
        new: true,
        runValidators: true
      }
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.json({
      mensaje: 'Multimedia actualizada correctamente',
      sitio
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