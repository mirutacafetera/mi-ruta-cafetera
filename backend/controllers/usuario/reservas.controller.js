
const Reserva = require('../../models/sitio/reserva');
const Actividad = require('../../models/sitio/actividad');
const SitioTuristico = require('../../models/admin/sitio');

const {
  crearNotificacion,
  crearNotificacionSitio
} = require('../../services/notificacion.service');


// =====================================================
// CONSTANTES Y UTILIDADES
// =====================================================

const ID_VALIDO = /^[a-f\d]{24}$/i;

const MAX_PERSONAS = 50;
const MAX_OBSERVACIONES = 500;
const MAX_CLAVE = 80;

const UNA_HORA = 60 * 60 * 1000;
const UN_DIA = 24 * UNA_HORA;

// Margen para no rechazar "hoy" por diferencias de zona horaria.
const TOLERANCIA_FECHA_MS = UN_DIA;
const HORIZONTE_FECHA_MS = 2 * 365 * UN_DIA;

const ESTADOS_CANCELABLES = ['pendiente', 'confirmada'];

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

const formatearFecha = (fecha) => {
  const iso = new Date(fecha).toISOString().slice(0, 10);
  const [anio, mes, dia] = iso.split('-');
  return `${dia}/${mes}/${anio}`;
};

const redondear = (numero) => Math.round(numero * 100) / 100;

const errorInterno = (res, contexto, error, mensaje) => {
  // El detalle técnico queda en el registro del servidor;
  // al cliente solo se le devuelve un mensaje genérico.
  console.error(contexto, error);

  return res.status(500).json({ mensaje });
};

const leerFecha = (valor) => {
  if (
    valor === undefined ||
    valor === null ||
    valor === ''
  ) {
    return { error: 'La fecha de la reserva es obligatoria.' };
  }

  if (typeof valor !== 'string' && !(valor instanceof Date)) {
    return { error: 'La fecha de la reserva no es válida.' };
  }

  const fecha = new Date(valor);

  if (Number.isNaN(fecha.getTime())) {
    return { error: 'La fecha de la reserva no es válida.' };
  }

  const ahora = Date.now();

  if (fecha.getTime() < ahora - TOLERANCIA_FECHA_MS) {
    return { error: 'La fecha de la reserva no puede ser anterior a hoy.' };
  }

  if (fecha.getTime() > ahora + HORIZONTE_FECHA_MS) {
    return { error: 'La fecha de la reserva está demasiado lejos.' };
  }

  return { fecha };
};

const leerCantidad = (valor) => {
  const numero =
    typeof valor === 'number'
      ? valor
      : typeof valor === 'string' && valor.trim() !== ''
        ? Number(valor)
        : NaN;

  if (
    !Number.isInteger(numero) ||
    numero < 1 ||
    numero > MAX_PERSONAS
  ) {
    return {
      error:
        `La cantidad de personas debe ser un número entero ` +
        `entre 1 y ${MAX_PERSONAS}.`
    };
  }

  return { cantidad: numero };
};

const leerObservaciones = (valor) => {
  if (valor === undefined || valor === null) {
    return { observaciones: '' };
  }

  if (typeof valor !== 'string') {
    return { error: 'Las observaciones no son válidas.' };
  }

  if (valor.trim().length > MAX_OBSERVACIONES) {
    return {
      error:
        `Las observaciones no pueden superar ` +
        `${MAX_OBSERVACIONES} caracteres.`
    };
  }

  return { observaciones: limpiarTexto(valor, MAX_OBSERVACIONES) };
};

const cuerpoDe = (req) =>
  req.body &&
  typeof req.body === 'object' &&
  !Array.isArray(req.body)
    ? req.body
    : {};

// Avisos: si fallan, la reserva ya está guardada y no se pierde.
const avisar = async (tarea, contexto) => {
  try {
    await tarea();
  } catch (error) {
    console.error(
      `${contexto} (la reserva quedó guardada):`,
      error
    );
  }
};


