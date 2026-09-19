const Resena = require('../../models/sitio/resena');

const obtenerResenas = async (req, res) => {
  try {
    const resenas = await Resena.find()
      .populate('usuario', '-password')
      .populate('sitio', 'nombre ciudad departamento')
      .sort({ createdAt: -1 });

    res.json(resenas);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener reseñas',
      error: error.message
    });
  }
};


const obtenerResena = async (req, res) => {
  try {
    const resena = await Resena.findById(req.params.id)
      .populate('usuario', '-password')
      .populate('sitio', 'nombre ciudad departamento');

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada'
      });
    }

    res.json(resena);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener reseña',
      error: error.message
    });
  }
};

const desactivarResena = async (req, res) => {
  try {
    const resena = await Resena.findByIdAndUpdate(
      req.params.id,
      {
        activo: false
      },
      {
        new: true
      }
    );

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada'
      });
    }

    res.json({
      mensaje: 'Reseña desactivada correctamente',
      resena
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al desactivar reseña',
      error: error.message
    });
  }
};

const activarResena = async (req, res) => {
  try {
    const resena = await Resena.findByIdAndUpdate(
      req.params.id,
      {
        activo: true
      },
      {
        new: true
      }
    );

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada'
      });
    }

    res.json({
      mensaje: 'Reseña activada correctamente',
      resena
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al activar reseña',
      error: error.message
    });
  }
};


const eliminarResena = async (req, res) => {
  try {
    const resena = await Resena.findByIdAndDelete(
      req.params.id
    );

    if (!resena) {
      return res.status(404).json({
        mensaje: 'Reseña no encontrada'
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


module.exports = {
  obtenerResenas,
  obtenerResena,
  desactivarResena,
  activarResena,
  eliminarResena
};