const Reserva = require('../../models/sitio/reserva');

const {
  crearNotificacion
} = require('../../services/notificacion.service');


// =====================================================
// OBTENER TODAS LAS RESERVAS DEL SITIO
// =====================================================

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
// OBTENER UNA RESERVA ESPECÍFICA
// =====================================================

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


// =====================================================
// ACTUALIZAR ESTADO DE LA RESERVA
// =====================================================

const actualizarEstadoReserva = async (req, res) => {
  try {

    const { estado } = req.body;

    // -------------------------------------------------
    // VALIDAR ESTADO
    // -------------------------------------------------

    const estadosPermitidos = [
      'pendiente',
      'confirmada',
      'cancelada',
      'completada'
    ];

    if (!estadosPermitidos.includes(estado)) {
      return res.status(400).json({
        mensaje:
          'Estado no válido. Los estados permitidos son: pendiente, confirmada, cancelada y completada'
      });
    }

    // -------------------------------------------------
    // BUSCAR Y ACTUALIZAR RESERVA
    // -------------------------------------------------

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

    // -------------------------------------------------
    // PREPARAR NOTIFICACIÓN
    // -------------------------------------------------

    let titulo = 'Actualización de reserva';

    let mensaje =
      'El estado de tu reserva ha sido actualizado.';

    if (estado === 'pendiente') {
      titulo = 'Reserva pendiente';
      mensaje =
        'Tu reserva se encuentra pendiente de confirmación.';
    }

    if (estado === 'confirmada') {
      titulo = 'Reserva confirmada';
      mensaje =
        'Tu reserva ha sido confirmada correctamente.';
    }

    if (estado === 'cancelada') {
      titulo = 'Reserva cancelada';
      mensaje =
        'Tu reserva ha sido cancelada.';
    }

    if (estado === 'completada') {
      titulo = 'Reserva completada';
      mensaje =
        'Tu reserva ha sido completada correctamente.';
    }

    // -------------------------------------------------
    // CREAR NOTIFICACIÓN PARA EL USUARIO
    // -------------------------------------------------

    await crearNotificacion(
      reserva.usuario._id,
      titulo,
      mensaje,
      'reserva'
    );

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    res.status(200).json({
      mensaje:
        'Estado de la reserva actualizado correctamente',
      reserva
    });

  } catch (error) {

    console.error(
      'Error al actualizar estado de la reserva:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al actualizar estado de la reserva',
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