// ======================================================
// ADMINISTRACIÓN DE RUTAS TURÍSTICAS PREDEFINIDAS
// ======================================================
//
// Solo administradores (ver routes/admin/rutasPredefinidas.routes.js).
// No hay eliminación física: una ruta se oculta con activa=false,
// lo que es reversible.
// ======================================================

const mongoose = require('mongoose');
const Ruta = require('../../models/usuario/ruta');
const SitioTuristico = require('../../models/admin/sitio');
const { validarParadas } = require('../../utils/rutaParadas');

const obtenerSitios = (ids) =>
  SitioTuristico.find({ _id: { $in: ids } })
    .select('_id nombre latitud longitud activo')
    .lean();

const errorInterno = (res, accion, error) => {
  console.error(`Error al ${accion} ruta predefinida:`, error);
  return res.status(500).json({
    ok: false,
    mensaje: `Error al ${accion} la ruta predefinida.`
  });
};

const listarPredefinidas = async (req, res) => {
  try {
    const rutas = await Ruta.find({ tipo: 'predefinida' })
      .populate('paradas.sitio')
      .sort({ nombre: 1 });
    return res.status(200).json({ ok: true, rutas });
  } catch (error) {
    return errorInterno(res, 'listar', error);
  }
};

const crearPredefinida = async (req, res) => {
  try {
    const { nombre, descripcion, paradas, tipoExperiencia } = req.body || {};

    if (typeof nombre !== 'string' || nombre.trim().length === 0) {
      return res.status(400).json({
        ok: false,
        mensaje: 'El nombre de la ruta es obligatorio.'
      });
    }

    const validacion = await validarParadas(paradas, obtenerSitios);
    if (!validacion.ok) {
      return res.status(400).json({ ok: false, mensaje: validacion.mensaje });
    }

    const existente = await Ruta.findOne({
      tipo: 'predefinida',
      nombre: nombre.trim()
    }).select('_id');
    if (existente) {
      return res.status(409).json({
        ok: false,
        mensaje: 'Ya existe una ruta predefinida con ese nombre.'
      });
    }

    const ruta = new Ruta({
      usuario: null,
      nombre: nombre.trim(),
      descripcion: typeof descripcion === 'string' ? descripcion.trim() : '',
      tipoExperiencia:
        typeof tipoExperiencia === 'string' ? tipoExperiencia.trim() : '',
      paradas: validacion.paradas,
      sitios: validacion.sitios,
      duracionPlanificadaMin: validacion.duracionPlanificadaMin,
      tipo: 'predefinida',
      activa: true,
      expiraEn: null
    });
    await ruta.save();
    await ruta.populate('paradas.sitio');

    return res.status(201).json({
      ok: true,
      mensaje: 'Ruta predefinida creada correctamente.',
      ruta
    });
  } catch (error) {
    return errorInterno(res, 'crear', error);
  }
};

const actualizarPredefinida = async (req, res) => {
  try {
    const { id } = req.params;
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        ok: false,
        mensaje: 'El ID de la ruta no es válido.'
      });
    }

    const ruta = await Ruta.findById(id);
    if (!ruta || ruta.tipo !== 'predefinida') {
      return res.status(404).json({
        ok: false,
        mensaje: 'Ruta predefinida no encontrada.'
      });
    }

    const body = req.body || {};

    if (body.nombre !== undefined) {
      if (typeof body.nombre !== 'string' || body.nombre.trim().length === 0) {
        return res.status(400).json({
          ok: false,
          mensaje: 'El nombre de la ruta es obligatorio.'
        });
      }
      ruta.nombre = body.nombre.trim();
    }
    if (body.descripcion !== undefined) {
      if (typeof body.descripcion !== 'string') {
        return res.status(400).json({
          ok: false,
          mensaje: 'La descripción debe ser texto.'
        });
      }
      ruta.descripcion = body.descripcion.trim();
    }
    if (body.tipoExperiencia !== undefined) {
      if (typeof body.tipoExperiencia !== 'string') {
        return res.status(400).json({
          ok: false,
          mensaje: 'tipoExperiencia debe ser texto.'
        });
      }
      ruta.tipoExperiencia = body.tipoExperiencia.trim();
    }
    if (body.activa !== undefined) {
      if (typeof body.activa !== 'boolean') {
        return res.status(400).json({
          ok: false,
          mensaje: 'El campo activa debe ser verdadero o falso.'
        });
      }
      ruta.activa = body.activa;
    }
    if (body.paradas !== undefined) {
      const validacion = await validarParadas(body.paradas, obtenerSitios);
      if (!validacion.ok) {
        return res.status(400).json({ ok: false, mensaje: validacion.mensaje });
      }
      ruta.paradas = validacion.paradas;
      ruta.sitios = validacion.sitios;
      ruta.duracionPlanificadaMin = validacion.duracionPlanificadaMin;
    }

    await ruta.save();
    await ruta.populate('paradas.sitio');

    return res.status(200).json({
      ok: true,
      mensaje: 'Ruta predefinida actualizada correctamente.',
      ruta
    });
  } catch (error) {
    return errorInterno(res, 'actualizar', error);
  }
};

module.exports = {
  listarPredefinidas,
  crearPredefinida,
  actualizarPredefinida
};
