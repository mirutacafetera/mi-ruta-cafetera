const Actividad = require('../../models/sitio/actividad');

// ======================================================
// OBTENER ACTIVIDADES DEL SITIO
// ======================================================

const obtenerActividades = async (req, res) => {
  try {
    const actividades = await Actividad.find({
      sitio: req.params.id,
      activo: true
    }).sort({ createdAt: -1 });

    res.status(200).json(actividades);

  } catch (error) {
    console.error('❌ Error al obtener actividades:', error);

    res.status(500).json({
      mensaje: 'Error al obtener actividades',
      error: error.message
    });
  }
};


// ======================================================
// CREAR ACTIVIDAD
// ======================================================

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
      nombre: req.body.nombre,
      descripcion: req.body.descripcion,
      precio: req.body.precio,
      horario: req.body.horario,
      duracion: req.body.duracion,

      sitio: req.usuario.sitioId,

      // La actividad comienza como borrador.
      estadoPublicacion: 'borrador',

      activo: true
    });

    await actividad.save();

    res.status(201).json({
      mensaje: 'Actividad creada correctamente como borrador',
      actividad
    });

  } catch (error) {
    console.error('❌ Error al crear actividad:', error);

    res.status(500).json({
      mensaje: 'Error al crear actividad',
      error: error.message
    });
  }
};


// ======================================================
// ACTUALIZAR ACTIVIDAD
// ======================================================

const actualizarActividad = async (req, res) => {
  try {

    // -------------------------------------------------
    // BUSCAR ACTIVIDAD DEL SITIO AUTENTICADO
    // -------------------------------------------------

    const actividad = await Actividad.findOne({
      _id: req.params.actividadId,
      sitio: req.usuario.sitioId
    });

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    // -------------------------------------------------
    // ACTUALIZAR SOLO CAMPOS PERMITIDOS
    // -------------------------------------------------

    if (req.body.nombre !== undefined) {
      actividad.nombre = req.body.nombre;
    }

    if (req.body.descripcion !== undefined) {
      actividad.descripcion = req.body.descripcion;
    }

    if (req.body.precio !== undefined) {
      actividad.precio = req.body.precio;
    }

    if (req.body.horario !== undefined) {
      actividad.horario = req.body.horario;
    }

    if (req.body.duracion !== undefined) {
      actividad.duracion = req.body.duracion;
    }

    // -------------------------------------------------
    // CAMBIO DE PUBLICACIÓN
    // -------------------------------------------------
    //
    // Si la actividad ya estaba aprobada y el sitio
    // modifica su información pública, el cambio
    // vuelve a requerir revisión.
    //
    // Si estaba rechazada, vuelve a quedar como borrador.
    //

    if (
      actividad.estadoPublicacion === 'aprobado' ||
      actividad.estadoPublicacion === 'rechazado'
    ) {
      actividad.estadoPublicacion = 'borrador';
      actividad.motivoRechazo = '';
      actividad.revisadoPor = null;
      actividad.revisadoAt = null;
    }

    await actividad.save();

    res.status(200).json({
      mensaje:
        'Actividad actualizada correctamente. Debe enviarse nuevamente a revisión para publicarse.',
      actividad
    });

  } catch (error) {
    console.error('❌ Error al actualizar actividad:', error);

    res.status(500).json({
      mensaje: 'Error al actualizar actividad',
      error: error.message
    });
  }
};


// ======================================================
// ENVIAR ACTIVIDAD A REVISIÓN
// ======================================================

const enviarActividadRevision = async (req, res) => {
  try {

    // -------------------------------------------------
    // BUSCAR ACTIVIDAD DEL SITIO AUTENTICADO
    // -------------------------------------------------

    const actividad = await Actividad.findOne({
      _id: req.params.actividadId,
      sitio: req.usuario.sitioId
    });

    if (!actividad) {
      return res.status(404).json({
        mensaje:
          'Actividad no encontrada o no pertenece a este sitio'
      });
    }

    // -------------------------------------------------
    // VALIDAR INFORMACIÓN BÁSICA
    // -------------------------------------------------

    if (!actividad.nombre || actividad.nombre.trim().length < 2) {
      return res.status(400).json({
        mensaje:
          'La actividad debe tener un nombre válido antes de enviarla a revisión'
      });
    }

    // -------------------------------------------------
    // COMPROBAR ESTADO
    // -------------------------------------------------

    if (actividad.estadoPublicacion === 'pendiente_revision') {
      return res.status(400).json({
        mensaje:
          'La actividad ya se encuentra pendiente de revisión'
      });
    }

    // -------------------------------------------------
    // ENVIAR A REVISIÓN
    // -------------------------------------------------

    actividad.estadoPublicacion = 'pendiente_revision';

    actividad.motivoRechazo = '';
    actividad.revisadoPor = null;
    actividad.revisadoAt = null;

    await actividad.save();

    res.status(200).json({
      mensaje:
        'Actividad enviada a revisión correctamente',
      actividad
    });

  } catch (error) {
    console.error(
      '❌ Error al enviar actividad a revisión:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al enviar la actividad a revisión',
      error: error.message
    });
  }
};


// ======================================================
// DESACTIVAR ACTIVIDAD
// ======================================================

const desactivarActividad = async (req, res) => {
  try {

    // -------------------------------------------------
    // BUSCAR ACTIVIDAD DEL SITIO AUTENTICADO
    // -------------------------------------------------

    const actividad = await Actividad.findOneAndUpdate(
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

    res.status(200).json({
      mensaje: 'Actividad desactivada correctamente',
      actividad
    });

  } catch (error) {
    console.error(
      '❌ Error al desactivar actividad:',
      error
    );

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
  enviarActividadRevision,
  desactivarActividad
};
