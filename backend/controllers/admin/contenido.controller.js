
const ContenidoAdmin = require('../../models/admin/contenido');

// ============================================================
// OBTENER CONTENIDOS PARA MODERACIÓN
// ============================================================

const obtenerContenidos = async (req, res) => {
  try {
    const filtro = {};

    if (req.query.estado) {
      const estadosPermitidos = [
        'pendiente_revision',
        'aprobado',
        'rechazado',
      ];

      if (!estadosPermitidos.includes(req.query.estado)) {
        return res.status(400).json({
          mensaje: 'El estado de publicación no es válido.',
        });
      }

      filtro.estadoPublicacion = req.query.estado;
    }

    const contenidos = await ContenidoAdmin.find(filtro)
      .populate('sitio', 'nombre')
      .sort({ createdAt: -1 });

    return res.json(contenidos);
  } catch (error) {
    return res.status(500).json({
      mensaje: 'Error al obtener contenidos.',
      error: error.message,
    });
  }
};

// ============================================================
// OBTENER UN CONTENIDO
// ============================================================

const obtenerContenido = async (req, res) => {
  try {
    const contenido = await ContenidoAdmin.findById(req.params.id)
      .populate('sitio', 'nombre');

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado.',
      });
    }

    return res.json(contenido);
  } catch (error) {
    return res.status(500).json({
      mensaje: 'Error al obtener contenido.',
      error: error.message,
    });
  }
};

// ============================================================
// ACTUALIZAR CONTENIDO Y MULTIMEDIA
// ============================================================

const actualizarContenido = async (req, res) => {
  try {
    const contenido = await ContenidoAdmin.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado.',
      });
    }

    const camposTexto = [
      'tipo',
      'titulo',
      'descripcion',
      'url',
      'idioma',
      'imagenPrincipal',
    ];

    for (const campo of camposTexto) {
      if (req.body[campo] !== undefined) {
        if (typeof req.body[campo] !== 'string') {
          return res.status(400).json({
            mensaje: `El campo ${campo} debe ser un texto.`,
          });
        }

        contenido[campo] = req.body[campo].trim();
      }
    }

    if (
      req.body.imagenes !== undefined &&
      !Array.isArray(req.body.imagenes)
    ) {
      return res.status(400).json({
        mensaje: 'Las imágenes deben enviarse como una lista.',
      });
    }

    if (req.body.imagenes !== undefined) {
      if (
        req.body.imagenes.some(
          (imagen) => typeof imagen !== 'string'
        )
      ) {
        return res.status(400).json({
          mensaje: 'Cada imagen debe contener una URL de texto.',
        });
      }

      contenido.imagenes = req.body.imagenes.map(
        (imagen) => imagen.trim()
      );
    }

    if (
      req.body.audioGuias !== undefined &&
      !Array.isArray(req.body.audioGuias)
    ) {
      return res.status(400).json({
        mensaje: 'Las audioguías deben enviarse como una lista.',
      });
    }

    if (req.body.audioGuias !== undefined) {
      const audiosValidos = req.body.audioGuias.every(
        (audio) =>
          audio &&
          typeof audio.titulo === 'string' &&
          audio.titulo.trim().length >= 2 &&
          typeof audio.url === 'string' &&
          audio.url.trim().length > 0 &&
          (audio.descripcion === undefined ||
            typeof audio.descripcion === 'string') &&
          (audio.duracion === undefined ||
            typeof audio.duracion === 'string') &&
          (audio.publicId === undefined ||
            typeof audio.publicId === 'string')
      );

      if (!audiosValidos) {
        return res.status(400).json({
          mensaje: 'Los datos de una o más audioguías no son válidos.',
        });
      }

      contenido.audioGuias = req.body.audioGuias.map((audio) => ({
        ...(audio._id ? { _id: audio._id } : {}),
        titulo: audio.titulo.trim(),
        descripcion: (audio.descripcion || '').trim(),
        url: audio.url.trim(),
        duracion: (audio.duracion || '').trim(),
        publicId: (audio.publicId || '').trim(),
      }));
    }

    await contenido.save();

    await contenido.populate('sitio', 'nombre');

    return res.json({
      mensaje: 'Contenido actualizado correctamente.',
      contenido,
    });
  } catch (error) {
    return res.status(500).json({
      mensaje: 'Error al actualizar contenido.',
      error: error.message,
    });
  }
};

