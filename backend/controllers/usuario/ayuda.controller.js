const Ayuda = require('../../models/usuario/ayuda');

// =====================================================
// CREAR REPORTE DE AYUDA
// =====================================================

const crearReporte = async (req, res) => {
  try {
    const { asunto, mensaje } = req.body;

    if (!asunto || !mensaje) {
      return res.status(400).json({
        mensaje: 'El asunto y el mensaje son obligatorios'
      });
    }

    const nuevoReporte = new Ayuda({
      usuarioId: req.usuario.id,
      asunto,
      mensaje
    });

    await nuevoReporte.save();

    return res.status(201).json({
      mensaje: 'Reporte enviado correctamente',
      reporte: nuevoReporte
    });

  } catch (error) {
    console.error('Error al crear reporte:', error);

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
    }).sort({ createdAt: -1 });

    return res.status(200).json(reportes);

  } catch (error) {
    console.error('Error al obtener reportes:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener los reportes'
    });
  }
};


module.exports = {
  crearReporte,
  obtenerMisReportes
};