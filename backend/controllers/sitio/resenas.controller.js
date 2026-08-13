const Resena = require('../../models/sitio/resena');

const obtenerResenas = async (req, res) => {
  try {
    const resenas = await Resena.find({
      sitio: req.params.id,
      activo: true
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

const obtenerCalificacionPromedio = async (req, res) => {
  try {
    const resenas = await Resena.find({
      sitio: req.params.id,
      activo: true
    });

    if (resenas.length === 0) {
      return res.json({
        promedio: 0,
        total: 0
      });
    }

    const suma = resenas.reduce(
      (total, resena) => total + resena.calificacion,
      0
    );

    const promedio = suma / resenas.length;

    res.json({
      promedio: Number(promedio.toFixed(1)),
      total: resenas.length
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener calificación',
      error: error.message
    });
  }
};

module.exports = {
  obtenerResenas,
  obtenerCalificacionPromedio
};