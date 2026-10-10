
const Contenido = require('../../models/sitio/contenido');

// ======================================================
// OBTENER CONTENIDOS PÚBLICOS DE UN SITIO
// ======================================================

const obtenerContenidos = async (req, res) => {
  try {
    const contenidos = await Contenido.find({
      sitio: req.params.sitioId,
      activo: true,
      estadoPublicacion: 'aprobado',
    }).sort({ createdAt: -1 });

    return res.status(200).json(contenidos);
  } catch (error) {
    console.error('Error al obtener contenidos:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener los contenidos',
      error: error.message,
    });
  }
};

// ======================================================
// OBTENER MIS CONTENIDOS
// ======================================================

const obtenerMisContenidos = async (req, res) => {
  try {
    const contenidos = await Contenido.find({
      sitio: req.usuario.sitioId,
    }).sort({ createdAt: -1 });

    return res.status(200).json(contenidos);
  } catch (error) {
    console.error('Error al obtener mis contenidos:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener tus contenidos',
      error: error.message,
    });
  }
};

// ======================================================
// OBTENER UN CONTENIDO
// ======================================================

const obtenerContenido = async (req, res) => {
  try {
    const contenido = await Contenido.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    return res.status(200).json(contenido);
  } catch (error) {
    console.error('Error al obtener contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener el contenido',
      error: error.message,
    });
  }
};

// ======================================================
// CREAR CONTENIDO
// ======================================================

const crearContenido = async (req, res) => {
  try {
    const {
      titulo,
      descripcion,
      imagenPrincipal,
      imagenes,
      audioGuias,
    } = req.body;

    if (
      typeof titulo !== 'string' ||
      titulo.trim().length < 2
    ) {
      return res.status(400).json({
        mensaje: 'El título debe tener al menos 2 caracteres',
      });
    }

    if (
      typeof descripcion !== 'string' ||
      descripcion.trim().length < 10
    ) {
      return res.status(400).json({
        mensaje: 'La descripción debe tener al menos 10 caracteres',
      });
    }

    if (imagenes !== undefined && !Array.isArray(imagenes)) {
      return res.status(400).json({
        mensaje: 'Las imágenes deben enviarse como una lista',
      });
    }

    if (
      audioGuias !== undefined &&
      !Array.isArray(audioGuias)
    ) {
      return res.status(400).json({
        mensaje: 'Las audio-guías deben enviarse como una lista',
      });
    }

    const contenido = await Contenido.create({
      sitio: req.usuario.sitioId,
      titulo: titulo.trim(),
      descripcion: descripcion.trim(),
      imagenPrincipal:
        typeof imagenPrincipal === 'string'
          ? imagenPrincipal.trim()
          : '',
      imagenes: imagenes || [],
      audioGuias: audioGuias || [],
      estadoPublicacion: 'borrador',
      activo: true,
    });

    return res.status(201).json({
      mensaje: 'Contenido creado correctamente',
      contenido,
    });
  } catch (error) {
    console.error('Error al crear contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al crear el contenido',
      error: error.message,
    });
  }
};

// ======================================================
// ACTUALIZAR CONTENIDO
// ======================================================

const actualizarContenido = async (req, res) => {
  try {
    const contenido = await Contenido.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    if (
      !req.usuario?.sitioId ||
      contenido.sitio.toString() !==
        req.usuario.sitioId.toString()
    ) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para modificar este contenido',
      });
    }

    if (contenido.estadoPublicacion === 'pendiente_revision') {
      return res.status(400).json({
        mensaje:
          'No puedes editar el contenido mientras está pendiente de revisión',
      });
    }

    const {
      titulo,
      descripcion,
      imagenPrincipal,
      imagenes,
      audioGuias,
    } = req.body;

    if (titulo !== undefined) {
      if (
        typeof titulo !== 'string' ||
        titulo.trim().length < 2
      ) {
        return res.status(400).json({
          mensaje: 'El título debe tener al menos 2 caracteres',
        });
      }

      contenido.titulo = titulo.trim();
    }

    if (descripcion !== undefined) {
      if (
        typeof descripcion !== 'string' ||
        descripcion.trim().length < 10
      ) {
        return res.status(400).json({
          mensaje:
            'La descripción debe tener al menos 10 caracteres',
        });
      }

      contenido.descripcion = descripcion.trim();
    }

    if (imagenPrincipal !== undefined) {
      if (typeof imagenPrincipal !== 'string') {
        return res.status(400).json({
          mensaje: 'La imagen principal debe ser una URL válida',
        });
      }

      contenido.imagenPrincipal = imagenPrincipal.trim();
    }

    if (imagenes !== undefined) {
      if (!Array.isArray(imagenes)) {
        return res.status(400).json({
          mensaje: 'Las imágenes deben enviarse como una lista',
        });
      }

      contenido.imagenes = imagenes;
    }

    if (audioGuias !== undefined) {
      if (!Array.isArray(audioGuias)) {
        return res.status(400).json({
          mensaje: 'Las audio-guías deben enviarse como una lista',
        });
      }

      contenido.audioGuias = audioGuias;
    }

    // Los contenidos aprobados o rechazados vuelven a borrador
    // cuando se modifican.
    if (
      contenido.estadoPublicacion === 'aprobado' ||
      contenido.estadoPublicacion === 'rechazado'
    ) {
      contenido.estadoPublicacion = 'borrador';
      contenido.motivoRechazo = '';
      contenido.revisadoPor = null;
      contenido.revisadoAt = null;
    }

    await contenido.save();

    return res.status(200).json({
      mensaje: 'Contenido actualizado correctamente',
      contenido,
    });
  } catch (error) {
    console.error('Error al actualizar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al actualizar el contenido',
      error: error.message,
    });
  }
};

