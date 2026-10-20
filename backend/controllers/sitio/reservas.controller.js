const Reserva = require('../../models/sitio/reserva');
const Notificacion = require('../../models/usuario/notificacion');

const {
  crearNotificacion
} = require('../../services/notificacion.service');


// =====================================================
// CONSTANTES Y UTILIDADES
// =====================================================

const ID_VALIDO = /^[a-f\d]{24}$/i;

const MAX_RESPUESTA = 500;
const MIN_MOTIVO = 3;

// Estados a los que puede pasar el establecimiento.
// ('cancelada' desde pendiente se conserva por compatibilidad
//  con versiones anteriores de la app.)
const TRANSICIONES = {
  pendiente: ['confirmada', 'rechazada', 'cancelada'],
  confirmada: ['completada', 'cancelada']
};

const ESTADOS_DESTINO = [
  'confirmada',
  'rechazada',
  'cancelada',
  'completada'
];

const esId = (valor) => ID_VALIDO.test(String(valor || ''));

const limpiarTexto = (valor, maximo) => {
  if (typeof valor !== 'string') return '';

  return valor
    // eslint-disable-next-line no-control-regex
    .replace(/[\u0000-\u001f\u007f]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, maximo);
};

const mismoSitio = (req) =>
  String(req.usuario.sitioId || '') !== '' &&
  String(req.usuario.sitioId) === String(req.params.id);

const errorInterno = (res, contexto, error, mensaje) => {
  console.error(contexto, error);

  return res.status(500).json({ mensaje });
};

const poblar = (consulta) =>
  consulta
    .populate('usuario', 'nombre apellido correo telefono')
    .populate('actividad', 'nombre descripcion precio')
    .populate('sitio', 'nombre');


// =====================================================
// OBTENER RESERVAS DEL SITIO
// =====================================================

const obtenerReservas = async (req, res) => {
  try {

    if (!mismoSitio(req)) {
      return res.status(403).json({
        mensaje:
          'No tienes permisos para consultar las reservas de este sitio'
      });
    }

    const reservas = await poblar(
      Reserva.find({
        sitio: req.usuario.sitioId
      })
    ).sort({
      fecha: 1
    });

    res.json(reservas);

  } catch (error) {

    errorInterno(
      res,
      'Error al obtener reservas del sitio:',
      error,
      'No se pudieron obtener las reservas.'
    );

  }
};


// =====================================================
// OBTENER UNA RESERVA
// =====================================================

const obtenerReserva = async (req, res) => {
  try {

    if (!mismoSitio(req)) {
      return res.status(403).json({
        mensaje:
          'No tienes permisos para consultar esta reserva'
      });
    }

    if (!esId(req.params.reservaId)) {
      return res.status(404).json({
        mensaje:
          'Reserva no encontrada o no pertenece a este sitio'
      });
    }

    const reserva = await poblar(
      Reserva.findOne({
        _id: req.params.reservaId,
        sitio: req.usuario.sitioId
      })
    );

    if (!reserva) {
      return res.status(404).json({
        mensaje:
          'Reserva no encontrada o no pertenece a este sitio'
      });
    }

    res.json(reserva);

  } catch (error) {

    errorInterno(
      res,
      'Error al obtener la reserva del sitio:',
      error,
      'No se pudo obtener la reserva.'
    );

  }
};


// =====================================================
// ACTUALIZAR ESTADO DE RESERVA
//
// Cuerpo: { estado, motivo? }
//   - rechazada: el motivo es obligatorio.
//   - confirmada: el motivo es opcional y sirve para dar
//     indicaciones (contacto, pago, punto de encuentro).
// =====================================================

