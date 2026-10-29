const mongoose = require('mongoose');

const Actividad = require('../../models/sitio/actividad');
const HistorialRevisionIA = require('../../models/admin/historial_revision_ia');

// Agregar la última evaluación de IA a cada actividad.
const agregarEvaluacionIA = async (actividades) => {
  const lista = Array.isArray(actividades)
    ? actividades
    : actividades
      ? [actividades]
      : [];

  if (!lista.length) {
    return Array.isArray(actividades) ? [] : null;
  }

  const ids = lista.map((actividad) => actividad._id);

  const historial = await HistorialRevisionIA.find({
    tipoSolicitud: 'actividad',
    solicitudId: { $in: ids },
  })
    .sort({ createdAt: -1 })
    .lean();

  const evaluaciones = new Map();

  for (const registro of historial) {
    const id = String(registro.solicitudId);

    if (!evaluaciones.has(id)) {
      evaluaciones.set(id, {
        decision: registro.decision,
        motivo: registro.motivo,
        criterios: registro.criterios || [],
        modeloIA: registro.modeloIA || '',
        fechaDecision: registro.fechaDecision || registro.createdAt,
      });
    }
  }

  const resultado = lista.map((actividad) => {
    const datos = actividad.toObject
      ? actividad.toObject()
      : actividad;

    return {
      ...datos,
      evaluacionIA: evaluaciones.get(String(datos._id)) || null,
    };
  });

  return Array.isArray(actividades) ? resultado : resultado[0];
};

// OBTENER ACTIVIDADES POR ESTADO
const obtenerActividadesPendientes = async (req, res) => {
  try {
    const { estado } = req.query;

    const estadosPermitidos = [
      'pendiente_revision',
      'aprobado',
      'rechazado',
    ];

    const filtroEstado = estadosPermitidos.includes(estado)
      ? { estadoPublicacion: estado }
      : { estadoPublicacion: { $in: estadosPermitidos } };

    // Excluir las actividades ocultadas por el administrador.
    const filtro = {
      ...filtroEstado,
      ocultoEnAdmin: { $ne: true },
    };

    const actividades = await Actividad.find(filtro)
      .populate('sitio', 'nombre ciudad departamento')
      .sort({ createdAt: -1 });

    const resultado = await agregarEvaluacionIA(actividades);

    return res.status(200).json({
      actividades: resultado,
    });
  } catch (error) {
    console.error('Error al obtener actividades:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener actividades',
      error: error.message,
    });
  }
};

// OBTENER UNA ACTIVIDAD
const obtenerActividad = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID de la actividad no es válido',
      });
    }

    const actividad = await Actividad.findById(id).populate(
      'sitio',
      'nombre ciudad departamento',
    );

    if (!actividad) {
      return res.status(404).json({
        mensaje: 'Actividad no encontrada',
      });
    }

    const resultado = await agregarEvaluacionIA(actividad);

    return res.status(200).json({
      actividad: resultado,
    });
  } catch (error) {
    console.error('Error al obtener actividad:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener actividad',
      error: error.message,
    });
  }
};

// APROBAR ACTIVIDAD POR ADMINISTRADOR
const aprobarActividad = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID de la actividad no es válido',
      });
    }

    const actividad = await Actividad.findById(id);

    if (!actividad) {
      return res.status(404).json({
        mensaje: 'Actividad no encontrada',
      });
    }

    if (actividad.estadoPublicacion !== 'pendiente_revision') {
      return res.status(400).json({
        mensaje: 'La actividad no está pendiente de revisión',
      });
    }

    actividad.estadoPublicacion = 'aprobado';
    actividad.motivoRechazo = '';
    actividad.revisadoPor = req.usuario.id;
    actividad.revisadoAt = new Date();

    await actividad.save();

    const actualizada = await Actividad.findById(actividad._id).populate(
      'sitio',
      'nombre ciudad departamento',
    );

    const resultado = await agregarEvaluacionIA(actualizada);

    return res.status(200).json({
      mensaje: 'Actividad aprobada correctamente',
      actividad: resultado,
    });
  } catch (error) {
    console.error('Error al aprobar actividad:', error);

    return res.status(500).json({
      mensaje: 'Error al aprobar actividad',
      error: error.message,
    });
  }
};

// RECHAZAR ACTIVIDAD POR ADMINISTRADOR
const rechazarActividad = async (req, res) => {
  try {
    const { id } = req.params;
    const { motivoRechazo } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID de la actividad no es válido',
      });
    }

    if (
      typeof motivoRechazo !== 'string' ||
      motivoRechazo.trim().length < 3
    ) {
      return res.status(400).json({
        mensaje: 'Debes indicar un motivo de rechazo válido',
      });
    }

    const actividad = await Actividad.findById(id);

    if (!actividad) {
      return res.status(404).json({
        mensaje: 'Actividad no encontrada',
      });
    }

    if (actividad.estadoPublicacion !== 'pendiente_revision') {
      return res.status(400).json({
        mensaje: 'La actividad no está pendiente de revisión',
      });
    }

    actividad.estadoPublicacion = 'rechazado';
    actividad.motivoRechazo = motivoRechazo.trim();
    actividad.revisadoPor = req.usuario.id;
    actividad.revisadoAt = new Date();

    await actividad.save();

    const actualizada = await Actividad.findById(actividad._id).populate(
      'sitio',
      'nombre ciudad departamento',
    );

    const resultado = await agregarEvaluacionIA(actualizada);

    return res.status(200).json({
      mensaje: 'Actividad rechazada correctamente',
      actividad: resultado,
    });
  } catch (error) {
    console.error('Error al rechazar actividad:', error);

    return res.status(500).json({
      mensaje: 'Error al rechazar actividad',
      error: error.message,
    });
  }
};

// OCULTAR ACTIVIDAD ÚNICAMENTE DEL PANEL ADMINISTRATIVO
const eliminarActividad = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID de la actividad no es válido',
      });
    }

    // Ocultar del panel administrativo sin borrar el documento
    // ni modificar la publicación del sitio.
    const actividad = await Actividad.findOneAndUpdate(
      {
        _id: id,
        ocultoEnAdmin: { $ne: true },
      },
      {
        $set: { ocultoEnAdmin: true },
      },
      {
        new: true,
        runValidators: true,
      },
    );

    if (!actividad) {
      const existente = await Actividad.exists({ _id: id });

      if (!existente) {
        return res.status(404).json({
          mensaje: 'Actividad no encontrada',
        });
      }

      // Ya estaba oculta. Respuesta sin mensaje de éxito.
      return res.status(200).json({ id });
    }

    // Respuesta exitosa sin el texto de la notificación roja.
    return res.status(200).json({ id });
  } catch (error) {
    console.error('Error al ocultar actividad del panel:', error);

    return res.status(500).json({
      mensaje: 'Error al ocultar actividad del panel administrativo',
      error: error.message,
    });
  }
};

module.exports = {
  obtenerActividadesPendientes,
  obtenerActividad,
  aprobarActividad,
  rechazarActividad,
  eliminarActividad,
};