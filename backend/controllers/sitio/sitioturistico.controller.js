const SitioTuristico = require('../../models/sitio/sitioturistico');

const obtenerSitios = async (req, res) => {
  try {
    const sitios = await SitioTuristico.find({
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

const crearSitio = async (req, res) => {
  try {
    const sitio = new SitioTuristico(req.body);

    await sitio.save();

    const sitioCreado = await SitioTuristico.findById(sitio._id)
      .populate('categoria');

    res.status(201).json({
      mensaje: 'Sitio turístico creado correctamente',
      sitio: sitioCreado
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
    const sitio = await SitioTuristico.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    ).populate('categoria');

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
    const sitio = await SitioTuristico.findByIdAndUpdate(
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

const activarSitio = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findByIdAndUpdate(
      req.params.id,
      {
        activo: true
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
      mensaje: 'Sitio turístico activado correctamente',
      sitio
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al activar sitio turístico',
      error: error.message
    });
  }
};

const eliminarSitio = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findByIdAndDelete(
      req.params.id
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.json({
      mensaje: 'Sitio turístico eliminado correctamente'
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar sitio turístico',
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
  activarSitio,
  eliminarSitio
};