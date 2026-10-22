
const mongoose = require('mongoose');

const ContenidoAdmin = require('../../models/admin/contenido');
const HistorialRevisionIA = require('../../models/admin/historial_revision_ia');

const agregarDatosRevision = async (contenidos) => {
  const lista = Array.isArray(contenidos)
    ? contenidos
    : contenidos
      ? [contenidos]
      : [];

  if (!lista.length) {
    return Array.isArray(contenidos) ? [] : null;
  }

  const ids = lista.map((contenido) => contenido._id);

  const historial = await HistorialRevisionIA.find({
    tipoSolicitud: 'contenido',
    solicitudId: { $in: ids },
  })
    .sort({ fechaDecision: -1 })
    .lean();

  const evaluaciones = new Map();

  for (const revision of historial) {
    const id = revision.solicitudId.toString();

    if (!evaluaciones.has(id)) {
      evaluaciones.set(id, {
        decision: revision.decision,
        motivo: revision.motivo,
        criterios: revision.criterios || [],
        modeloIA: revision.modeloIA || '',
        fechaDecision: revision.fechaDecision,
      });
    }
  }

  const resultado = lista.map((contenido) => {
    const documento = contenido.toObject
      ? contenido.toObject()
      : contenido;

    return {
      ...documento,
      evaluacionIA:
        evaluaciones.get(contenido._id.toString()) || null,
    };
  });

  return Array.isArray(contenidos) ? resultado : resultado[0];
};

const obtenerContenidos = async (req, res) => {
  try {
    const filtro = {};

    if (req.query.estado) {
      filtro.estadoPublicacion = req.query.estado;
    }

    const contenidos = await ContenidoAdmin.find(filtro)
      .populate('sitio', 'nombre ciudad departamento')
      .populate('revisadoPor', 'nombre nombreCompleto correo')
      .sort({ createdAt: -1 });

    const resultado = await agregarDatosRevision(contenidos);

    console.log(
      'CONTENIDOS Y REVISIONES:',
      JSON.stringify(
        resultado.map((contenido) => ({
          id: contenido._id,
          titulo: contenido.titulo,
          estadoPublicacion: contenido.estadoPublicacion,
          revisadoPor: contenido.revisadoPor,
          revisadoAt: contenido.revisadoAt,
          evaluacionIA: contenido.evaluacionIA,
        })),
        null,
        2
      )
    );

    return res.status(200).json(resultado);
  } catch (error) {
    console.error('Error al obtener contenidos:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener los contenidos',
    });
  }
};

const obtenerContenido = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador no válido',
      });
    }

    const contenido = await ContenidoAdmin.findById(req.params.id)
      .populate('sitio', 'nombre ciudad departamento')
      .populate('revisadoPor', 'nombre nombreCompleto correo');

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    return res.status(200).json(
      await agregarDatosRevision(contenido)
    );
  } catch (error) {
    console.error('Error al obtener contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener el contenido',
    });
  }
};

const actualizarContenido = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador no válido',
      });
    }

    const contenido = await ContenidoAdmin.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    const campos = [
      'titulo',
      'descripcion',
      'url',
      'idioma',
      'imagenPrincipal',
      'imagenes',
      'audioGuias',
    ];

    for (const campo of campos) {
      if (req.body[campo] !== undefined) {
        contenido[campo] = req.body[campo];
      }
    }

    await contenido.save();
    await contenido.populate('sitio', 'nombre ciudad departamento');
    await contenido.populate(
      'revisadoPor',
      'nombre nombreCompleto correo'
    );

    return res.status(200).json({
      mensaje: 'Contenido actualizado correctamente',
      contenido: await agregarDatosRevision(contenido),
    });
  } catch (error) {
    console.error('Error al actualizar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al actualizar el contenido',
    });
  }
};

