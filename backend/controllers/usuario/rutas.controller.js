const Ruta = require('../../models/usuario/ruta');

// OBTENER RUTAS DEL USUARIO
const obtenerRutas = async (req, res) => {
  try {
    const rutas = await Ruta.find({
      usuario: req.params.usuarioId,
      activa: true
    }).populate('sitios');

    res.json(rutas);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener rutas',
      error: error.message
    });
  }
};


// CREAR RUTA
const crearRuta = async (req, res) => {
  try {
    const ruta = new Ruta(req.body);

    await ruta.save();

    res.status(201).json({
      mensaje: 'Ruta creada correctamente',
      ruta
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear ruta',
      error: error.message
    });
  }
};


// ACTUALIZAR RUTA
const actualizarRuta = async (req, res) => {
  try {
    const ruta = await Ruta.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!ruta) {
      return res.status(404).json({
        mensaje: 'Ruta no encontrada'
      });
    }

    res.json({
      mensaje: 'Ruta actualizada correctamente',
      ruta
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar ruta',
      error: error.message
    });
  }
};


// ELIMINAR RUTA
const eliminarRuta = async (req, res) => {
  try {
    const ruta = await Ruta.findByIdAndDelete(
      req.params.id
    );

    if (!ruta) {
      return res.status(404).json({
        mensaje: 'Ruta no encontrada'
      });
    }

    res.json({
      mensaje: 'Ruta eliminada correctamente'
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar ruta',
      error: error.message
    });
  }
};


module.exports = {
  obtenerRutas,
  crearRuta,
  actualizarRuta,
  eliminarRuta
};