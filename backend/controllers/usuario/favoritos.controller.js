const Favorito = require('../../models/usuario/favorito');

// OBTENER FAVORITOS
const obtenerFavoritos = async (req, res) => {
  try {
    const favoritos = await Favorito.find({
      usuario: req.params.usuarioId
    }).populate('sitio');

    res.json(favoritos);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener favoritos',
      error: error.message
    });
  }
};


// AGREGAR FAVORITO
const agregarFavorito = async (req, res) => {
  try {
    const { usuario, sitio } = req.body;

    const existe = await Favorito.findOne({
      usuario,
      sitio
    });

    if (existe) {
      return res.status(400).json({
        mensaje: 'El sitio ya está en favoritos'
      });
    }

    const favorito = new Favorito({
      usuario,
      sitio
    });

    await favorito.save();

    res.status(201).json({
      mensaje: 'Sitio agregado a favoritos',
      favorito
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al agregar favorito',
      error: error.message
    });
  }
};


// ELIMINAR FAVORITO
const eliminarFavorito = async (req, res) => {
  try {
    const favorito = await Favorito.findByIdAndDelete(
      req.params.id
    );

    if (!favorito) {
      return res.status(404).json({
        mensaje: 'Favorito no encontrado'
      });
    }

    res.json({
      mensaje: 'Sitio eliminado de favoritos'
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar favorito',
      error: error.message
    });
  }
};

module.exports = {
  obtenerFavoritos,
  agregarFavorito,
  eliminarFavorito
};