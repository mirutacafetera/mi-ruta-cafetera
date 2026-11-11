
const mongoose = require('mongoose');
const Resena = require('../../models/sitio/resena');

// ======================================================
// OBTENER TODAS LAS RESEÑAS
// ======================================================

const obtenerResenas = async (req, res) => {
  try {
    const resenas = await Resena.find()
      .populate('usuario', 'nombre apellido fotoPerfil avatar')
      .populate('sitio', 'nombre ciudad departamento')
      .sort({ createdAt: -1 })
      .lean();

    return res.status(200).json(resenas);
  } catch (error) {
    console.error('Error al obtener reseñas:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener reseñas',
      error: error.message
    });
  }
};

// ======================================================
// OBTENER UNA RESEÑA
// ======================================================

const obtenerResena = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        mensaje: 'El identificador de la reseña no es válido.'
      });
    }

    const resena = await Resena.findById(id)
      .populate('usuario', 'nombre apellido fotoPerfil avatar')
      .populate('sitio', 'nombre ciudad departamento')
      .lean();

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada'
      });
    }

    return res.status(200).json(resena);
  } catch (error) {
    console.error('Error al obtener reseña:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener reseña',
      error: error.message
    });
  }
};

// ======================================================
// DESACTIVAR RESEÑA
// ======================================================

const desactivarResena = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        mensaje: 'El identificador de la reseña no es válido.'
      });
    }

    const resena = await Resena.findByIdAndUpdate(
      id,
      { $set: { activo: false } },
      { new: true, runValidators: true }
    );

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada'
      });
    }

    return res.status(200).json({
      mensaje: 'Reseña desactivada correctamente',
      resena
    });
  } catch (error) {
    console.error('Error al desactivar reseña:', error);

    return res.status(500).json({
      mensaje: 'Error al desactivar reseña',
      error: error.message
    });
  }
};

// ======================================================
// ACTIVAR RESEÑA
// ======================================================

const activarResena = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        mensaje: 'El identificador de la reseña no es válido.'
      });
    }

    const resena = await Resena.findByIdAndUpdate(
      id,
      { $set: { activo: true } },
      { new: true, runValidators: true }
    );

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada'
      });
    }

    return res.status(200).json({
      mensaje: 'Reseña activada correctamente',
      resena
    });
  } catch (error) {
    console.error('Error al activar reseña:', error);

    return res.status(500).json({
      mensaje: 'Error al activar reseña',
      error: error.message
    });
  }
};

// ======================================================
// ELIMINACIÓN LÓGICA ADMINISTRATIVA
// ======================================================

const eliminarResena = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        mensaje: 'El identificador de la reseña no es válido.'
      });
    }

    const resena = await Resena.findByIdAndUpdate(
      id,
      { $set: { activo: false } },
      { new: true }
    );

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada'
      });
    }

    return res.status(200).json({
      mensaje: 'Reseña ocultada correctamente',
      resena
    });
  } catch (error) {
    console.error('Error al ocultar reseña:', error);

    return res.status(500).json({
      mensaje: 'Error al ocultar reseña',
      error: error.message
    });
  }
};

module.exports = {
  obtenerResenas,
  obtenerResena,
  desactivarResena,
  activarResena,
  eliminarResena
};
