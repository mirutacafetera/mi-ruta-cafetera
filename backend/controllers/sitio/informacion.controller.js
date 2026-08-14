const SitioTuristico = require('../../models/sitio/sitioturistico');

const obtenerInformacion = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findById(req.params.id);

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.json(sitio);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener información del sitio',
      error: error.message
    });
  }
};


const actualizarInformacion = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findByIdAndUpdate(
      req.params.id,
      req.body,
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
      mensaje: 'Información del sitio actualizada correctamente',
      sitio
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar información del sitio',
      error: error.message
    });
  }
};


module.exports = {
  obtenerInformacion,
  actualizarInformacion
};