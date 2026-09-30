const Contenido = require('../../models/sitio/contenido');


// =====================================================
// OBTENER CONTENIDOS DE UN SITIO
// =====================================================

const obtenerContenidos = async (req, res) => {
  try {

    const contenidos = await Contenido.find({
      sitio: req.params.sitioId,
      activo: true
    }).sort({
      createdAt: -1
    });

    res.json(contenidos);

  } catch (error) {

    res.status(500).json({
      mensaje: 'Error al obtener contenidos',
      error: error.message
    });

  }
};


// =====================================================
// OBTENER UN CONTENIDO
// =====================================================

const obtenerContenido = async (req, res) => {
  try {

    const contenido =
      await Contenido.findById(req.params.id);

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


// =====================================================
// CREAR CONTENIDO
// =====================================================

const crearContenido = async (req, res) => {
  try {

    // -------------------------------------------------
    // CREAR CONTENIDO PARA EL SITIO AUTENTICADO
    // -------------------------------------------------

    const contenido = new Contenido({
      ...req.body,
      sitio: req.usuario.sitioId
    });

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


// =====================================================
// ACTUALIZAR CONTENIDO
// =====================================================

const actualizarContenido = async (req, res) => {
  try {

    // -------------------------------------------------
    // BUSCAR Y ACTUALIZAR SOLO CONTENIDO DEL SITIO
    // -------------------------------------------------

    const contenido =
      await Contenido.findOneAndUpdate(
        {
          _id: req.params.id,
          sitio: req.usuario.sitioId
        },
        req.body,
        {
          new: true,
          runValidators: true
        }
      );

    if (!contenido) {
      return res.status(404).json({
        mensaje:
          'Contenido no encontrado o no pertenece a este sitio'
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


// =====================================================
// DESACTIVAR CONTENIDO
// =====================================================

const desactivarContenido = async (req, res) => {
  try {

    const contenido =
      await Contenido.findOneAndUpdate(
        {
          _id: req.params.id,
          sitio: req.usuario.sitioId
        },
        {
          activo: false
        },
        {
          new: true
        }
      );

    if (!contenido) {
      return res.status(404).json({
        mensaje:
          'Contenido no encontrado o no pertenece a este sitio'
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


// =====================================================
// ACTIVAR CONTENIDO
// =====================================================

const activarContenido = async (req, res) => {
  try {

    const contenido =
      await Contenido.findOneAndUpdate(
        {
          _id: req.params.id,
          sitio: req.usuario.sitioId
        },
        {
          activo: true
        },
        {
          new: true
        }
      );

    if (!contenido) {
      return res.status(404).json({
        mensaje:
          'Contenido no encontrado o no pertenece a este sitio'
      });
    }

    res.json({
      mensaje: 'Contenido activado correctamente',
      contenido
    });

  } catch (error) {

    res.status(500).json({
      mensaje: 'Error al activar contenido',
      error: error.message
    });

  }
};


// =====================================================
// ELIMINAR CONTENIDO
// =====================================================

const eliminarContenido = async (req, res) => {
  try {

    const contenido =
      await Contenido.findOneAndDelete({
        _id: req.params.id,
        sitio: req.usuario.sitioId
      });

    if (!contenido) {
      return res.status(404).json({
        mensaje:
          'Contenido no encontrado o no pertenece a este sitio'
      });
    }

    res.json({
      mensaje: 'Contenido eliminado correctamente',
      contenido
    });

  } catch (error) {

    res.status(500).json({
      mensaje: 'Error al eliminar contenido',
      error: error.message
    });

  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  obtenerContenidos,
  obtenerContenido,
  crearContenido,
  actualizarContenido,
  desactivarContenido,
  activarContenido,
  eliminarContenido
};