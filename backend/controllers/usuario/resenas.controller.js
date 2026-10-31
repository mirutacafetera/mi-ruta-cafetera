const mongoose = require('mongoose');
const Resena = require('../../models/sitio/resena');
const SitioTuristico = require('../../models/admin/sitio');

// ======================================================
// OBTENER RESEÑAS PÚBLICAS DE UN SITIO
// ======================================================

const obtenerResenasPorSitio = async (req, res) => {
  try {
    const { sitioId } = req.params;

    if (!mongoose.isValidObjectId(sitioId)) {
      return res.status(400).json({
        mensaje: 'El identificador del sitio no es válido.'
      });
    }

    const resenas = await Resena.find({
      sitio: sitioId,
      activo: true
    })
      .select('usuario sitio calificacion comentario imagenes activo createdAt')
      .populate('usuario', 'nombre apellido fotoPerfil avatar')
      .sort({ createdAt: -1 })
      .lean();

    return res.json(resenas);
  } catch (error) {
    console.error('Error al obtener reseñas:', error);

    return res.status(500).json({
      mensaje: 'No fue posible obtener las reseñas.'
    });
  }
};

// ======================================================
// CREAR RESEÑA
// ======================================================

const crearResena = async (req, res) => {
  try {
    const { sitio, comentario, calificacion } = req.body;

    if (!mongoose.isValidObjectId(sitio)) {
      return res.status(400).json({
        mensaje: 'El identificador del sitio no es válido.'
      });
    }

    const comentarioLimpio =
      typeof comentario === 'string' ? comentario.trim() : '';

    const nota = Number(calificacion);

    if (!Number.isInteger(nota) || nota < 1 || nota > 5) {
      return res.status(400).json({
        mensaje: 'La calificación debe ser un número entero entre 1 y 5.'
      });
    }

    if (!comentarioLimpio || comentarioLimpio.length > 1000) {
      return res.status(400).json({
        mensaje: 'El comentario es obligatorio y no puede superar los 1000 caracteres.'
      });
    }

    const sitioExiste = await SitioTuristico.exists({
      _id: sitio
    });

    if (!sitioExiste) {
      return res.status(404).json({
        mensaje: 'No se encontró el sitio turístico.'
      });
    }

    const imagenes = (req.files || [])
    .map((archivo) => archivo.path || archivo.url)
    .filter((url) => typeof url === 'string' && url.trim().length > 0);

    const resena = await Resena.create({
      usuario: req.usuario.id,
      sitio,
      comentario: comentarioLimpio,
      calificacion: nota,
      imagenes
    });

    await resena.populate(
      'usuario',
      'nombre apellido fotoPerfil avatar'
    );

    return res.status(201).json({
      mensaje: 'Reseña creada correctamente.',
      resena
    });
  } catch (error) {
    console.error('Error al crear reseña:', error);

    if (error.name === 'ValidationError' ||
        error.name === 'CastError') {
      return res.status(400).json({
        mensaje: 'Los datos de la reseña no son válidos.'
      });
    }

    return res.status(500).json({
      mensaje: 'No fue posible crear la reseña.'
    });
  }
};

// ======================================================
// ACTUALIZAR RESEÑA PROPIA
// ======================================================

const actualizarResena = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        mensaje: 'El identificador de la reseña no es válido.'
      });
    }

    const camposPermitidos = ['calificacion', 'comentario'];
    const camposRecibidos = Object.keys(req.body);

    if (
      camposRecibidos.length === 0 ||
      camposRecibidos.some(
        (campo) => !camposPermitidos.includes(campo)
      )
    ) {
      return res.status(400).json({
        mensaje: 'Solo puedes modificar la calificación y el comentario.'
      });
    }

    const cambios = {};

    if (Object.prototype.hasOwnProperty.call(req.body, 'calificacion')) {
      const nota = Number(req.body.calificacion);

      if (!Number.isInteger(nota) || nota < 1 || nota > 5) {
        return res.status(400).json({
          mensaje: 'La calificación debe estar entre 1 y 5.'
        });
      }

      cambios.calificacion = nota;
    }

    if (Object.prototype.hasOwnProperty.call(req.body, 'comentario')) {
      if (typeof req.body.comentario !== 'string') {
        return res.status(400).json({
          mensaje: 'El comentario debe ser texto.'
        });
      }

      const comentario = req.body.comentario.trim();

      if (!comentario || comentario.length > 1000) {
        return res.status(400).json({
          mensaje: 'El comentario es obligatorio y no puede superar los 1000 caracteres.'
        });
      }

      cambios.comentario = comentario;
    }

    const resena = await Resena.findOneAndUpdate(
      {
        _id: id,
        usuario: req.usuario.id
      },
      { $set: cambios },
      {
        new: true,
        runValidators: true
      }
    ).populate('usuario', 'nombre apellido fotoPerfil avatar');

    if (!resena) {
      return res.status(404).json({
        mensaje: 'No se encontró la reseña o no tienes permiso para modificarla.'
      });
    }

    return res.json({
      mensaje: 'Reseña actualizada correctamente.',
      resena
    });
  } catch (error) {
    console.error('Error al actualizar reseña:', error);

    return res.status(500).json({
      mensaje: 'No fue posible actualizar la reseña.'
    });
  }
};

// ======================================================
// ELIMINAR RESEÑA PROPIA
// ======================================================

const eliminarResena = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        mensaje: 'El identificador de la reseña no es válido.'
      });
    }

    const resena = await Resena.findOneAndDelete({
      _id: id,
      usuario: req.usuario.id
    });

    if (!resena) {
      return res.status(404).json({
        mensaje: 'No se encontró la reseña o no tienes permiso para eliminarla.'
      });
    }

    return res.json({
      mensaje: 'Reseña eliminada correctamente.'
    });
  } catch (error) {
    console.error('Error al eliminar reseña:', error);

    return res.status(500).json({
      mensaje: 'No fue posible eliminar la reseña.'
    });
  }
};

module.exports = {
  obtenerResenasPorSitio,
  crearResena,
  actualizarResena,
  eliminarResena
};