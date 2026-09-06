const SitioTuristico = require('../../models/admin/sitio');

// ============================================================
// OBTENER TODOS LOS SITIOS TURÍSTICOS
// ============================================================

const obtenerSitios = async (req, res) => {
  try {
    const sitios = await SitioTuristico.find({
      activo: true
    })
      .populate('categoria')
      .sort({ nombre: 1 });

    res.json(sitios);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener sitios turísticos',
      error: error.message
    });
  }
};


// ============================================================
// OBTENER UN SITIO
// ============================================================

const obtenerSitio = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findById(req.params.id)
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


// ============================================================
// BUSCAR SITIOS
// ============================================================

const buscarSitios = async (req, res) => {
  try {
    const { nombre } = req.query;

    if (!nombre || !nombre.trim()) {
      return res.json([]);
    }

    const sitios = await SitioTuristico.find({
      nombre: {
        $regex: nombre.trim(),
        $options: 'i'
      },
      activo: true
    })
      .populate('categoria')
      .sort({ nombre: 1 });

    res.json(sitios);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al buscar sitios turísticos',
      error: error.message
    });
  }
};


// ============================================================
// FILTRAR POR CATEGORÍA
// ============================================================

const filtrarPorCategoria = async (req, res) => {
  try {
    const sitios = await SitioTuristico.find({
      categoria: req.params.categoriaId,
      activo: true
    })
      .populate('categoria')
      .sort({ nombre: 1 });

    res.json(sitios);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al filtrar sitios',
      error: error.message
    });
  }
};


// ============================================================
// EXPORTACIONES
// ============================================================

module.exports = {
  obtenerSitios,
  obtenerSitio,
  buscarSitios,
  filtrarPorCategoria
};