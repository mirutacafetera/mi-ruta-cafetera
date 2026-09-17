const Reserva = require('../../models/sitio/reserva');


// OBTENER TODAS LAS RESERVAS DEL SITIO
const obtenerReservas = async (req, res) => {
  try {
    const reservas = await Reserva.find({
      sitio: req.params.id
    })
      .populate(
        'usuario',
        'nombre apellido telefono'
      )
      .populate(
        'actividad',
        'nombre descripcion precio horario duracion'
      )
      .populate(
        'sitio',
        'nombre descripcion direccion ciudad departamento imagen'
      )
      .sort({ fecha: 1 });

    res.json(reservas);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener reservas',
      error: error.message
    });
  }
};


// OBTENER UNA RESERVA ESPECÍFICA
const obtenerReserva = async (req, res) => {
  try {
    const reserva = await Reserva.findOne({
      _id: req.params.reservaId,
      sitio: req.params.id
    })
      .populate(
        'usuario',
        'nombre apellido telefono'
      )
      .populate(
        'actividad',
        'nombre descripcion precio horario duracion'
      )
      .populate(
        'sitio',
        'nombre descripcion direccion ciudad departamento imagen'
      );

    if (!reserva) {
      return res.status(404).json({
        mensaje: 'Reserva no encontrada'
      });
    }

    res.json(reserva);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener reserva',
      error: error.message
    });
  }
};


// ACTUALIZAR ESTADO DE LA RESERVA
const actualizarEstadoReserva = async (req, res) => {
  try {
    const { estado } = req.body;

    const reserva = await Reserva.findOneAndUpdate(
      {
        _id: req.params.reservaId,
        sitio: req.params.id
      },
      {
        estado
      },
      {
        new: true,
        runValidators: true
      }
    )
      .populate(
        'usuario',
        'nombre apellido telefono'
      )
      .populate(
        'actividad',
        'nombre descripcion precio horario duracion'
      )
      .populate(
        'sitio',
        'nombre descripcion direccion ciudad departamento imagen'
      );

    if (!reserva) {
      return res.status(404).json({
        mensaje: 'Reserva no encontrada'
      });
    }

    res.json({
      mensaje: 'Estado de la reserva actualizado correctamente',
      reserva
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar estado de la reserva',
      error: error.message
    });
  }
};


module.exports = {
  obtenerReservas,
  obtenerReserva,
  actualizarEstadoReserva
};