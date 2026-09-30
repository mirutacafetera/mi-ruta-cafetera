const Reserva = require('../../models/sitio/reserva');


// =====================================================
// OBTENER RESERVAS DEL SITIO
// =====================================================

const obtenerReservas = async (req, res) => {
  try {

    // -------------------------------------------------
    // COMPROBAR QUE EL SITIO PERTENECE A LA CUENTA
    // -------------------------------------------------

    if (req.usuario.sitioId !== req.params.id) {
      return res.status(403).json({
        mensaje:
          'No tienes permisos para consultar las reservas de este sitio'
      });
    }

    // -------------------------------------------------
    // BUSCAR RESERVAS
    // -------------------------------------------------

    const reservas = await Reserva.find({
      sitio: req.usuario.sitioId
    })
      .populate(
        'usuario',
        'nombre apellido correo telefono'
      )
      .populate(
        'actividad',
        'nombre descripcion precio'
      )
      .populate(
        'sitio',
        'nombre'
      )
      .sort({
        fecha: 1
      });

    res.json(reservas);

  } catch (error) {

    res.status(500).json({
      mensaje: 'Error al obtener reservas',
      error: error.message
    });

  }
};


// =====================================================
// OBTENER UNA RESERVA
// =====================================================

const obtenerReserva = async (req, res) => {
  try {

    // -------------------------------------------------
    // COMPROBAR SITIO
    // -------------------------------------------------

    if (req.usuario.sitioId !== req.params.id) {
      return res.status(403).json({
        mensaje:
          'No tienes permisos para consultar esta reserva'
      });
    }

    // -------------------------------------------------
    // BUSCAR RESERVA
    // -------------------------------------------------

    const reserva =
      await Reserva.findOne({
        _id: req.params.reservaId,
        sitio: req.usuario.sitioId
      })
        .populate(
          'usuario',
          'nombre apellido correo telefono'
        )
        .populate(
          'actividad',
          'nombre descripcion precio'
        )
        .populate(
          'sitio',
          'nombre'
        );

    if (!reserva) {
      return res.status(404).json({
        mensaje:
          'Reserva no encontrada o no pertenece a este sitio'
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


// =====================================================
// ACTUALIZAR ESTADO DE RESERVA
// =====================================================

const actualizarEstadoReserva = async (
  req,
  res
) => {
  try {

    // -------------------------------------------------
    // COMPROBAR SITIO
    // -------------------------------------------------

    if (req.usuario.sitioId !== req.params.id) {
      return res.status(403).json({
        mensaje:
          'No tienes permisos para modificar reservas de este sitio'
      });
    }

    // -------------------------------------------------
    // VALIDAR ESTADO
    // -------------------------------------------------

    const estadosPermitidos = [
      'pendiente',
      'confirmada',
      'cancelada',
      'completada'
    ];

    const {
      estado
    } = req.body;

    if (!estadosPermitidos.includes(estado)) {
      return res.status(400).json({
        mensaje:
          'Estado de reserva no válido'
      });
    }

    // -------------------------------------------------
    // ACTUALIZAR RESERVA
    // -------------------------------------------------

    const reserva =
      await Reserva.findOneAndUpdate(
        {
          _id: req.params.reservaId,
          sitio: req.usuario.sitioId
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
          'nombre apellido correo telefono'
        )
        .populate(
          'actividad',
          'nombre descripcion precio'
        )
        .populate(
          'sitio',
          'nombre'
        );

    // -------------------------------------------------
    // COMPROBAR EXISTENCIA
    // -------------------------------------------------

    if (!reserva) {
      return res.status(404).json({
        mensaje:
          'Reserva no encontrada o no pertenece a este sitio'
      });
    }

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    res.json({
      mensaje:
        'Estado de reserva actualizado correctamente',
      reserva
    });

  } catch (error) {

    res.status(500).json({
      mensaje:
        'Error al actualizar estado de reserva',
      error: error.message
    });

  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  obtenerReservas,
  obtenerReserva,
  actualizarEstadoReserva
};