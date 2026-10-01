const mongoose = require('mongoose');

const Actividad = require('../../models/sitio/actividad');
const SitioTuristico = require('../../models/admin/sitio');

// =====================================================
// OBTENER ACTIVIDADES PENDIENTES
// =====================================================

const obtenerActividadesPendientes = async (req, res) => {
  try {
    const actividades = await Actividad.find({
      estadoPublicacion: 'pendiente_revision'
    })
      .populate(
        'sitio',
        'nombre ciudad departamento'
      )
      .sort({
        createdAt: -1
      });

    return res.status(200).json({
      actividades
    });
  } catch (error) {
    console.error(
      '❌ Error al obtener actividades pendientes:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al obtener actividades pendientes',
      error: error.message
    });
  }
};

// =====================================================
// OBTENER UNA ACTIVIDAD
// =====================================================

const obtenerActividad = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID de la actividad no es válido'
      });
    }

    const actividad = await Actividad.findById(id)
      .populate(
        'sitio',
        'nombre ciudad departamento'
      );

    if (!actividad) {
      return res.status(404).json({
        mensaje: 'Actividad no encontrada'
      });
    }

    return res.status(200).json({
      actividad
    });
  } catch (error) {
    console.error(
      '❌ Error al obtener actividad:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al obtener actividad',
      error: error.message
    });
  }
};

// =====================================================
// APROBAR ACTIVIDAD
// =====================================================

const aprobarActividad = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID de la actividad no es válido'
      });
    }

    const actividad = await Actividad.findById(id);

    if (!actividad) {
      return res.status(404).json({
        mensaje: 'Actividad no encontrada'
      });
    }

    if (
      actividad.estadoPublicacion !==
      'pendiente_revision'
    ) {
      return res.status(400).json({
        mensaje:
          'La actividad no está pendiente de revisión'
      });
    }

    actividad.estadoPublicacion = 'aprobado';
    actividad.motivoRechazo = '';
    actividad.revisadoPor = req.usuario.id;
    actividad.revisadoAt = new Date();

    await actividad.save();

    const actividadActualizada =
      await Actividad.findById(actividad._id)
        .populate(
          'sitio',
          'nombre ciudad departamento'
        );

    return res.status(200).json({
      mensaje:
        'Actividad aprobada correctamente',
      actividad: actividadActualizada
    });
  } catch (error) {
    console.error(
      '❌ Error al aprobar actividad:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al aprobar actividad',
      error: error.message
    });
  }
};

// =====================================================
// RECHAZAR ACTIVIDAD
// =====================================================

const rechazarActividad = async (req, res) => {
  try {
    const { id } = req.params;
    const { motivoRechazo } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID de la actividad no es válido'
      });
    }

    if (
      !motivoRechazo ||
      motivoRechazo.trim().length < 3
    ) {
      return res.status(400).json({
        mensaje:
          'Debes indicar el motivo del rechazo'
      });
    }

    const actividad = await Actividad.findById(id);

    if (!actividad) {
      return res.status(404).json({
        mensaje: 'Actividad no encontrada'
      });
    }

    if (
      actividad.estadoPublicacion !==
      'pendiente_revision'
    ) {
      return res.status(400).json({
        mensaje:
          'La actividad no está pendiente de revisión'
      });
    }

    actividad.estadoPublicacion = 'rechazado';

    actividad.motivoRechazo =
      motivoRechazo.trim();

    actividad.revisadoPor = req.usuario.id;
    actividad.revisadoAt = new Date();

    await actividad.save();

    const actividadActualizada =
      await Actividad.findById(actividad._id)
        .populate(
          'sitio',
          'nombre ciudad departamento'
        );

    return res.status(200).json({
      mensaje:
        'Actividad rechazada correctamente',
      actividad: actividadActualizada
    });
  } catch (error) {
    console.error(
      '❌ Error al rechazar actividad:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al rechazar actividad',
      error: error.message
    });
  }
};

module.exports = {
  obtenerActividadesPendientes,
  obtenerActividad,
  aprobarActividad,
  rechazarActividad
};