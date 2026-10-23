
const mongoose = require('mongoose');
const Ayuda = require('../../models/usuario/ayuda');

// =====================================================
// CREAR REPORTE O SUGERENCIA DE UN SITIO
// =====================================================

const crearReporteSitio = async (req, res) => {
  try {
    const { asunto, mensaje, tipoReporte } = req.body;
    const sitioId = req.usuario?.sitioId;

    if (!sitioId || !mongoose.Types.ObjectId.isValid(sitioId)) {
      return res.status(400).json({
        mensaje: 'No se pudo identificar el sitio autenticado.'
      });
    }

    if (
      typeof asunto !== 'string' ||
      typeof mensaje !== 'string' ||
      !asunto.trim() ||
      !mensaje.trim()
    ) {
      return res.status(400).json({
        mensaje: 'El asunto y la descripción son obligatorios.'
      });
    }

    const tiposPermitidos = [
      'problema',
      'sugerencia',
      'mejora',
      'otro'
    ];

    const tipo = tipoReporte || 'problema';

    if (!tiposPermitidos.includes(tipo)) {
      return res.status(400).json({
        mensaje: 'El tipo de reporte no es válido.'
      });
    }

    if (asunto.trim().length > 120 || mensaje.trim().length > 3000) {
      return res.status(400).json({
        mensaje: 'El asunto admite máximo 120 caracteres y la descripción 3000.'
      });
    }

    const nuevoReporte = new Ayuda({
      tipoRemitente: 'sitio',
      sitioId,
      tipoReporte: tipo,
      asunto: asunto.trim(),
      mensaje: mensaje.trim()
    });

    await nuevoReporte.save();

    return res.status(201).json({
      mensaje: 'Reporte enviado correctamente.',
      reporte: nuevoReporte
    });
  } catch (error) {
    console.error('Error al crear reporte del sitio:', error);

    return res.status(500).json({
      mensaje: 'Error al enviar el reporte.'
    });
  }
};

// =====================================================
// CONSULTAR REPORTES DEL SITIO AUTENTICADO
// =====================================================

const obtenerMisReportesSitio = async (req, res) => {
  try {
    const sitioId = req.usuario?.sitioId;

    if (!sitioId || !mongoose.Types.ObjectId.isValid(sitioId)) {
      return res.status(400).json({
        mensaje: 'No se pudo identificar el sitio autenticado.'
      });
    }

    const reportes = await Ayuda.find({
      tipoRemitente: 'sitio',
      sitioId
    }).sort({ createdAt: -1 });

    return res.status(200).json(reportes);
  } catch (error) {
    console.error('Error al consultar reportes del sitio:', error);

    return res.status(500).json({
      mensaje: 'Error al consultar tus reportes.'
    });
  }
};

module.exports = {
  crearReporteSitio,
  obtenerMisReportesSitio
};