// ============================================================
// APROBAR CONTENIDO
// ============================================================

const aprobarContenido = async (req, res) => {
  try {
    const contenido = await ContenidoAdmin.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado.',
      });
    }

    if (contenido.estadoPublicacion !== 'pendiente_revision') {
      return res.status(400).json({
        mensaje: 'Solo se pueden aceptar contenidos pendientes de revisión.',
      });
    }

    contenido.estadoPublicacion = 'aprobado';
    contenido.motivoRechazo = '';
    contenido.activo = true;

    await contenido.save();

    return res.json({
      mensaje: 'Contenido aprobado correctamente.',
      contenido,
    });
  } catch (error) {
    return res.status(500).json({
      mensaje: 'Error al aprobar contenido.',
      error: error.message,
    });
  }
};

// ============================================================
// RECHAZAR CONTENIDO
// ============================================================

const rechazarContenido = async (req, res) => {
  try {
    const motivo = String(req.body.motivoRechazo || '').trim();

    if (!motivo) {
      return res.status(400).json({
        mensaje: 'Debes indicar el motivo del rechazo.',
      });
    }

    const contenido = await ContenidoAdmin.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado.',
      });
    }

    if (contenido.estadoPublicacion !== 'pendiente_revision') {
      return res.status(400).json({
        mensaje: 'Solo se pueden rechazar contenidos pendientes de revisión.',
      });
    }

    contenido.estadoPublicacion = 'rechazado';
    contenido.motivoRechazo = motivo;
    contenido.activo = false;

    await contenido.save();

    return res.json({
      mensaje: 'Contenido rechazado correctamente.',
      contenido,
    });
  } catch (error) {
    return res.status(500).json({
      mensaje: 'Error al rechazar contenido.',
      error: error.message,
    });
  }
};

// ============================================================
// DESACTIVAR CONTENIDO APROBADO
// ============================================================

const desactivarContenido = async (req, res) => {
  try {
    const contenido = await ContenidoAdmin.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado.',
      });
    }

    if (contenido.estadoPublicacion !== 'aprobado') {
      return res.status(400).json({
        mensaje: 'Solo se pueden desactivar contenidos aprobados.',
      });
    }

    contenido.activo = false;
    await contenido.save();

    return res.json({
      mensaje: 'Contenido desactivado correctamente.',
      contenido,
    });
  } catch (error) {
    return res.status(500).json({
      mensaje: 'Error al desactivar contenido.',
      error: error.message,
    });
  }
};

// ============================================================
// ACTIVAR CONTENIDO APROBADO
// ============================================================

const activarContenido = async (req, res) => {
  try {
    const contenido = await ContenidoAdmin.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado.',
      });
    }

    if (contenido.estadoPublicacion !== 'aprobado') {
      return res.status(400).json({
        mensaje: 'Solo se pueden activar contenidos aprobados.',
      });
    }

    contenido.activo = true;
    await contenido.save();

    return res.json({
      mensaje: 'Contenido activado correctamente.',
      contenido,
    });
  } catch (error) {
    return res.status(500).json({
      mensaje: 'Error al activar contenido.',
      error: error.message,
    });
  }
};

// ============================================================
// ELIMINAR CONTENIDO
// ============================================================

const eliminarContenido = async (req, res) => {
  try {
    const contenido = await ContenidoAdmin.findByIdAndDelete(
      req.params.id
    );

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado.',
      });
    }

    return res.json({
      mensaje: 'Contenido eliminado correctamente.',
    });
  } catch (error) {
    return res.status(500).json({
      mensaje: 'Error al eliminar contenido.',
      error: error.message,
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
