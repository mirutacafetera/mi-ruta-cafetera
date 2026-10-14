const mongoose = require('mongoose');

const Contenido = require('../../models/sitio/contenido');
const SitioTuristico = require('../../models/admin/sitio');

// =====================================================
// OBTENER CONTENIDOS PENDIENTES
// =====================================================

const obtenerContenidosPendientes = async (req, res) => {
  try {
    const contenidos = await Contenido.find({
      estadoPublicacion: 'pendiente_revision',
      activo: true,
    })
      .populate('sitio', 'nombre ciudad departamento')
      .sort({ createdAt: -1 });

    return res.status(200).json({
      total: contenidos.length,
      contenidos,
    });
  } catch (error) {
    console.error('Error al obtener contenidos pendientes:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener contenidos pendientes',
    });
  }
};

// =====================================================
// OBTENER DETALLE DE CONTENIDO
// =====================================================

const obtenerDetalleContenido = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador de contenido no válido',
      });
    }

    const contenido = await Contenido.findById(req.params.id)
      .populate('sitio', 'nombre ciudad departamento direccion');

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    return res.status(200).json({ contenido });
  } catch (error) {
    console.error('Error al consultar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al consultar el contenido',
    });
  }
};

// =====================================================
// APROBAR CONTENIDO
// =====================================================

const aprobarContenido = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador de contenido no válido',
      });
    }

    const contenido = await Contenido.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    if (contenido.estadoPublicacion !== 'pendiente_revision') {
      return res.status(409).json({
        mensaje: 'El contenido ya no está pendiente de revisión',
        estadoPublicacion: contenido.estadoPublicacion,
      });
    }

    if (!contenido.activo) {
      return res.status(409).json({
        mensaje: 'No se puede aprobar un contenido desactivado',
      });
    }

    contenido.estadoPublicacion = 'aprobado';
    contenido.motivoRechazo = '';
    contenido.revisadoPor = req.usuario.id;
    contenido.revisadoAt = new Date();

    await contenido.save();

    return res.status(200).json({
      mensaje: 'Contenido aprobado correctamente',
      contenido,
    });
  } catch (error) {
    console.error('Error al aprobar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al aprobar el contenido',
    });
  }
};

// =====================================================
// RECHAZAR CONTENIDO
// =====================================================

const rechazarContenido = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador de contenido no válido',
      });
    }

    const motivo = req.body?.motivoRechazo;

    if (typeof motivo !== 'string' || motivo.trim().length < 3) {
      return res.status(400).json({
        mensaje: 'Debes indicar un motivo de rechazo de al menos 3 caracteres',
      });
    }

    const contenido = await Contenido.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    if (contenido.estadoPublicacion !== 'pendiente_revision') {
      return res.status(409).json({
        mensaje: 'El contenido ya no está pendiente de revisión',
        estadoPublicacion: contenido.estadoPublicacion,
      });
    }

    contenido.estadoPublicacion = 'rechazado';
    contenido.motivoRechazo = motivo.trim();
    contenido.revisadoPor = req.usuario.id;
    contenido.revisadoAt = new Date();

    await contenido.save();

    return res.status(200).json({
      mensaje: 'Contenido rechazado. Se ha registrado el motivo.',
      contenido,
    });
  } catch (error) {
    console.error('Error al rechazar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al rechazar el contenido',
    });
  }
};

module.exports = {
  obtenerContenidosPendientes,
  obtenerDetalleContenido,
  aprobarContenido,
  rechazarContenido,
};