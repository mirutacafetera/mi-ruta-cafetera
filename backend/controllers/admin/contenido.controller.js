
const mongoose = require('mongoose');

const ContenidoAdmin = require('../../models/admin/contenido');
const HistorialRevisionIA = require('../../models/admin/historial_revision_ia');

// AGREGAR DATOS DE REVISION IA
const agregarDatosRevision = async (contenidos) => {
  const lista = Array.isArray(contenidos)
    ? contenidos
    : contenidos
      ? [contenidos]
      : [];

  if (!lista.length) {
    return Array.isArray(contenidos) ? [] : null;
  }

  const historial = await HistorialRevisionIA.find({
    tipoSolicitud: 'contenido',
    solicitudId: { $in: lista.map((c) => c._id) },
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

  const resultado = lista.map((contenido) => ({
    ...(contenido.toObject ? contenido.toObject() : contenido),
    evaluacionIA:
      evaluaciones.get(contenido._id.toString()) || null,
  }));

  return Array.isArray(contenidos) ? resultado : resultado[0];
};

// OBTENER CONTENIDOS DEL PANEL ADMINISTRATIVO
const obtenerContenidos = async (req, res) => {
  try {
    const filtro = {
      ocultoEnAdmin: { $ne: true },
    };

    if (req.query.estado) {
      filtro.estadoPublicacion = req.query.estado;
    }

    const contenidos = await ContenidoAdmin.find(filtro)
      .populate('sitio', 'nombre ciudad departamento')
      .populate('revisadoPor', 'nombre nombreCompleto correo')
      .sort({ createdAt: -1 });

    return res.status(200).json(
      await agregarDatosRevision(contenidos)
    );
  } catch (error) {
    console.error('Error al obtener contenidos:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener los contenidos',
    });
  }
};

// OBTENER UN CONTENIDO VISIBLE EN EL PANEL
const obtenerContenido = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador no válido',
      });
    }

    const contenido = await ContenidoAdmin.findOne({
      _id: req.params.id,
      ocultoEnAdmin: { $ne: true },
    })
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

// ACTUALIZAR CONTENIDO
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

// OBTENER ID DEL ADMINISTRADOR
const obtenerAdministradorId = (req) => {
  const id =
    req.usuario?.id ||
    req.usuario?._id ||
    req.usuario?.administradorId;

  return id && mongoose.isValidObjectId(id) ? id : null;
};

// APROBAR CONTENIDO
const aprobarContenido = async (req, res) => {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(400).json({
        mensaje: 'Identificador no válido',
      });
    }

    const administradorId = obtenerAdministradorId(req);

    if (!administradorId) {
      return res.status(401).json({
        mensaje:
          'No se pudo identificar al administrador. Verifica el token de sesión.',
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

// RECHAZAR CONTENIDO
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

    const administradorId = obtenerAdministradorId(req);

    if (!administradorId) {
      return res.status(401).json({
        mensaje:
          'No se pudo identificar al administrador. Verifica el token de sesión.',
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

// DESACTIVAR CONTENIDO
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

// ACTIVAR CONTENIDO
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

// OCULTAR CONTENIDO SOLO DEL PANEL ADMINISTRATIVO
const eliminarContenido = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        mensaje: 'Identificador no válido',
      });
    }

    const contenido = await ContenidoAdmin.findOneAndUpdate(
      {
        _id: id,
        ocultoEnAdmin: { $ne: true },
      },
      {
        $set: {
          ocultoEnAdmin: true,
        },
      },
      {
        new: true,
        runValidators: true,
      }
    );

    if (!contenido) {
      const existente = await ContenidoAdmin.exists({ _id: id });

      if (!existente) {
        return res.status(404).json({
          mensaje: 'Contenido no encontrado',
        });
      }

      return res.status(200).json({
        mensaje: 'El contenido ya estaba oculto del panel administrativo',
        id,
      });
    }

    return res.status(200).json({
      mensaje: 'Contenido ocultado del panel administrativo correctamente',
      id: contenido._id,
    });
  } catch (error) {
    console.error('Error al ocultar contenido del panel:', error);

    return res.status(500).json({
      mensaje: 'Error al ocultar el contenido del panel administrativo',
    });
  }
};

// EXPORTAR FUNCIONES
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
