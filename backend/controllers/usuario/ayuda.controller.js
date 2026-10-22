const Ayuda = require('../../models/usuario/ayuda');

// =====================================================
// AYUDA Y SOPORTE (USUARIO)
// =====================================================
//
//   POST /api/ayuda   crea un reporte del usuario autenticado
//   GET  /api/ayuda   lista SOLO los reportes del usuario
//
// La identidad sale siempre del JWT (req.usuario.id): el
// cuerpo de la petición no puede indicar a nombre de quién se
// crea ni de quién se consulta.
// =====================================================

const ASUNTO_MIN = 3;
const ASUNTO_MAX = 100;
const MENSAJE_MIN = 10;
const MENSAJE_MAX = 1000;

// Mismo reporte (asunto + mensaje) del mismo usuario dentro de
// esta ventana se considera un reenvío accidental.
const VENTANA_DUPLICADO_MS = 10 * 60 * 1000;

const MAX_REPORTES_LISTA = 50;

const validarReporte = (cuerpo) => {
  const asunto = cuerpo?.asunto;
  const mensaje = cuerpo?.mensaje;

  if (typeof asunto !== 'string' || typeof mensaje !== 'string') {
    return { error: 'El asunto y el mensaje son obligatorios' };
  }

  const asuntoLimpio = asunto.trim();
  const mensajeLimpio = mensaje.trim();

  if (
    asuntoLimpio.length < ASUNTO_MIN ||
    asuntoLimpio.length > ASUNTO_MAX
  ) {
    return {
      error:
        `El asunto debe tener entre ${ASUNTO_MIN} y ${ASUNTO_MAX} caracteres`
    };
  }

  if (
    mensajeLimpio.length < MENSAJE_MIN ||
    mensajeLimpio.length > MENSAJE_MAX
  ) {
    return {
      error:
        `El mensaje debe tener entre ${MENSAJE_MIN} y ${MENSAJE_MAX} caracteres`
    };
  }

  return { asunto: asuntoLimpio, mensaje: mensajeLimpio };
};

// =====================================================
// CREAR REPORTE DE AYUDA
// =====================================================
const crearReporte = async (req, res) => {
  try {
    const datos = validarReporte(req.body);

    if (datos.error) {
      return res.status(400).json({ mensaje: datos.error });
    }

    const usuarioId = req.usuario.id;

    const repetido = await Ayuda.findOne({
      usuarioId,
      asunto: datos.asunto,
      mensaje: datos.mensaje,
      createdAt: {
        $gte: new Date(Date.now() - VENTANA_DUPLICADO_MS)
      }
    })
      .select('_id')
      .lean();

    if (repetido) {
      return res.status(409).json({
        mensaje:
          'Ya enviaste este mismo reporte hace un momento. Te responderemos pronto.'
      });
    }

    const nuevo = await Ayuda.create({
      usuarioId,
      asunto: datos.asunto,
      mensaje: datos.mensaje
    });

    return res.status(201).json({
      mensaje: 'Reporte enviado correctamente',
      reporte: {
        id: nuevo._id,
        asunto: nuevo.asunto,
        mensaje: nuevo.mensaje,
        estado: nuevo.estado,
        createdAt: nuevo.createdAt
      }
    });
  } catch (error) {
    console.error('Error al crear reporte:', error && error.message);

    return res.status(500).json({
      mensaje: 'Error al enviar el reporte'
    });
  }
};

// =====================================================
// OBTENER MIS REPORTES
// =====================================================
const obtenerMisReportes = async (req, res) => {
  try {
    const reportes = await Ayuda.find({
      usuarioId: req.usuario.id
    })
      .select('asunto mensaje estado respuestaAdmin createdAt updatedAt')
      .sort({ createdAt: -1 })
      .limit(MAX_REPORTES_LISTA)
      .lean();

    return res.status(200).json(reportes);
  } catch (error) {
    console.error('Error al obtener reportes:', error && error.message);

    return res.status(500).json({
      mensaje: 'Error al obtener los reportes'
    });
  }
};

module.exports = {
  crearReporte,
  obtenerMisReportes,
  // Solo para pruebas
  _validarReporte: validarReporte
};