// =====================================================
// OBTENER RESERVAS DEL USUARIO AUTENTICADO
// =====================================================

const obtenerReservas = async (req, res) => {
  try {
    const reservas = await Reserva.find({
      usuario: req.usuario.id
    })
      .populate(
        'sitio',
        'nombre descripcion ciudad departamento imagen'
      )
      .populate(
        'actividad',
        'nombre descripcion precio horario duracion imagenPrincipal'
      )
      .sort({
        fecha: -1
      });

    res.status(200).json(reservas);

  } catch (error) {
    errorInterno(
      res,
      'Error al obtener reservas:',
      error,
      'No se pudieron obtener tus reservas.'
    );
  }
};


// =====================================================
// CREAR SOLICITUD DE RESERVA
//
// Cuerpo: { actividad, fecha, cantidadPersonas,
//           observaciones?, sitio?, claveSolicitud? }
//
// - El usuario sale del token.
// - El sitio y el precio salen de la actividad guardada;
//   el cliente no puede imponerlos.
// =====================================================

const crearReserva = async (req, res) => {
  try {
    const body = cuerpoDe(req);
    const usuarioId = req.usuario.id;

    // ---------------------------------------------
    // VALIDAR ENTRADA
    // ---------------------------------------------

    if (!esId(body.actividad)) {
      return res.status(400).json({
        mensaje: 'Selecciona una actividad válida.'
      });
    }

    const sitioIndicado =
      body.sitio === undefined ||
      body.sitio === null ||
      body.sitio === ''
        ? null
        : String(body.sitio);

    if (sitioIndicado !== null && !esId(sitioIndicado)) {
      return res.status(400).json({
        mensaje: 'El sitio indicado no es válido.'
      });
    }

    const resultadoFecha = leerFecha(body.fecha);

    if (resultadoFecha.error) {
      return res.status(400).json({
        mensaje: resultadoFecha.error
      });
    }

    const resultadoCantidad = leerCantidad(body.cantidadPersonas);

    if (resultadoCantidad.error) {
      return res.status(400).json({
        mensaje: resultadoCantidad.error
      });
    }

    const resultadoObservaciones = leerObservaciones(
      body.observaciones
    );

    if (resultadoObservaciones.error) {
      return res.status(400).json({
        mensaje: resultadoObservaciones.error
      });
    }

    const { fecha } = resultadoFecha;
    const { cantidad } = resultadoCantidad;
    const { observaciones } = resultadoObservaciones;

    const clave = limpiarTexto(
      (req.headers && req.headers['idempotency-key']) ||
        body.claveSolicitud,
      MAX_CLAVE
    );

    // ---------------------------------------------
    // REINTENTO DE UNA SOLICITUD YA REGISTRADA
    // ---------------------------------------------

    const respuestaDuplicada = (reserva) =>
      res.status(200).json({
        mensaje: 'Esta solicitud ya había sido registrada.',
        duplicada: true,
        reserva
      });

    if (clave) {
      const previa = await Reserva.findOne({
        usuario: usuarioId,
        claveSolicitud: clave
      });

      if (previa) {
        return respuestaDuplicada(previa);
      }
    }

    // ---------------------------------------------
    // COMPROBAR ACTIVIDAD Y SITIO
    // ---------------------------------------------

    const actividad = await Actividad
      .findById(body.actividad)
      .select('sitio nombre precio activo estadoPublicacion')
      .lean();

    if (
      !actividad ||
      actividad.activo === false ||
      actividad.estadoPublicacion !== 'aprobado'
    ) {
      return res.status(404).json({
        mensaje: 'La actividad no existe o no está disponible.'
      });
    }

    const sitioId = String(actividad.sitio);

    if (sitioIndicado !== null && sitioIndicado !== sitioId) {
      return res.status(400).json({
        mensaje: 'La actividad no pertenece al sitio indicado.'
      });
    }

    const sitio = await SitioTuristico
      .findById(sitioId)
      .select('nombre activo')
      .lean();

    if (!sitio || sitio.activo === false) {
      return res.status(404).json({
        mensaje: 'El sitio turístico no está disponible.'
      });
    }

    // ---------------------------------------------
    // SOLICITUD PENDIENTE REPETIDA
    // ---------------------------------------------

    const repetida = await Reserva.findOne({
      usuario: usuarioId,
      actividad: actividad._id,
      estado: 'pendiente',
      fecha: {
        $gte: new Date(fecha.getTime() - 12 * UNA_HORA),
        $lte: new Date(fecha.getTime() + 12 * UNA_HORA)
      }
    });

    if (repetida) {
      return res.status(409).json({
        mensaje:
          'Ya tienes una solicitud pendiente para esta ' +
          'actividad en esa fecha.'
      });
    }

    // ---------------------------------------------
    // PRECIO: SIEMPRE DESDE LA BASE DE DATOS
    // ---------------------------------------------

    const precioUnitario =
      Number.isFinite(actividad.precio) && actividad.precio > 0
        ? actividad.precio
        : 0;

    const reserva = new Reserva({
      usuario: usuarioId,
      sitio: sitioId,
      actividad: actividad._id,
      fecha,
      cantidadPersonas: cantidad,
      actividadNombre: actividad.nombre || '',
      precioUnitario,
      precioTotal: redondear(precioUnitario * cantidad),
      estado: 'pendiente',
      observaciones,
      ...(clave ? { claveSolicitud: clave } : {})
    });

    try {
      await reserva.save();
    } catch (errorGuardado) {
      // Dos envíos simultáneos con la misma clave.
      if (clave && errorGuardado && errorGuardado.code === 11000) {
        const previa = await Reserva.findOne({
          usuario: usuarioId,
          claveSolicitud: clave
        });

        if (previa) {
          return respuestaDuplicada(previa);
        }
      }

      throw errorGuardado;
    }

    // ---------------------------------------------
    // NOTIFICACIONES PERSISTENTES
    // ---------------------------------------------

    const nombreActividad = actividad.nombre || 'una actividad';

    await avisar(
      () =>
        crearNotificacionSitio(
          sitioId,
          'Nueva solicitud de reserva',
          `${nombreActividad}: ${cantidad} ` +
            `${cantidad === 1 ? 'persona' : 'personas'} ` +
            `para el ${formatearFecha(fecha)}. ` +
            'Revísala en Reservas.',
          'reserva_nueva',
          reserva._id
        ),
      'No se pudo notificar al establecimiento'
    );

    await avisar(
      () =>
        crearNotificacion(
          usuarioId,
          'Solicitud enviada',
          `Tu solicitud para ${nombreActividad} fue enviada ` +
            'y está pendiente de confirmación.',
          'reserva',
          reserva._id
        ),
      'No se pudo notificar al usuario'
    );

    res.status(201).json({
      mensaje:
        'Solicitud enviada. El establecimiento la revisará ' +
        'y te responderá.',
      reserva
    });

  } catch (error) {
    errorInterno(
      res,
      'Error al crear reserva:',
      error,
      'No se pudo registrar la solicitud de reserva.'
    );
  }
};


