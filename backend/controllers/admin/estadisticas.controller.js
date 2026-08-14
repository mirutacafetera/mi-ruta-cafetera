const Estadistica = require('../../models/admin/estadistica');
const Usuario = require('../../models/usuario/usuario');
const Sitio = require('../../models/usuario/sitio');
const Resena = require('../../models/sitio/resena');
const Reserva = require('../../models/sitio/reserva');
const Visita = require('../../models/usuario/visita');

const obtenerEstadisticas = async (req, res) => {
  try {
    const usuarios = await Usuario.countDocuments();
    const sitios = await Sitio.countDocuments();
    const resenas = await Resena.countDocuments();
    const reservas = await Reserva.countDocuments();
    const visitas = await Visita.countDocuments();

    res.json({
      usuarios,
      sitios,
      resenas,
      reservas,
      visitas
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