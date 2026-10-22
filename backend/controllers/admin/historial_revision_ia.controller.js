
const HistorialRevisionIA = require(
  '../../models/admin/historial_revision_ia'
);

const obtenerHistorialRevisionIA = async (req, res) => {
  try {
    const pagina = Math.max(
      1,
      parseInt(req.query.pagina, 10) || 1,
    );

    const limite = Math.min(
      100,
      Math.max(1, parseInt(req.query.limite, 10) || 20),
    );

    const filtro = {};

    const tiposPermitidos = [
      'contenido',
      'producto',
      'actividad',
    ];

    const decisionesPermitidas = [
      'aprobado',
      'rechazado',
      'pendiente_manual',
      'error',
    ];

    if (req.query.tipoSolicitud) {
      if (!tiposPermitidos.includes(req.query.tipoSolicitud)) {
        return res.status(400).json({
          mensaje: 'El tipo de solicitud no es válido.',
        });
      }

      filtro.tipoSolicitud = req.query.tipoSolicitud;
    }

    if (req.query.decision) {
      if (!decisionesPermitidas.includes(req.query.decision)) {
        return res.status(400).json({
          mensaje: 'La decisión indicada no es válida.',
        });
      }

      filtro.decision = req.query.decision;
    }

    const [historial, total] = await Promise.all([
      HistorialRevisionIA.find(filtro)
        .sort({ fechaDecision: -1 })
        .skip((pagina - 1) * limite)
        .limit(limite)
        .lean(),

      HistorialRevisionIA.countDocuments(filtro),
    ]);

    return res.status(200).json({
      mensaje: 'Historial de revisiones obtenido correctamente.',
      historial,
      paginacion: {
        pagina,
        limite,
        total,
        totalPaginas: Math.ceil(total / limite),
      },
    });
  } catch (error) {
    console.error(
      'Error consultando el historial de la IA:',
      error,
    );

    return res.status(500).json({
      mensaje: 'No se pudo consultar el historial de revisiones.',
    });
  }
};

module.exports = {
  obtenerHistorialRevisionIA,
};
