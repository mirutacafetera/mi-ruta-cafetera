
const Notificacion = require('../../models/usuario/notificacion');

const ID_VALIDO = /^[a-f\d]{24}$/i;

// OBTENER NOTIFICACIONES DEL USUARIO AUTENTICADO
//
// La identidad sale del token. Si la ruta trae un usuarioId
// (versión anterior de la API), debe ser el del propio usuario.
const obtenerNotificaciones = async (req, res) => {
  try {
    const usuarioId = String(req.usuario.id);

    if (
      req.params.usuarioId !== undefined &&
      String(req.params.usuarioId) !== usuarioId
    ) {
      return res.status(403).json({
        mensaje: 'No tienes permisos para ver estas notificaciones'
      });
    }

    const notificaciones = await Notificacion.find({
      usuario: usuarioId,
      activo: true
    })
      .sort({ createdAt: -1 })
      .populate('sitioOrigen', 'nombre');

    res.json(notificaciones);

  } catch (error) {
    console.error('Error al obtener notificaciones:', error);

    res.status(500).json({
      mensaje: 'No se pudieron obtener las notificaciones'
    });
  }
};

// CONTAR NO LEÍDAS (contador de la campana)
const contarNoLeidas = async (req, res) => {
  try {
    const total = await Notificacion.countDocuments({
      usuario: req.usuario.id,
      activo: true,
      leida: false
    });

    res.json({ total });

  } catch (error) {
    console.error('Error al contar notificaciones:', error);

    res.status(500).json({
      mensaje: 'No se pudo contar las notificaciones'
    });
  }
};

// MARCAR COMO LEÍDA (solo las propias)
const marcarLeida = async (req, res) => {
  try {
    if (!ID_VALIDO.test(String(req.params.id || ''))) {
      return res.status(404).json({
        mensaje: 'Notificación no encontrada'
      });
    }

    const notificacion = await Notificacion.findOneAndUpdate(
      {
        _id: req.params.id,
        usuario: req.usuario.id
      },
      {
        leida: true
      },
      {
        returnDocument: 'after'
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
    console.error('Error al marcar notificación:', error);

    res.status(500).json({
      mensaje: 'No se pudo marcar la notificación'
    });
  }
};

// MARCAR TODAS COMO LEÍDAS (solo las propias)
const marcarTodasLeidas = async (req, res) => {
  try {
    const resultado = await Notificacion.updateMany(
      {
        usuario: req.usuario.id,
        activo: true,
        leida: false
      },
      {
        leida: true
      }
    );

    res.json({
      mensaje: 'Notificaciones marcadas como leídas',
      actualizadas: resultado.modifiedCount
    });

  } catch (error) {
    console.error('Error al marcar notificaciones:', error);

    res.status(500).json({
      mensaje: 'No se pudieron marcar las notificaciones'
    });
  }
};

module.exports = {
  obtenerNotificaciones,
  contarNoLeidas,
  marcarLeida,
  marcarTodasLeidas
};
