const Actividad = require('../../models/sitio/actividad');

const obtenerActividades = async (req, res) => {
  try {
    const actividades = await Actividad.find({
      sitio: req.params.id,
      activo: true
    });

    res.json(actividades);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener actividades',
      error: error.message
    });
  }
};


const crearActividad = async (req, res) => {
  try {

    // -------------------------------------------------
    // COMPROBAR QUE EL SITIO PERTENECE A LA CUENTA
    // -------------------------------------------------

    if (req.usuario.sitioId !== req.params.id) {
      return res.status(403).json({
        mensaje:
          'No tienes permisos para administrar este sitio'
      });
    }

    // -------------------------------------------------
    // CREAR ACTIVIDAD
    // -------------------------------------------------

    const actividad = new Actividad({
      ...req.body,
      sitio: req.usuario.sitioId
    });

    await actividad.save();

    res.status(201).json({
      mensaje: 'Actividad creada correctamente',
      actividad
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al crear actividad',
      error: error.message
    });
  }
};

const actualizarActividad = async (req, res) => {
  try {

    // -------------------------------------------------
    // BUSCAR ACTIVIDAD DEL SITIO AUTENTICADO
    // -------------------------------------------------

    const actividad =
      await Actividad.findOneAndUpdate(
        {
          _id: req.params.actividadId,
          sitio: req.usuario.sitioId
        },
        req.body,
        {
          new: true,
          runValidators: true
        }
      );

    // -------------------------------------------------
    // COMPROBAR EXISTENCIA
    // -------------------------------------------------

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    res.json({
      mensaje: 'Actividad actualizada correctamente',
      actividad
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al actualizar actividad',
      error: error.message
    });
  }
};


const desactivarActividad = async (req, res) => {
  try {

    // -------------------------------------------------
    // BUSCAR ACTIVIDAD DEL SITIO AUTENTICADO
    // -------------------------------------------------

    const actividad =
      await Actividad.findOneAndUpdate(
        {
          _id: req.params.actividadId,
          sitio: req.usuario.sitioId
        },
        {
          activo: false
        },
        {
          new: true
        }
      );

    // -------------------------------------------------
    // COMPROBAR EXISTENCIA
    // -------------------------------------------------

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    res.json({
      mensaje: 'Actividad desactivada correctamente',
      actividad
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al desactivar actividad',
      error: error.message
    });
  }
};


module.exports = {
  obtenerActividades,
  crearActividad,
  actualizarActividad,
  desactivarActividad
};