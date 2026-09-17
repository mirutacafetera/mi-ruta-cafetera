const Reserva = require('../../models/sitio/reserva');


// =====================================================
// OBTENER RESERVAS DEL USUARIO AUTENTICADO
// =====================================================

const obtenerReservas = async (req, res) => {
  try {

    const reservas = await Reserva.find({
      usuario: req.usuario.id
    })
      .populate(
        'sitio',
        'nombre descripcion ciudad departamento imagen'
      )
      .populate(
        'actividad',
        'nombre descripcion precio horario duracion'
      )
      .sort({
        fecha: -1
      });

    res.status(200).json(reservas);

  } catch (error) {

    res.status(500).json({
      mensaje: 'Error al obtener reservas',
      error: error.message
    });

  }
};


// =====================================================
// CREAR RESERVA
// =====================================================

const crearReserva = async (req, res) => {
  try {

    const reserva = new Reserva({

      sitio: req.body.sitio,

      actividad: req.body.actividad,

      fecha: req.body.fecha,

      cantidadPersonas: req.body.cantidadPersonas,

      precioTotal: req.body.precioTotal,

      observaciones: req.body.observaciones,

      // EL USUARIO SALE DEL TOKEN
      usuario: req.usuario.id

    });

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


// =====================================================
// ACTUALIZAR RESERVA
// =====================================================

const actualizarReserva = async (req, res) => {
  try {

    const reserva = await Reserva.findOneAndUpdate(
      {
        _id: req.params.id,

        // SOLO RESERVAS DEL USUARIO AUTENTICADO
        usuario: req.usuario.id
      },
      {
        sitio: req.body.sitio,

        actividad: req.body.actividad,

        fecha: req.body.fecha,

        cantidadPersonas: req.body.cantidadPersonas,

        precioTotal: req.body.precioTotal,

        observaciones: req.body.observaciones
      },
      {
        new: true,
        runValidators: true
      }
    );

    if (!reserva) {
      return res.status(404).json({
        mensaje:
          'Reserva no encontrada o no pertenece al usuario'
      });
    }

    res.status(200).json({
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


// =====================================================
// CANCELAR RESERVA
// =====================================================

const cancelarReserva = async (req, res) => {
  try {

    const reserva = await Reserva.findOneAndUpdate(
      {
        _id: req.params.id,

        // SOLO PUEDE CANCELAR SUS RESERVAS
        usuario: req.usuario.id
      },
      {
        estado: 'cancelada'
      },
      {
        new: true,
        runValidators: true
      }
    );

    if (!reserva) {
      return res.status(404).json({
        mensaje:
          'Reserva no encontrada o no pertenece al usuario'
      });
    }

    res.status(200).json({
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


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  obtenerReservas,
  crearReserva,
  actualizarReserva,
  cancelarReserva
};