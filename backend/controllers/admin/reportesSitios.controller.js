
const mongoose = require('mongoose');
const Ayuda = require('../../models/usuario/ayuda');

const ESTADOS_PERMITIDOS = [
  'pendiente',
  'en_revision',
  'resuelto',
];

// GET /api/admin/reportes-sitios
const obtenerReportesSitios = async (req, res) => {
  try {
    const { estado, tipoReporte } = req.query;

    const filtro = {
      tipoRemitente: 'sitio',
    };

    if (estado && estado !== 'todos') {
      if (!ESTADOS_PERMITIDOS.includes(estado)) {
        return res.status(400).json({
          mensaje: 'El estado solicitado no es válido.',
        });
      }

      filtro.estado = estado;
    }

    if (tipoReporte && tipoReporte !== 'todos') {
      if (!['problema', 'sugerencia', 'mejora', 'otro'].includes(tipoReporte)) {
        return res.status(400).json({
          mensaje: 'El tipo de reporte no es válido.',
        });
      }

      filtro.tipoReporte = tipoReporte;
    }

    const reportes = await Ayuda.find(filtro)
      .populate('sitioId', 'nombre')
      .sort({ createdAt: -1 })
      .lean();

    return res.status(200).json(reportes);
  } catch (error) {
    console.error('Error al consultar reportes de sitios:', error);

    return res.status(500).json({
      mensaje: 'No fue posible consultar los reportes de sitios.',
    });
  }
};

// GET /api/admin/reportes-sitios/:id
const obtenerReporteSitio = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El identificador del reporte no es válido.',
      });
    }

    const reporte = await Ayuda.findOne({
      _id: id,
      tipoRemitente: 'sitio',
    })
      .populate('sitioId', 'nombre');

    if (!reporte) {
      return res.status(404).json({
        mensaje: 'No se encontró el reporte del sitio.',
      });
    }

    return res.status(200).json(reporte);
  } catch (error) {
    console.error('Error al consultar el reporte del sitio:', error);

    return res.status(500).json({
      mensaje: 'No fue posible consultar el reporte.',
    });
  }
};

// PUT /api/admin/reportes-sitios/:id
const responderReporteSitio = async (req, res) => {
  try {
    const { id } = req.params;
    const { estado, respuestaAdmin } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El identificador del reporte no es válido.',
      });
    }

    if (!ESTADOS_PERMITIDOS.includes(estado)) {
      return res.status(400).json({
        mensaje: 'Selecciona un estado válido.',
      });
    }

    if (
      typeof respuestaAdmin !== 'string' ||
      respuestaAdmin.trim().length > 3000
    ) {
      return res.status(400).json({
        mensaje: 'La respuesta debe ser un texto de máximo 3000 caracteres.',
      });
    }

    const reporte = await Ayuda.findOne({
      _id: id,
      tipoRemitente: 'sitio',
    });

    if (!reporte) {
      return res.status(404).json({
        mensaje: 'No se encontró el reporte del sitio.',
      });
    }

    reporte.estado = estado;
    reporte.respuestaAdmin = respuestaAdmin.trim() || null;

    await reporte.save();

    await reporte.populate('sitioId', 'nombre');

    return res.status(200).json({
      mensaje: 'Reporte del sitio actualizado correctamente.',
      reporte,
    });
  } catch (error) {
    console.error('Error al responder reporte del sitio:', error);

    return res.status(500).json({
      mensaje: 'No fue posible actualizar el reporte del sitio.',
    });
  }
};

module.exports = {
  obtenerReportesSitios,
  obtenerReporteSitio,
  responderReporteSitio,
};