const aprobarContenido = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador no válido',
      });
    }

    const contenido = await ContenidoAdmin.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    if (contenido.estadoPublicacion !== 'pendiente_revision') {
      return res.status(409).json({
        mensaje: 'El contenido ya fue revisado',
      });
    }

    const administradorId = req.usuario?.id || req.usuario?._id;

    if (
      !administradorId ||
      !mongoose.isValidObjectId(administradorId)
    ) {
      console.error(
        'No se identificó al administrador:',
        req.usuario
      );

      return res.status(401).json({
        mensaje:
          'No se pudo identificar al administrador. Verifica el token de sesión.',
      });
    }

    contenido.estadoPublicacion = 'aprobado';
    contenido.motivoRechazo = '';
    contenido.activo = true;
    contenido.revisadoPor = administradorId;
    contenido.revisadoAt = new Date();

    await contenido.save();
    await contenido.populate('sitio', 'nombre ciudad departamento');
    await contenido.populate(
      'revisadoPor',
      'nombre nombreCompleto correo'
    );

    return res.status(200).json({
      mensaje: 'Contenido aprobado correctamente',
      contenido: await agregarDatosRevision(contenido),
    });
  } catch (error) {
    console.error('Error al aprobar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al aprobar el contenido',
    });
  }
};

const rechazarContenido = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador no válido',
      });
    }

    const motivo = req.body?.motivoRechazo;

    if (typeof motivo !== 'string' || motivo.trim().length < 3) {
      return res.status(400).json({
        mensaje: 'Debes indicar un motivo de rechazo válido',
      });
    }

    const contenido = await ContenidoAdmin.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    if (contenido.estadoPublicacion !== 'pendiente_revision') {
      return res.status(409).json({
        mensaje: 'El contenido ya fue revisado',
      });
    }

    const administradorId = req.usuario?.id || req.usuario?._id;

    if (
      !administradorId ||
      !mongoose.isValidObjectId(administradorId)
    ) {
      console.error(
        'No se identificó al administrador:',
        req.usuario
      );

      return res.status(401).json({
        mensaje:
          'No se pudo identificar al administrador. Verifica el token de sesión.',
      });
    }

    contenido.estadoPublicacion = 'rechazado';
    contenido.motivoRechazo = motivo.trim();
    contenido.activo = false;
    contenido.revisadoPor = administradorId;
    contenido.revisadoAt = new Date();

    await contenido.save();
    await contenido.populate('sitio', 'nombre ciudad departamento');
    await contenido.populate(
      'revisadoPor',
      'nombre nombreCompleto correo'
    );

    return res.status(200).json({
      mensaje: 'Contenido rechazado correctamente',
      contenido: await agregarDatosRevision(contenido),
    });
  } catch (error) {
    console.error('Error al rechazar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al rechazar el contenido',
    });
  }
};

const desactivarContenido = async (req, res) => {
  try {
    const contenido = await ContenidoAdmin.findByIdAndUpdate(
      req.params.id,
      { activo: false },
      { new: true }
    );

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    return res.status(200).json({
      mensaje: 'Contenido desactivado correctamente',
      contenido,
    });
  } catch (error) {
    console.error('Error al desactivar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al desactivar el contenido',
    });
  }
};

const activarContenido = async (req, res) => {
  try {
    const contenido = await ContenidoAdmin.findByIdAndUpdate(
      req.params.id,
      { activo: true },
      { new: true }
    );

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    return res.status(200).json({
      mensaje: 'Contenido activado correctamente',
      contenido,
    });
  } catch (error) {
    console.error('Error al activar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al activar el contenido',
    });
  }
};

const eliminarContenido = async (req, res) => {
  try {
    const contenido = await ContenidoAdmin.findByIdAndDelete(
      req.params.id
    );

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    return res.status(200).json({
      mensaje: 'Contenido eliminado correctamente',
    });
  } catch (error) {
    console.error('Error al eliminar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al eliminar el contenido',
    });
  }
};

module.exports = {
  obtenerContenidos,
  obtenerContenido,
  actualizarContenido,
  aprobarContenido,
  rechazarContenido,
  desactivarContenido,
  activarContenido,
  eliminarContenido,
};
