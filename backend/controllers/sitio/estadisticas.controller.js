const SitioTuristico = require('../../models/sitio/sitioturistico');
const Resena = require('../../models/sitio/resena');
const Reserva = require('../../models/sitio/reserva');

const obtenerEstadisticas = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findById(req.params.id);

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    const resenas = await Resena.countDocuments({
      sitio: req.params.id
    });

    const reservas = await Reserva.countDocuments({
      sitio: req.params.id
    });

    res.json({
      sitio: {
        id: sitio._id,
        nombre: sitio.nombre
      },
      estadisticas: {
        totalResenas: resenas,
        totalReservas: reservas
      }
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener estadísticas del sitio',
      error: error.message
    });
  }
};

module.exports = {
  obtenerEstadisticas
};