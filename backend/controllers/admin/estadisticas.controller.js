
const Estadistica = require('../../models/admin/estadistica');
const Usuario = require('../../models/usuario/usuario');
const Resena = require('../../models/sitio/resena');
const Reserva = require('../../models/sitio/reserva');
const Ayuda = require('../../models/usuario/ayuda');

const obtenerEstadisticas = async (req, res) => {
  try {
    const [
      usuarios,
      resenas,
      reservas,
      reportes,
      reportesPendientes,
      reportesEnRevision,
      reportesResueltos
    ] = await Promise.all([
      Usuario.countDocuments(),
      Resena.countDocuments(),
      Reserva.countDocuments(),
      Ayuda.countDocuments(),
      Ayuda.countDocuments({ estado: 'pendiente' }),
      Ayuda.countDocuments({ estado: 'en_revision' }),
      Ayuda.countDocuments({ estado: 'resuelto' })
    ]);

    res.json({
      usuarios,
      resenas,
      reservas,
      reportes,
      reportesPendientes,
      reportesEnRevision,
      reportesResueltos
    });
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener estadísticas',
      error: error.message
    });
  }
};

const obtenerEstadisticasGuardadas = async (req, res) => {
  try {
    const estadisticas = await Estadistica.find()
      .sort({ fecha: -1 });

    res.json(estadisticas);
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener estadísticas guardadas',
      error: error.message
    });
  }
};

const crearEstadistica = async (req, res) => {
  try {
    const estadistica = new Estadistica(req.body);

    await estadistica.save();

    res.status(201).json({
      mensaje: 'Estadística registrada correctamente',
      estadistica
    });
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al registrar estadística',
      error: error.message
    });
  }
};

module.exports = {
  obtenerEstadisticas,
  obtenerEstadisticasGuardadas,
  crearEstadistica
};