// =====================================================
// ACTUALIZAR UNA SOLICITUD PENDIENTE
//
// Solo se pueden cambiar fecha, cantidad y observaciones,
// y solo mientras la solicitud sigue pendiente. La
// actividad, el sitio y el precio no se pueden modificar.
// =====================================================

const actualizarReserva = async (req, res) => {
  try {
    const id = req.params.id;

    if (!esId(id)) {
      return res.status(404).json({
        mensaje: 'Reserva no encontrada o no pertenece al usuario'
      });
    }

    const actual = await Reserva.findOne({
      _id: id,
      usuario: req.usuario.id
    });

    if (!actual) {
      return res.status(404).json({
        mensaje: 'Reserva no encontrada o no pertenece al usuario'
      });
    }

    if (actual.estado !== 'pendiente') {
      return res.status(409).json({
        mensaje:
          'Solo se puede modificar una solicitud pendiente.'
      });
    }

    const body = cuerpoDe(req);
    const cambios = {};

    if (body.fecha !== undefined) {
      const resultado = leerFecha(body.fecha);

      if (resultado.error) {
        return res.status(400).json({ mensaje: resultado.error });
      }

      cambios.fecha = resultado.fecha;
    }

    if (body.cantidadPersonas !== undefined) {
      const resultado = leerCantidad(body.cantidadPersonas);

      if (resultado.error) {
        return res.status(400).json({ mensaje: resultado.error });
      }

      cambios.cantidadPersonas = resultado.cantidad;
      cambios.precioTotal = redondear(
        (actual.precioUnitario || 0) * resultado.cantidad
      );
    }

    if (body.observaciones !== undefined) {
      const resultado = leerObservaciones(body.observaciones);

      if (resultado.error) {
        return res.status(400).json({ mensaje: resultado.error });
      }

      cambios.observaciones = resultado.observaciones;
    }

    if (Object.keys(cambios).length === 0) {
      return res.status(400).json({
        mensaje: 'No hay cambios para guardar.'
      });
    }

    const reserva = await Reserva.findOneAndUpdate(
      {
        _id: id,
        usuario: req.usuario.id,
        estado: 'pendiente'
      },
      cambios,
      {
        returnDocument: 'after',
        runValidators: true
      }
    );

    if (!reserva) {
      return res.status(409).json({
        mensaje:
          'La solicitud cambió de estado y ya no se puede modificar.'
      });
    }

    res.status(200).json({
      mensaje: 'Solicitud actualizada correctamente',
      reserva
    });

  } catch (error) {
    errorInterno(
      res,
      'Error al actualizar reserva:',
      error,
      'No se pudo actualizar la solicitud.'
    );
  }
};


