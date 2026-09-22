const Notificacion = require('../models/usuario/notificacion');

// =====================================================
// CREAR NOTIFICACIÓN
// =====================================================

const crearNotificacion = async (
  usuarioId,
  titulo,
  mensaje,
  tipo = 'general'
) => {
  try {

    const notificacion = new Notificacion({
      usuario: usuarioId,
      titulo,
      mensaje,
      tipo,
      leida: false,
      activo: true
    });

    await notificacion.save();    

    return notificacion;

  } catch (error) {

    console.error(
      'Error al crear notificación:',
      error
    );

    throw error;
  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  crearNotificacion
};