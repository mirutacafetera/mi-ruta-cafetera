const Actividad = require('../../models/sitio/actividad');

const obtenerActividades = async (req, res) => {
  try {
    const actividades = await Actividad.find({
      sitio: req.params.id,
      activo: true
    }).sort({ createdAt: -1 });

    res.status(200).json(actividades);
  } catch (error) {
    console.error('❌ Error al obtener actividades:', error);

    res.status(500).json({
      mensaje: 'Error al obtener actividades',
      error: error.message
    });
  }
};

const crearActividad = async (req, res) => {
  try {
    if (req.usuario.sitioId !== req.params.id) {
      return res.status(403).json({
        mensaje: 'No tienes permisos para administrar este sitio'
      });
    }

    const actividad = new Actividad({
      nombre: req.body.nombre,
      descripcion: req.body.descripcion,
      precio: req.body.precio,
      horario: req.body.horario,
      duracion: req.body.duracion,
      sitio: req.usuario.sitioId,
      imagenPrincipal: '',
      imagenes: [],
      estadoPublicacion: 'borrador',
      activo: true
    });

    await actividad.save();

    res.status(201).json({
      mensaje: 'Actividad creada correctamente como borrador',
      actividad
    });
  } catch (error) {
    console.error('❌ Error al crear actividad:', error);

    res.status(500).json({
      mensaje: 'Error al crear actividad',
      error: error.message
    });
  }
};

const actualizarActividad = async (req, res) => {
  try {
    const actividad = await Actividad.findOne({
      _id: req.params.actividadId,
      sitio: req.usuario.sitioId
    });

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    if (req.body.nombre !== undefined) {
      actividad.nombre = req.body.nombre;
    }

    if (req.body.descripcion !== undefined) {
      actividad.descripcion = req.body.descripcion;
    }

    if (req.body.precio !== undefined) {
      actividad.precio = req.body.precio;
    }

    if (req.body.horario !== undefined) {
      actividad.horario = req.body.horario;
    }

    if (req.body.duracion !== undefined) {
      actividad.duracion = req.body.duracion;
    }

    if (
      actividad.estadoPublicacion === 'aprobado' ||
      actividad.estadoPublicacion === 'rechazado'
    ) {
      actividad.estadoPublicacion = 'borrador';
      actividad.motivoRechazo = '';
      actividad.revisadoPor = null;
      actividad.revisadoAt = null;
    }

    await actividad.save();

    res.status(200).json({
      mensaje:
        'Actividad actualizada correctamente. Debe enviarse nuevamente a revisión para publicarse.',
      actividad
    });
  } catch (error) {
    console.error('❌ Error al actualizar actividad:', error);

    res.status(500).json({
      mensaje: 'Error al actualizar actividad',
      error: error.message
    });
  }
};

const subirImagenesActividad = async (req, res) => {
  try {
    const actividad = await Actividad.findOne({
      _id: req.params.actividadId,
      sitio: req.usuario.sitioId
    });

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        mensaje: 'Debes seleccionar al menos una imagen.'
      });
    }

    const imagenesActuales = Array.isArray(actividad.imagenes)
      ? actividad.imagenes
      : [];

    const cantidadActual =
      (actividad.imagenPrincipal ? 1 : 0) +
      imagenesActuales.length;

    if (cantidadActual + req.files.length > 10) {
      return res.status(400).json({
        mensaje:
          'Una actividad puede tener máximo 10 imágenes.'
      });
    }

    const urls = req.files
      .map((file) => file.path)
      .filter(Boolean);

    if (urls.length === 0) {
      return res.status(400).json({
        mensaje:
          'No fue posible obtener las imágenes subidas.'
      });
    }

    if (!actividad.imagenPrincipal) {
      actividad.imagenPrincipal = urls[0];

      if (urls.length > 1) {
        actividad.imagenes.push(...urls.slice(1));
      }
    } else {
      actividad.imagenes.push(...urls);
    }

    if (
      actividad.estadoPublicacion === 'aprobado' ||
      actividad.estadoPublicacion === 'rechazado'
    ) {
      actividad.estadoPublicacion = 'borrador';
      actividad.motivoRechazo = '';
      actividad.revisadoPor = null;
      actividad.revisadoAt = null;
    }

    await actividad.save();

    return res.status(201).json({
      mensaje: 'Imágenes agregadas correctamente.',
      actividad
    });
  } catch (error) {
    console.error(
      '❌ Error al subir imágenes de actividad:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al subir las imágenes.',
      error: error.message
    });
  }
};

