
const Resena = require('../../models/sitio/resena');

const obtenerResenas = async (req, res) => {
  try {
    const resenas = await Resena.find()
      .populate(
        'usuario',
        'nombre apellido fotoPerfil avatar'
      )
      .populate('sitio', 'nombre ciudad departamento')
      .sort({ createdAt: -1 });

    return res.status(200).json(resenas);
  } catch (error) {
    console.error('Error al obtener reseñas:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener reseñas',
      error: error.message,
    });
  }
};

const obtenerResena = async (req, res) => {
  try {
    const resena = await Resena.findById(req.params.id)
      .populate(
        'usuario',
        'nombre apellido fotoPerfil avatar'
      )
      .populate('sitio', 'nombre ciudad departamento');

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada',
      });
    }

    return res.status(200).json(resena);
  } catch (error) {
    console.error('Error al obtener reseña:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener reseña',
      error: error.message,
    });
  }
};

const desactivarResena = async (req, res) => {
  try {
    const resena = await Resena.findByIdAndUpdate(
      req.params.id,
      { activo: false },
      { new: true }
    );

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada',
      });
    }

    return res.status(200).json({
      mensaje: 'Reseña desactivada correctamente',
      resena,
    });
  } catch (error) {
    console.error('Error al desactivar reseña:', error);

    return res.status(500).json({
      mensaje: 'Error al desactivar reseña',
      error: error.message,
    });
  }
};

const activarResena = async (req, res) => {
  try {
    const resena = await Resena.findByIdAndUpdate(
      req.params.id,
      { activo: true },
      { new: true }
    );

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada',
      });
    }

    return res.status(200).json({
      mensaje: 'Reseña activada correctamente',
      resena,
    });
  } catch (error) {
    console.error('Error al activar reseña:', error);

    return res.status(500).json({
      mensaje: 'Error al activar reseña',
      error: error.message,
    });
  }
};

const eliminarResena = async (req, res) => {
  try {
    const resena = await Resena.findByIdAndDelete(req.params.id);

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada',
      });
    }

    return res.status(200).json({
      mensaje: 'Reseña eliminada correctamente',
    });
  } catch (error) {
    console.error('Error al eliminar reseña:', error);

    return res.status(500).json({
      mensaje: 'Error al eliminar reseña',
      error: error.message,
    });
  }
};

module.exports = {
  obtenerResenas,
  obtenerResena,
  desactivarResena,
  activarResena,
  eliminarResena,
};
