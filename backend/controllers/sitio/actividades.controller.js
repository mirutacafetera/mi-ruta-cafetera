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
    const actividad = new Actividad({
      ...req.body,
      sitio: req.params.id
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
    const actividad = await Actividad.findByIdAndUpdate(
      req.params.actividadId,
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!actividad) {
      return res.status(404).json({
        mensaje: 'Actividad no encontrada'
      });
    }

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
    const actividad = await Actividad.findByIdAndUpdate(
      req.params.actividadId,
      {
        activo: false
      },
      {
        new: true
      }
    );

    if (!actividad) {
      return res.status(404).json({
        mensaje: 'Actividad no encontrada'
      });
    }

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