const eliminarImagenActividad = async (req, res) => {
  try {
    const actividad = await Actividad.findOne({
      _id: req.params.actividadId,
      sitio: req.usuario.sitioId
    });

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    const { url } = req.body;

    if (!url) {
      return res.status(400).json({
        mensaje: 'Debes indicar la URL de la imagen.'
      });
    }

    if (actividad.imagenPrincipal === url) {
      return res.status(400).json({
        mensaje:
          'No puedes eliminar la imagen principal sin seleccionar otra primero.'
      });
    }

    const imagenesAntes = actividad.imagenes.length;

    actividad.imagenes = actividad.imagenes.filter(
      (imagen) => imagen !== url
    );

    if (actividad.imagenes.length === imagenesAntes) {
      return res.status(404).json({
        mensaje: 'La imagen no pertenece a esta actividad.'
      });
    }

    if (
      actividad.estadoPublicacion === 'aprobado' ||
      actividad.estadoPublicacion === 'rechazado'
    ) {
      actividad.estadoPublicacion = 'borrador';
      actividad.motivoRechazo = '';
      actividad.revisadoPor = null;
      actividad.revisadoAt = null;
    }

    await actividad.save();

    return res.status(200).json({
      mensaje: 'Imagen eliminada correctamente.',
      actividad
    });
  } catch (error) {
    console.error(
      '❌ Error al eliminar imagen de actividad:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al eliminar la imagen.',
      error: error.message
    });
  }
};

const establecerImagenPrincipal = async (req, res) => {
  try {
    const actividad = await Actividad.findOne({
      _id: req.params.actividadId,
      sitio: req.usuario.sitioId
    });

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    const { url } = req.body;

    if (!url) {
      return res.status(400).json({
        mensaje: 'Debes indicar la URL de la imagen.'
      });
    }

    if (actividad.imagenPrincipal === url) {
      return res.status(200).json({
        mensaje: 'La imagen ya es la principal.',
        actividad
      });
    }

    const indice = actividad.imagenes.indexOf(url);

    if (indice === -1) {
      return res.status(404).json({
        mensaje: 'La imagen no pertenece a esta actividad.'
      });
    }

    const imagenPrincipalAnterior =
      actividad.imagenPrincipal;

    actividad.imagenPrincipal = url;

    actividad.imagenes[indice] =
      imagenPrincipalAnterior;

    if (
      actividad.estadoPublicacion === 'aprobado' ||
      actividad.estadoPublicacion === 'rechazado'
    ) {
      actividad.estadoPublicacion = 'borrador';
      actividad.motivoRechazo = '';
      actividad.revisadoPor = null;
      actividad.revisadoAt = null;
    }

    await actividad.save();

    return res.status(200).json({
      mensaje:
        'Imagen principal actualizada correctamente.',
      actividad
    });
  } catch (error) {
    console.error(
      '❌ Error al establecer imagen principal:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al establecer la imagen principal.',
      error: error.message
    });
  }
};

const enviarActividadRevision = async (req, res) => {
  try {
    const actividad = await Actividad.findOne({
      _id: req.params.actividadId,
      sitio: req.usuario.sitioId
    });

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    if (!actividad.nombre || actividad.nombre.trim().length < 2) {
      return res.status(400).json({
        mensaje:
          'La actividad debe tener un nombre válido antes de enviarla a revisión'
      });
    }

    if (actividad.estadoPublicacion === 'pendiente_revision') {
      return res.status(400).json({
        mensaje:
          'La actividad ya se encuentra pendiente de revisión'
      });
    }

    actividad.estadoPublicacion = 'pendiente_revision';
    actividad.motivoRechazo = '';
    actividad.revisadoPor = null;
    actividad.revisadoAt = null;

    await actividad.save();

    res.status(200).json({
      mensaje:
        'Actividad enviada a revisión correctamente',
      actividad
    });
  } catch (error) {
    console.error(
      '❌ Error al enviar actividad a revisión:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al enviar la actividad a revisión',
      error: error.message
    });
  }
};

const desactivarActividad = async (req, res) => {
  try {
    const actividad = await Actividad.findOneAndUpdate(
      {
        _id: req.params.actividadId,
        sitio: req.usuario.sitioId
      },
      {
        activo: false
      },
      {
        new: true
      }
    );

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    res.status(200).json({
      mensaje: 'Actividad desactivada correctamente',
      actividad
    });
  } catch (error) {
    console.error(
      '❌ Error al desactivar actividad:',
      error
    );

    res.status(500).json({
      mensaje: 'Error al desactivar actividad',
      error: error.message
    });
  }
};

module.exports = {
  obtenerActividades,
  crearActividad,
  actualizarActividad,
  subirImagenesActividad,
  eliminarImagenActividad,
  establecerImagenPrincipal,
  enviarActividadRevision,
  desactivarActividad
};
