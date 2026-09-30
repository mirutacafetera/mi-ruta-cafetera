const SitioTuristico = require('../../models/admin/sitio');
const Actividad = require('../../models/sitio/actividad');
const Contenido = require('../../models/sitio/contenido');
const Reserva = require('../../models/sitio/reserva');
const Resena = require('../../models/sitio/resena');


// =====================================================
// OBTENER DASHBOARD DEL SITIO
// =====================================================

const obtenerDashboard = async (req, res) => {
  try {

    // -------------------------------------------------
    // IDENTIFICAR SITIO AUTENTICADO
    // -------------------------------------------------

    const sitioId = req.usuario.sitioId;

    // -------------------------------------------------
    // BUSCAR INFORMACIÓN DEL SITIO
    // -------------------------------------------------

    const sitio = await SitioTuristico.findById(
      sitioId
    ).select(
      'nombre activo'
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    // -------------------------------------------------
    // OBTENER ESTADÍSTICAS
    // -------------------------------------------------

    const [
      totalActividades,
      totalContenidos,
      totalReservas,
      totalResenas,
      reservasPendientes,
      reservasConfirmadas
    ] = await Promise.all([

      Actividad.countDocuments({
        sitio: sitioId,
        activo: true
      }),

      Contenido.countDocuments({
        sitio: sitioId,
        activo: true
      }),

      Reserva.countDocuments({
        sitio: sitioId
      }),

      Resena.countDocuments({
        sitio: sitioId,
        activo: true
      }),

      Reserva.countDocuments({
        sitio: sitioId,
        estado: 'pendiente'
      }),

      Reserva.countDocuments({
        sitio: sitioId,
        estado: 'confirmada'
      })

    ]);

    // -------------------------------------------------
    // CALIFICACIÓN PROMEDIO
    // -------------------------------------------------

    const resultadoCalificacion =
      await Resena.aggregate([
        {
          $match: {
            sitio: sitio._id,
            activo: true
          }
        },
        {
          $group: {
            _id: null,
            promedio: {
              $avg: '$calificacion'
            }
          }
        }
      ]);

    const promedioCalificacion =
      resultadoCalificacion.length > 0
        ? Number(
            resultadoCalificacion[0].promedio.toFixed(1)
          )
        : 0;

    // -------------------------------------------------
    // RESPUESTA
    // -------------------------------------------------

    return res.status(200).json({
      sitioId: sitio._id.toString(),
      nombreSitio: sitio.nombre,
      activo: sitio.activo,

      totalActividades,
      totalContenidos,
      totalReservas,
      totalResenas,

      promedioCalificacion,

      reservasPendientes,
      reservasConfirmadas
    });

  } catch (error) {

    console.error(
      'Error al obtener dashboard del sitio:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al obtener dashboard del sitio',
      error: error.message
    });
  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  obtenerDashboard
};