const Resena = require('../../models/sitio/resena');

// ======================================================
// OBTENER RESEÑAS DE UN SITIO
// ======================================================

const obtenerResenasPorSitio = async (req, res) => {
  try {
    const resenas = await Resena.find({
      sitio: req.params.sitioId
    })
      .populate('usuario', 'nombre apellido fotoPerfil')
      .sort({ createdAt: -1 });

    res.json(resenas);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener reseñas',
      error: error.message
    });
  }
};


// ======================================================
// CREAR RESEÑA
// ======================================================

const crearResena = async (req, res) => {
  try {
    const {
      sitio,
      comentario,
      calificacion
    } = req.body;

    const resena = new Resena({
      usuario: req.usuario.id,
      sitio,
      comentario,
      calificacion
    });

    await resena.save();

    res.status(201).json({
      mensaje: 'Reseña creada correctamente',
      resena
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear reseña',
      error: error.message
    });
  }
};


// ======================================================
// ACTUALIZAR RESEÑA
// ======================================================

const actualizarResena = async (req, res) => {
  try {
    const resena = await Resena.findOneAndUpdate(
      {
        _id: req.params.id,
        usuario: req.usuario.id
      },
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada o no tienes permiso para modificarla'
      });
    }

    res.json({
      mensaje: 'Reseña actualizada correctamente',
      resena
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar reseña',
      error: error.message
    });
  }
};


// ======================================================
// ELIMINAR RESEÑA
// ======================================================

const eliminarResena = async (req, res) => {
  try {
    const resena = await Resena.findOneAndDelete({
      _id: req.params.id,
      usuario: req.usuario.id
    });

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada o no tienes permiso para eliminarla'
      });
    }

    res.json({
      mensaje: 'Reseña eliminada correctamente'
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar reseña',
      error: error.message
    });
  }
};


// ======================================================
// EXPORTAR FUNCIONES
// ======================================================

module.exports = {
  obtenerResenasPorSitio,
  crearResena,
  actualizarResena,
  eliminarResena
};