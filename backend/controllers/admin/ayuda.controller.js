const Ayuda = require('../../models/usuario/ayuda');

// =====================================================
// OBTENER TODOS LOS REPORTES
// =====================================================

const obtenerReportes = async (req, res) => {
  try {
    const reportes = await Ayuda.find()
      .populate('usuarioId', 'nombre apellido correo')
      .sort({ createdAt: -1 });

    return res.status(200).json(reportes);

  } catch (error) {
    console.error('Error al obtener reportes:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener los reportes'
    });
  }
};


// =====================================================
// OBTENER UN REPORTE POR ID
// =====================================================

const obtenerReporte = async (req, res) => {
  try {
    const { id } = req.params;

    const reporte = await Ayuda.findById(id)
      .populate('usuarioId', 'nombre apellido correo');

    if (!reporte) {
      return res.status(404).json({
        mensaje: 'Reporte no encontrado'
      });
    }

    return res.status(200).json(reporte);

  } catch (error) {
    console.error('Error al obtener reporte:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener el reporte'
    });
  }
};


// =====================================================
// RESPONDER / ACTUALIZAR REPORTE
// =====================================================

const responderReporte = async (req, res) => {
  try {
    const { id } = req.params;
    const { estado, respuestaAdmin } = req.body;

    const reporte = await Ayuda.findById(id);

    if (!reporte) {
      return res.status(404).json({
        mensaje: 'Reporte no encontrado'
      });
    }

    if (estado) {
      reporte.estado = estado;
    }

    if (respuestaAdmin) {
      reporte.respuestaAdmin = respuestaAdmin;
    }

    await reporte.save();

    return res.status(200).json({
      mensaje: 'Reporte actualizado correctamente',
      reporte
    });

  } catch (error) {
    console.error('Error al responder reporte:', error);

    return res.status(500).json({
      mensaje: 'Error al actualizar el reporte'
    });
  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  obtenerReportes,
  obtenerReporte,
  responderReporte
};