// ======================================================
// ENVIAR A REVISIÓN
// ======================================================

const enviarContenidoRevision = async (req, res) => {
  try {
    const contenido = await Contenido.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    if (
      !req.usuario?.sitioId ||
      contenido.sitio.toString() !==
        req.usuario.sitioId.toString()
    ) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para modificar este contenido',
      });
    }

    if (contenido.estadoPublicacion === 'pendiente_revision') {
      return res.status(400).json({
        mensaje: 'El contenido ya está pendiente de revisión',
      });
    }

    if (
      !contenido.titulo ||
      contenido.titulo.trim().length < 2
    ) {
      return res.status(400).json({
        mensaje: 'El contenido necesita un título válido',
      });
    }

    if (
      !contenido.descripcion ||
      contenido.descripcion.trim().length < 10
    ) {
      return res.status(400).json({
        mensaje: 'El contenido necesita una descripción válida',
      });
    }

    contenido.estadoPublicacion = 'pendiente_revision';
    contenido.motivoRechazo = '';
    contenido.revisadoPor = null;
    contenido.revisadoAt = null;

    await contenido.save();

    return res.status(200).json({
      mensaje: 'Contenido enviado a revisión',
      contenido,
    });
  } catch (error) {
    console.error(
      'Error al enviar contenido a revisión:',
      error,
    );

    return res.status(500).json({
      mensaje: 'Error al enviar el contenido a revisión',
      error: error.message,
    });
  }
};


const eliminarContenido = async (req, res) => {
  try {
    const contenido = await Contenido.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    if (
      !req.usuario?.sitioId ||
      contenido.sitio.toString() !==
        req.usuario.sitioId.toString()
    ) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para eliminar este contenido',
      });
    }

    if (contenido.estadoPublicacion === 'pendiente_revision') {
      return res.status(400).json({
        mensaje:
          'No puedes eliminar el contenido mientras está pendiente de revisión',
      });
    }

    await Contenido.findByIdAndDelete(contenido._id);

    return res.status(200).json({
      mensaje: 'Contenido eliminado correctamente',
      id: contenido._id,
    });
  } catch (error) {
    console.error('Error al eliminar contenido:', error);

    return res.status(500).json({
      mensaje: 'Error al eliminar el contenido',
      error: error.message,
    });
  }
};

// ======================================================
// SUBIR IMÁGENES DE CONTENIDO
// ======================================================

const subirImagenesContenido = async (req, res) => {
  try {
    const contenido = await Contenido.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado',
      });
    }

    if (
      !req.usuario?.sitioId ||
      contenido.sitio.toString() !==
        req.usuario.sitioId.toString()
    ) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para modificar este contenido',
      });
    }

    if (contenido.estadoPublicacion === 'pendiente_revision') {
      return res.status(400).json({
        mensaje:
          'No puedes modificar las imágenes mientras el contenido está pendiente de revisión',
      });
    }

    const archivoPrincipal = req.files?.imagenPrincipal?.[0];
    const archivosGaleria = req.files?.imagenes || [];

    if (!archivoPrincipal && archivosGaleria.length === 0) {
      return res.status(400).json({
        mensaje: 'Debes seleccionar al menos una imagen',
      });
    }

    if (archivoPrincipal) {
      if (
        typeof archivoPrincipal.path !== 'string' ||
        archivoPrincipal.path.trim().length === 0
      ) {
        return res.status(500).json({
          mensaje:
            'Cloudinary no devolvió la URL de la imagen principal',
        });
      }

      // Reemplaza la imagen principal anterior.
      contenido.imagenPrincipal = archivoPrincipal.path;
    }

    if (archivosGaleria.length > 0) {
      const nuevasImagenes = archivosGaleria.map(
        (archivo) => archivo.path,
      );

      if (
        nuevasImagenes.some(
          (url) =>
            typeof url !== 'string' ||
            url.trim().length === 0,
        )
      ) {
        return res.status(500).json({
          mensaje:
            'No se pudieron obtener todas las URL de las imágenes',
        });
      }

      // Las imágenes nuevas se agregan a la galería existente.
      contenido.imagenes.push(...nuevasImagenes);
    }

    // Los contenidos aprobados o rechazados vuelven a borrador
    // cuando se modifican sus imágenes.
    if (
      contenido.estadoPublicacion === 'aprobado' ||
      contenido.estadoPublicacion === 'rechazado'
    ) {
      contenido.estadoPublicacion = 'borrador';
      contenido.motivoRechazo = '';
      contenido.revisadoPor = null;
      contenido.revisadoAt = null;
    }

    await contenido.save();

    return res.status(200).json({
      mensaje: 'Imágenes cargadas correctamente',
      contenido,
    });
  } catch (error) {
    console.error(
      'Error al subir imágenes del contenido:',
      error,
    );

    return res.status(500).json({
      mensaje: 'Error al subir las imágenes',
      error: error.message,
    });
  }
};

// ======================================================
// EXPORTACIONES
// ======================================================

module.exports = {
  obtenerContenidos,
  obtenerMisContenidos,
  obtenerContenido,
  crearContenido,
  actualizarContenido,
  enviarContenidoRevision,
  subirImagenesContenido,
  eliminarContenido,
};
