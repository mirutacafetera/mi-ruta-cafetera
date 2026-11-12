const Notificacion = require('../models/usuario/notificacion');
const Favorito = require('../models/usuario/favorito');
const SitioTuristico = require('../models/admin/sitio');

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
// AVISAR A LOS USUARIOS QUE UN SITIO PUBLICÓ UNA NOVEDAD
//
// Se llama cuando una actividad o un producto pasa a
// estadoPublicacion = 'aprobado' (por la IA o por el
// administrador). Destinatarios: usuarios que tienen el
// sitio en favoritos.
//
// Nunca lanza errores: una falla al notificar no debe
// impedir que la publicación se apruebe.
// =====================================================

const notificarContenidoPublicado = async (tipo, elemento) => {
  try {

    if (!['actividad', 'producto'].includes(tipo) || !elemento) {
      return 0;
    }

    const sitioId = elemento.sitio?._id || elemento.sitio;

    if (!sitioId) {
      return 0;
    }

    const filtroElemento = {
      tipo,
      [tipo]: elemento._id
    };

    // Usuarios con el sitio en favoritos.
    const destinatarios = await Favorito.distinct('usuario', {
      sitio: sitioId
    });

    if (destinatarios.length === 0) {
      return 0;
    }

    // Evita avisar dos veces por el mismo elemento
    // (por ejemplo, si se edita y se vuelve a aprobar).
    const yaAvisados = new Set(
      (
        await Notificacion.distinct('usuario', filtroElemento)
      ).map(String)
    );

    const pendientes = destinatarios.filter(
      id => !yaAvisados.has(String(id))
    );

    if (pendientes.length === 0) {
      return 0;
    }

    const sitio = await SitioTuristico.findById(sitioId)
      .select('nombre')
      .lean();

    const nombreSitio = sitio?.nombre || 'Un sitio que sigues';
    const nombreElemento = elemento.nombre || '';

    const titulo = tipo === 'actividad'
      ? `Nueva actividad en ${nombreSitio}`
      : `Nuevo producto en ${nombreSitio}`;

    const mensaje = tipo === 'actividad'
      ? `${nombreSitio} publicó una nueva actividad: ${nombreElemento}.`
      : `${nombreSitio} publicó un nuevo producto: ${nombreElemento}.`;

    await Notificacion.insertMany(
      pendientes.map(usuarioId => ({
        usuario: usuarioId,
        sitioOrigen: sitioId,
        [tipo]: elemento._id,
        titulo,
        mensaje,
        tipo,
        leida: false,
        activo: true
      }))
    );

    return pendientes.length;

  } catch (error) {

    console.error(
      'Error al notificar contenido publicado:',
      error.message
    );

    return 0;
  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  crearNotificacion,
  crearNotificacionSitio,
  notificarContenidoPublicado
};
