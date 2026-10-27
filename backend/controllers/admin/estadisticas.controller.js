const Estadistica = require('../../models/admin/estadistica');
const Usuario = require('../../models/usuario/usuario');
const Resena = require('../../models/sitio/resena');
const Reserva = require('../../models/sitio/reserva');
const Ayuda = require('../../models/usuario/ayuda');

const MESES = [
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Agosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre',
];

const obtenerAnio = (valor) => {
  const anio = Number(valor);

  if (
    valor !== undefined &&
    (!Number.isInteger(anio) || anio < 2000 || anio > 2100)
  ) {
    throw new Error('El año consultado no es válido.');
  }

  if (valor !== undefined) return anio;

  return Number(
    new Intl.DateTimeFormat('en', {
      timeZone: 'America/Bogota',
      year: 'numeric',
    }).format(new Date()),
  );
};

const obtenerConteoMensual = async (Modelo, anio) => {
  // Límites del año en hora de Colombia (UTC-5).
  const inicio = new Date(Date.UTC(anio, 0, 1, 5));
  const fin = new Date(Date.UTC(anio + 1, 0, 1, 5));

  const resultados = await Modelo.aggregate([
    {
      $match: {
        createdAt: {
          $gte: inicio,
          $lt: fin,
        },
      },
    },
    {
      $group: {
        _id: {
          $month: {
            date: '$createdAt',
            timezone: 'America/Bogota',
          },
        },
        cantidad: { $sum: 1 },
      },
    },
  ]);

  const conteos = Array(12).fill(0);

  resultados.forEach((resultado) => {
    conteos[resultado._id - 1] = resultado.cantidad;
  });

  return conteos;
};

const obtenerEstadisticas = async (req, res) => {
  try {
    const anio = obtenerAnio(req.query.anio);

    const [
      usuarios,
      resenas,
      reservas,
      reportes,
      reportesPendientes,
      reportesEnRevision,
      reportesResueltos,
      usuariosMensuales,
      resenasMensuales,
      reservasMensuales,
      reportesMensuales,
    ] = await Promise.all([
      Usuario.countDocuments(),
      Resena.countDocuments(),
      Reserva.countDocuments(),
      Ayuda.countDocuments(),
      Ayuda.countDocuments({ estado: 'pendiente' }),
      Ayuda.countDocuments({ estado: 'en_revision' }),
      Ayuda.countDocuments({ estado: 'resuelto' }),

      obtenerConteoMensual(Usuario, anio),
      obtenerConteoMensual(Resena, anio),
      obtenerConteoMensual(Reserva, anio),
      obtenerConteoMensual(Ayuda, anio),
    ]);

    const mensuales = MESES.map((nombre, indice) => ({
      mes: indice + 1,
      nombre,
      usuarios: usuariosMensuales[indice],
      resenas: resenasMensuales[indice],
      reservas: reservasMensuales[indice],
      reportes: reportesMensuales[indice],
    }));

    res.json({
      usuarios,
      resenas,
      reservas,
      reportes,
      reportesPendientes,
      reportesEnRevision,
      reportesResueltos,
      anio,
      mensuales,
    });
  } catch (error) {
    res.status(error.message.includes('no es válido') ? 400 : 500).json({
      mensaje: 'Error al obtener estadísticas',
      error: error.message,
    });
  }
};

const obtenerEstadisticasGuardadas = async (req, res) => {
  try {
    const estadisticas = await Estadistica.find().sort({ fecha: -1 });
    res.json(estadisticas);
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener estadísticas guardadas',
      error: error.message,
    });
  }
};

const crearEstadistica = async (req, res) => {
  try {
    const estadistica = new Estadistica(req.body);
    await estadistica.save();

    res.status(201).json({
      mensaje: 'Estadística registrada correctamente',
      estadistica,
    });
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al registrar estadística',
      error: error.message,
    });
  }
};

module.exports = {
  obtenerEstadisticas,
  obtenerEstadisticasGuardadas,
  crearEstadistica,
};