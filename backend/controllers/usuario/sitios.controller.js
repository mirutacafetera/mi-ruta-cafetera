const Sitio = require('../../models/usuario/sitio');

// OBTENER TODOS LOS SITIOS
const obtenerSitios = async (req, res) => {
  try {
    const sitios = await Sitio.find({
      activo: true
    }).populate('categoria');

    res.json(sitios);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener sitios turísticos',
      error: error.message
    });
  }
};


// OBTENER UN SITIO
const obtenerSitio = async (req, res) => {
  try {
    const sitio = await Sitio.findById(req.params.id)
      .populate('categoria');

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.json(sitio);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener sitio turístico',
      error: error.message
    });
  }
};


// BUSCAR SITIOS
const buscarSitios = async (req, res) => {
  try {
    const { nombre } = req.query;

    const sitios = await Sitio.find({
      nombre: {
        $regex: nombre,
        $options: 'i'
      },
      activo: true
    }).populate('categoria');

    res.json(sitios);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al buscar sitios turísticos',
      error: error.message
    });
  }
};


// FILTRAR POR CATEGORÍA
const filtrarPorCategoria = async (req, res) => {
  try {
    const sitios = await Sitio.find({
      categoria: req.params.categoriaId,
      activo: true
    }).populate('categoria');

    res.json(sitios);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al filtrar sitios',
      error: error.message
    });
  }
};

module.exports = {
  obtenerSitios,
  obtenerSitio,
  buscarSitios,
  filtrarPorCategoria
};