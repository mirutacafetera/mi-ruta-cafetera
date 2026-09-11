const Reporte = require('../../models/ayuda/reporte');


// =====================================================
// CREAR REPORTE
// =====================================================

const crearReporte = async (req, res) => {
  try {

    const {
      asunto,
      mensaje
    } = req.body;

    // -------------------------------------------------
    // VERIFICAR USUARIO AUTENTICADO
    // -------------------------------------------------

    if (!req.usuario) {
      return res.status(401).json({
        mensaje: 'Debes iniciar sesión'
      });
    }

    // -------------------------------------------------
    // VALIDAR CAMPOS
    // -------------------------------------------------

    if (!asunto || !mensaje) {
      return res.status(400).json({
        mensaje: 'El asunto y el mensaje son obligatorios'
      });
    }

    // -------------------------------------------------
    // OBTENER DATOS DEL USUARIO DESDE EL JWT
    // -------------------------------------------------

    const tipoRemitente = req.usuario.rol;
    const remitenteId = req.usuario.id;

    // -------------------------------------------------
    // CREAR REPORTE
    // -------------------------------------------------

    const nuevoReporte = new Reporte({
      tipoRemitente,
      remitenteId,
      asunto,
      mensaje
    });

    await nuevoReporte.save();

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(201).json({
      mensaje: 'Reporte enviado correctamente',
      reporte: nuevoReporte
    });

  } catch (error) {

    console.error(
      'Error al crear el reporte:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al crear el reporte',
      error: error.message
    });
  }
};


// =====================================================
// OBTENER TODOS LOS REPORTES
// =====================================================

const obtenerReportes = async (req, res) => {
  try {

    const reportes = await Reporte.find()
      .sort({ createdAt: -1 });

    return res.status(200).json({
      reportes
    });

  } catch (error) {

    console.error(
      'Error al obtener los reportes:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al obtener los reportes',
      error: error.message
    });
  }
};


// =====================================================
// OBTENER UN REPORTE
// =====================================================

const obtenerReporte = async (req, res) => {
  try {

    const reporte = await Reporte.findById(
      req.params.id
    );

    if (!reporte) {
      return res.status(404).json({
        mensaje: 'Reporte no encontrado'
      });
    }

    return res.status(200).json({
      reporte
    });

  } catch (error) {

    console.error(
      'Error al obtener el reporte:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al obtener el reporte',
      error: error.message
    });
  }
};


// =====================================================
// RESPONDER REPORTE
// =====================================================

const responderReporte = async (req, res) => {
  try {

    const {
      respuestaAdmin
    } = req.body;

    // -------------------------------------------------
    // VALIDAR RESPUESTA
    // -------------------------------------------------

    if (!respuestaAdmin) {
      return res.status(400).json({
        mensaje: 'La respuesta es obligatoria'
      });
    }

    // -------------------------------------------------
    // BUSCAR REPORTE
    // -------------------------------------------------

    const reporte = await Reporte.findById(
      req.params.id
    );

    if (!reporte) {
      return res.status(404).json({
        mensaje: 'Reporte no encontrado'
      });
    }

    // -------------------------------------------------
    // GUARDAR RESPUESTA
    // -------------------------------------------------

    reporte.respuestaAdmin = respuestaAdmin;
    reporte.estado = 'en_revision';

    await reporte.save();

    return res.status(200).json({
      mensaje: 'Respuesta enviada correctamente',
      reporte
    });

  } catch (error) {

    console.error(
      'Error al responder el reporte:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al responder el reporte',
      error: error.message
    });
  }
};


// =====================================================
// CAMBIAR ESTADO
// =====================================================

const cambiarEstadoReporte = async (req, res) => {
  try {

    const {
      estado
    } = req.body;

    // -------------------------------------------------
    // ESTADOS PERMITIDOS
    // -------------------------------------------------

    const estadosPermitidos = [
      'pendiente',
      'en_revision',
      'resuelto'
    ];

    if (!estadosPermitidos.includes(estado)) {
      return res.status(400).json({
        mensaje: 'Estado no válido'
      });
    }

    // -------------------------------------------------
    // BUSCAR REPORTE
    // -------------------------------------------------

    const reporte = await Reporte.findById(
      req.params.id
    );

    if (!reporte) {
      return res.status(404).json({
        mensaje: 'Reporte no encontrado'
      });
    }

    // -------------------------------------------------
    // ACTUALIZAR ESTADO
    // -------------------------------------------------

    reporte.estado = estado;

    await reporte.save();

    return res.status(200).json({
      mensaje: 'Estado actualizado correctamente',
      reporte
    });

  } catch (error) {

    console.error(
      'Error al cambiar el estado:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al cambiar el estado',
      error: error.message
    });
  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  crearReporte,
  obtenerReportes,
  obtenerReporte,
  responderReporte,
  cambiarEstadoReporte
};