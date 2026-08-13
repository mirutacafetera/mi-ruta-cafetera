const Notificacion = require('../../models/usuario/notificacion');

// OBTENER NOTIFICACIONES
const obtenerNotificaciones = async (req, res) => {
  try {
    const notificaciones = await Notificacion.find({
      usuario: req.params.usuarioId,
      activo: true
    }).sort({ createdAt: -1 });

    res.json(notificaciones);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener notificaciones',
      error: error.message
    });
  }
};


// CREAR NOTIFICACIÓN
const crearNotificacion = async (req, res) => {
  try {
    const notificacion = new Notificacion(req.body);

    await notificacion.save();

    res.status(201).json({
      mensaje: 'Notificación creada correctamente',
      notificacion
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear notificación',
      error: error.message
    });
  }
};


// MARCAR COMO LEÍDA
const marcarLeida = async (req, res) => {
  try {
    const notificacion = await Notificacion.findByIdAndUpdate(
      req.params.id,
      {
        leida: true
      },
      {
        new: true
      }
    );

    if (!notificacion) {
      return res.status(404).json({
        mensaje: 'Notificación no encontrada'
      });
    }

    res.json({
      mensaje: 'Notificación marcada como leída',
      notificacion
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al marcar notificación',
      error: error.message
    });
  }
};


module.exports = {
  obtenerNotificaciones,
  crearNotificacion,
  marcarLeida
};