// =====================================================
// CANCELAR RESERVA
//
// Solo desde pendiente o confirmada.
// =====================================================

const cancelarReserva = async (req, res) => {
  try {
    const id = req.params.id;

    if (!esId(id)) {
      return res.status(404).json({
        mensaje: 'Reserva no encontrada o no pertenece al usuario'
      });
    }

    const reserva = await Reserva.findOneAndUpdate(
      {
        _id: id,

        // SOLO PUEDE CANCELAR SUS RESERVAS
        usuario: req.usuario.id,

        estado: { $in: ESTADOS_CANCELABLES }
      },
      {
        estado: 'cancelada'
      },
      {
        returnDocument: 'after',
        runValidators: true
      }
    );

    if (!reserva) {
      const existente = await Reserva.findOne({
        _id: id,
        usuario: req.usuario.id
      });

      if (!existente) {
        return res.status(404).json({
          mensaje: 'Reserva no encontrada o no pertenece al usuario'
        });
      }

      return res.status(409).json({
        mensaje:
          `No se puede cancelar una reserva ${existente.estado}.`
      });
    }

    await avisar(
      () =>
        crearNotificacionSitio(
          reserva.sitio,
          'Reserva cancelada por el visitante',
          `${reserva.actividadNombre || 'Una actividad'}: ` +
            `el visitante canceló su reserva del ` +
            `${formatearFecha(reserva.fecha)}.`,
          'reserva_cancelada',
          reserva._id
        ),
      'No se pudo notificar la cancelación al establecimiento'
    );

    res.status(200).json({
      mensaje: 'Reserva cancelada correctamente',
      reserva
    });

  } catch (error) {
    errorInterno(
      res,
      'Error al cancelar reserva:',
      error,
      'No se pudo cancelar la reserva.'
    );
  }
};


// =====================================================
// EXPORTAR
// =====================================================

module.exports = {
  obtenerReservas,
  crearReserva,
  actualizarReserva,
  cancelarReserva
};
