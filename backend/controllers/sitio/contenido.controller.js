const Contenido = require('../../models/sitio/contenido');

const obtenerContenidos = async (req, res) => {
  try {
    const contenidos = await Contenido.find({
      sitio: req.params.sitioId,
      activo: true
    }).sort({ createdAt: -1 });

    res.json(contenidos);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener contenidos',
      error: error.message
    });
  }
};

const obtenerContenido = async (req, res) => {
  try {
    const contenido = await Contenido.findById(req.params.id);

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado'
      });
    }

    res.json(contenido);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener contenido',
      error: error.message
    });
  }
};

const crearContenido = async (req, res) => {
  try {
    const contenido = new Contenido(req.body);

    await contenido.save();

    res.status(201).json({
      mensaje: 'Contenido creado correctamente',
      contenido
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear contenido',
      error: error.message
    });
  }
};

const actualizarContenido = async (req, res) => {
  try {
    const contenido = await Contenido.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado'
      });
    }

    res.json({
      mensaje: 'Contenido actualizado correctamente',
      contenido
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar contenido',
      error: error.message
    });
  }
};

const desactivarContenido = async (req, res) => {
  try {
    const contenido = await Contenido.findByIdAndUpdate(
      req.params.id,
      { activo: false },
      { new: true }
    );

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado'
      });
    }

    res.json({
      mensaje: 'Contenido desactivado correctamente',
      contenido
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al desactivar contenido',
      error: error.message
    });
  }
};

const activarContenido = async (req, res) => {
  try {
    const contenido = await Contenido.findByIdAndUpdate(
      req.params.id,
      { activo: true },
      { new: true }
    );

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado'
      });
    }

    res.json({
      mensaje: 'Contenido activado correctamente',
      contenido
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al activar contenido',
      contenido
    });
  }
};

const eliminarContenido = async (req, res) => {
  try {
    const contenido = await Contenido.findByIdAndDelete(
      req.params.id
    );

    if (!contenido) {
      return res.status(404).json({
        mensaje: 'Contenido no encontrado'
      });
    }

    res.json({
      mensaje: 'Contenido eliminado correctamente'
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar contenido',
      error: error.message
    });
  }
};

module.exports = {
  obtenerContenidos,
  obtenerContenido,
  crearContenido,
  actualizarContenido,
  desactivarContenido,
  activarContenido,
  eliminarContenido
};