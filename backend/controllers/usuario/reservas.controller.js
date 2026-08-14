const Reserva = require('../../models/sitio/reserva');

// OBTENER RESERVAS DEL USUARIO
const obtenerReservas = async (req, res) => {
  try {
    const reservas = await Reserva.find({
      usuario: req.params.usuarioId
    })
      .populate('sitio')
      .sort({ fecha: -1 });

    res.json(reservas);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener reservas',
      error: error.message
    });
  }
};


// CREAR RESERVA
const crearReserva = async (req, res) => {
  try {
    const reserva = new Reserva(req.body);

    await reserva.save();

    res.status(201).json({
      mensaje: 'Reserva creada correctamente',
      reserva
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear reserva',
      error: error.message
    });
  }
};


// ACTUALIZAR RESERVA
const actualizarReserva = async (req, res) => {
  try {
    const reserva = await Reserva.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!reserva) {
      return res.status(404).json({
        mensaje: 'Reserva no encontrada'
      });
    }

    res.json({
      mensaje: 'Reserva actualizada correctamente',
      reserva
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar reserva',
      error: error.message
    });
  }
};


// CANCELAR RESERVA
const cancelarReserva = async (req, res) => {
  try {
    const reserva = await Reserva.findByIdAndUpdate(
      req.params.id,
      {
        estado: 'cancelada'
      },
      {
        new: true
      }
    );

    if (!reserva) {
      return res.status(404).json({
        mensaje: 'Reserva no encontrada'
      });
    }

    res.json({
      mensaje: 'Reserva cancelada correctamente',
      reserva
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al cancelar reserva',
      error: error.message
    });
  }
};


module.exports = {
  obtenerReservas,
  crearReserva,
  actualizarReserva,
  cancelarReserva
};