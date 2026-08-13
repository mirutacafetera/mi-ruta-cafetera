const Sitio = require('../../models/usuario/sitio');

const obtenerSitios = async (req, res) => {
  try {
    const sitios = await Sitio.find()
      .populate('categoria');

    res.json(sitios);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener sitios turísticos',
      error: error.message
    });
  }
};


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


const crearSitio = async (req, res) => {
  try {
    const sitio = new Sitio(req.body);

    await sitio.save();

    res.status(201).json({
      mensaje: 'Sitio turístico creado correctamente',
      sitio
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear sitio turístico',
      error: error.message
    });
  }
};


const actualizarSitio = async (req, res) => {
  try {
    const sitio = await Sitio.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.json({
      mensaje: 'Sitio turístico actualizado correctamente',
      sitio
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar sitio turístico',
      error: error.message
    });
  }
};


const desactivarSitio = async (req, res) => {
  try {
    const sitio = await Sitio.findByIdAndUpdate(
      req.params.id,
      {
        activo: false
      },
      {
        new: true
      }
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.json({
      mensaje: 'Sitio turístico desactivado correctamente',
      sitio
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al desactivar sitio turístico',
      error: error.message
    });
  }
};


const agregarMultimedia = async (req, res) => {
  try {
    const { fotos, videos } = req.body;

    const sitio = await Sitio.findByIdAndUpdate(
      req.params.id,
      {
        fotos,
        videos
      },
      {
        new: true,
        runValidators: true
      }
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.json({
      mensaje: 'Fotografías y videos actualizados correctamente',
      sitio
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar multimedia',
      error: error.message
    });
  }
};


module.exports = {
  obtenerSitios,
  obtenerSitio,
  crearSitio,
  actualizarSitio,
  desactivarSitio,
  agregarMultimedia
};