const actualizarEstadoReserva = async (req, res) => {
  try {

    if (!mismoSitio(req)) {
      return res.status(403).json({
        mensaje:
          'No tienes permisos para modificar reservas de este sitio'
      });
    }

    const body =
      req.body &&
      typeof req.body === 'object' &&
      !Array.isArray(req.body)
        ? req.body
        : {};

    const estado = body.estado;

    if (!ESTADOS_DESTINO.includes(estado)) {
      return res.status(400).json({
        mensaje: 'Estado de reserva no válido'
      });
    }

    const respuesta = limpiarTexto(
      typeof body.motivo === 'string' ? body.motivo : body.respuesta,
      MAX_RESPUESTA
    );

    if (estado === 'rechazada' && respuesta.length < MIN_MOTIVO) {
      return res.status(400).json({
        mensaje: 'Indica el motivo del rechazo.'
      });
    }

    if (!esId(req.params.reservaId)) {
      return res.status(404).json({
        mensaje:
          'Reserva no encontrada o no pertenece a este sitio'
      });
    }

    const actual = await Reserva.findOne({
      _id: req.params.reservaId,
      sitio: req.usuario.sitioId
    });

    if (!actual) {
      return res.status(404).json({
        mensaje:
          'Reserva no encontrada o no pertenece a este sitio'
      });
    }

    const permitidos = TRANSICIONES[actual.estado] || [];

    if (!permitidos.includes(estado)) {
      return res.status(409).json({
        mensaje:
          `No se puede pasar una reserva de ${actual.estado} ` +
          `a ${estado}.`
      });
    }

    const cambios = {
      estado,
      respondidaAt: new Date()
    };

    if (respuesta) {
      cambios.respuestaSitio = respuesta;
    }

    // El filtro por estado evita pisar un cambio simultáneo.
    const reserva = await poblar(
      Reserva.findOneAndUpdate(
        {
          _id: req.params.reservaId,
          sitio: req.usuario.sitioId,
          estado: actual.estado
        },
        cambios,
        {
          new: true,
          runValidators: true
        }
      )
    );

    if (!reserva) {
      return res.status(409).json({
        mensaje:
          'La reserva cambió de estado. Actualiza la lista.'
      });
    }

    // ---------------------------------------------
    // AVISAR AL USUARIO (persistente)
    // ---------------------------------------------

    const textos = {
      confirmada: {
        titulo: 'Reserva confirmada',
        mensaje: (sitio, actividad) =>
          `${sitio} confirmó tu solicitud de ${actividad}. ` +
          'El establecimiento te contactará para coordinar el pago.'
      },
      rechazada: {
        titulo: 'Solicitud rechazada',
        mensaje: (sitio, actividad) =>
          `${sitio} no pudo aceptar tu solicitud de ${actividad}.`
      },
      cancelada: {
        titulo: 'Reserva cancelada',
        mensaje: (sitio, actividad) =>
          `${sitio} canceló tu reserva de ${actividad}.`
      }
    };

    const texto = textos[estado];

    if (texto && reserva.usuario) {
      try {
        const nombreSitio =
          (reserva.sitio && reserva.sitio.nombre) ||
          'El establecimiento';

        const nombreActividad =
          reserva.actividadNombre ||
          (reserva.actividad && reserva.actividad.nombre) ||
          'la actividad';

        const idUsuario = reserva.usuario._id || reserva.usuario;

        const detalle = reserva.respuestaSitio
          ? ` Mensaje: ${reserva.respuestaSitio}`
          : '';

        await crearNotificacion(
          idUsuario,
          texto.titulo,
          texto.mensaje(nombreSitio, nombreActividad) + detalle,
          `reserva_${estado}`,
          reserva._id
        );
      } catch (errorAviso) {
        console.error(
          'No se pudo notificar al usuario (el estado quedó guardado):',
          errorAviso
        );
      }
    }

    res.json({
      mensaje: 'Estado de reserva actualizado correctamente',
      reserva
    });

  } catch (error) {

    errorInterno(
      res,
      'Error al actualizar estado de reserva:',
      error,
      'No se pudo actualizar el estado de la reserva.'
    );

  }
};


// =====================================================
// NOTIFICACIONES DEL ESTABLECIMIENTO
// =====================================================

const obtenerNotificacionesSitio = async (req, res) => {
  try {

    const notificaciones = await Notificacion.find({
      sitio: req.usuario.sitioId,
      activo: true
    })
      .sort({ createdAt: -1 })
      .limit(100);

    res.json(notificaciones);

  } catch (error) {

    errorInterno(
      res,
      'Error al obtener notificaciones del sitio:',
      error,
      'No se pudieron obtener las notificaciones.'
    );

  }
};

const marcarNotificacionSitioLeida = async (req, res) => {
  try {

    if (!esId(req.params.id)) {
      return res.status(404).json({
        mensaje: 'Notificación no encontrada'
      });
    }

    const notificacion = await Notificacion.findOneAndUpdate(
      {
        _id: req.params.id,
        sitio: req.usuario.sitioId
      },
      { leida: true },
      { new: true }
    );

    if (!notificacion) {
      return res.status(404).json({
        mensaje: 'Notificación no encontrada'
      });
    }

    res.json({
      mensaje: 'Notificación marcada como leída',
      notificacion
    });

  } catch (error) {

    errorInterno(
      res,
      'Error al marcar la notificación del sitio:',
      error,
      'No se pudo marcar la notificación.'
    );

  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  obtenerReservas,
  obtenerReserva,
  actualizarEstadoReserva,
  obtenerNotificacionesSitio,
  marcarNotificacionSitioLeida
};
