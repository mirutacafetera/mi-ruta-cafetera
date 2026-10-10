
const Contenido = require('../../models/sitio/contenido');

// ============================================================
// COMPROBAR PROPIEDAD Y ESTADO DEL CONTENIDO
// ============================================================

async function obtenerContenidoEditable(req, res) {
  const contenido = await Contenido.findById(req.params.id);

  if (!contenido) {
    res.status(404).json({
      mensaje: 'No se encontró el contenido.',
    });
    return null;
  }

  const sitioId = req.usuario?.sitioId;

  if (
    !sitioId ||
    contenido.sitio?.toString() !== sitioId.toString()
  ) {
    res.status(403).json({
      mensaje: 'No tienes permiso para modificar este contenido.',
    });
    return null;
  }

  if (contenido.estadoPublicacion === 'pendiente_revision') {
    res.status(400).json({
      mensaje: 'No puedes modificar el contenido mientras está en revisión.',
    });
    return null;
  }

  return contenido;
}

// ============================================================
// AGREGAR AUDIOGUÍA
// POST /:id/audioguias
// ============================================================

const subirAudioGuia = async (req, res) => {
  try {
    const contenido = await obtenerContenidoEditable(req, res);
    if (!contenido) return;

    if (!req.file) {
      return res.status(400).json({
        mensaje: 'Debes seleccionar un archivo de audio.',
      });
    }

    const titulo = String(req.body.titulo || '').trim();
    const descripcion = String(req.body.descripcion || '').trim();
    const duracion = String(req.body.duracion || '').trim();

    if (titulo.length < 2) {
      return res.status(400).json({
        mensaje: 'El título del audio debe tener al menos 2 caracteres.',
      });
    }

    contenido.audioGuias.push({
      titulo,
      descripcion,
      url: req.file.path,
      duracion,
      publicId: req.file.filename,
    });

    await contenido.save();

    return res.status(201).json({
      mensaje: 'Audioguía guardada correctamente.',
      contenido,
    });
  } catch (error) {
    console.error('Error al guardar audioguía:', error);

    return res.status(500).json({
      mensaje: 'No fue posible guardar la audioguía.',
    });
  }
};

// ============================================================
// ELIMINAR AUDIOGUÍA
// DELETE /:id/audioguias/:audioId
// ============================================================

const eliminarAudioGuia = async (req, res) => {
  try {
    const contenido = await obtenerContenidoEditable(req, res);
    if (!contenido) return;

    const audio = contenido.audioGuias.id(req.params.audioId);

    if (!audio) {
      return res.status(404).json({
        mensaje: 'No se encontró la audioguía.',
      });
    }

    // Eliminar el archivo de Cloudinary si tiene publicId.
    if (audio.publicId) {
      try {
        await require('../../config/cloudinary').uploader.destroy(
          audio.publicId,
          { resource_type: 'video' },
        );
      } catch (errorCloudinary) {
        console.error(
          'No se pudo eliminar el archivo de Cloudinary:',
          errorCloudinary,
        );

        return res.status(502).json({
          mensaje: 'No se pudo eliminar el archivo de audio almacenado.',
        });
      }
    }

    audio.deleteOne();
    await contenido.save();

    return res.json({
      mensaje: 'Audioguía eliminada correctamente.',
      contenido,
    });
  } catch (error) {
    console.error('Error al eliminar audioguía:', error);

    return res.status(500).json({
      mensaje: 'No fue posible eliminar la audioguía.',
    });
  }
};

module.exports = {
  subirAudioGuia,
  eliminarAudioGuia,
};
