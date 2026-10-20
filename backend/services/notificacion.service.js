const Notificacion = require('../models/usuario/notificacion');

// =====================================================
// CREAR NOTIFICACIÓN PARA UN USUARIO
// =====================================================

const crearNotificacion = async (
  usuarioId,
  titulo,
  mensaje,
  tipo = 'general',
  reservaId = null
) => {
  try {

    const notificacion = new Notificacion({
      usuario: usuarioId,
      reserva: reservaId,
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
// CREAR NOTIFICACIÓN PARA UN ESTABLECIMIENTO
// Se guarda en la base de datos: sigue disponible aunque
// el establecimiento cierre y vuelva a abrir la aplicación.
// =====================================================

const crearNotificacionSitio = async (
  sitioId,
  titulo,
  mensaje,
  tipo = 'general',
  reservaId = null
) => {
  try {

    const notificacion = new Notificacion({
      sitio: sitioId,
      reserva: reservaId,
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
      'Error al crear notificación del sitio:',
      error
    );

    throw error;
  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  crearNotificacion,
  crearNotificacionSitio
};
