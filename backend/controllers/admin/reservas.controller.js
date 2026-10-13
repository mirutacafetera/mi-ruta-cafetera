
const Reserva = require('../../models/sitio/reserva');

// Obtener todas las reservas
const obtenerReservas = async (req, res) => {
  try {
    const { estado, sitio, fecha } = req.query;

    const filtros = {};

    if (estado) filtros.estado = estado;
    if (sitio) filtros.sitio = sitio;

    if (fecha) {
      const inicio = new Date(`${fecha}T00:00:00.000Z`);
      const fin = new Date(inicio);
      fin.setUTCDate(fin.getUTCDate() + 1);

      filtros.fecha = { $gte: inicio, $lt: fin };
    }

    const reservas = await Reserva.find(filtros)
      .populate('usuario', 'nombre apellido correo')
      .populate('sitio', 'nombre')
      .populate('actividad', 'nombre titulo')
      .sort({ createdAt: -1 });

    return res.status(200).json({
      mensaje: 'Reservas obtenidas correctamente',
      total: reservas.length,
      reservas
    });
  } catch (error) {
    console.error('Error al obtener reservas:', error);
    return res.status(500).json({
      mensaje: 'Error al obtener las reservas'
    });
  }
};

// Consultar una reserva
const obtenerReserva = async (req, res) => {
  try {
    const reserva = await Reserva.findById(req.params.id)
      .populate('usuario', 'nombre apellido correo')
      .populate('sitio', 'nombre')
      .populate('actividad', 'nombre titulo');

    if (!reserva) {
      return res.status(404).json({
        mensaje: 'Reserva no encontrada'
      });
    }

    return res.status(200).json({ reserva });
  } catch (error) {
    console.error('Error al consultar reserva:', error);
    return res.status(500).json({
      mensaje: 'Error al consultar la reserva'
    });
  }
};

// Cambiar estado de una reserva
const actualizarEstadoReserva = async (req, res) => {
  try {
    const { estado } = req.body;

    const estadosPermitidos = [
      'pendiente',
      'confirmada',
      'cancelada',
      'completada'
    ];

    if (!estadosPermitidos.includes(estado)) {
      return res.status(400).json({
        mensaje: 'Estado de reserva no válido'
      });
    }

    const reserva = await Reserva.findByIdAndUpdate(
      req.params.id,
      { estado },
      { new: true, runValidators: true }
    )
      .populate('usuario', 'nombre apellido correo')
      .populate('sitio', 'nombre')
      .populate('actividad', 'nombre titulo');

    if (!reserva) {
      return res.status(404).json({
        mensaje: 'Reserva no encontrada'
      });
    }

    return res.status(200).json({
      mensaje: 'Estado de reserva actualizado correctamente',
      reserva
    });
  } catch (error) {
    console.error('Error al actualizar reserva:', error);
    return res.status(500).json({
      mensaje: 'Error al actualizar la reserva'
    });
  }
};

module.exports = {
  obtenerReservas,
  obtenerReserva,
  actualizarEstadoReserva
};
