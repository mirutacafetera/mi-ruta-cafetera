const SitioTuristico = require('../../models/admin/sitio');
const CuentaSitio = require('../../models/sitio/auth');

// ============================================================
// CONVERTIR A NÚMERO
// ============================================================

const convertirNumero = (valor) => {
  if (
    valor === undefined ||
    valor === null ||
    valor === ''
  ) {
    return undefined;
  }

  const numero = Number(valor);

  return Number.isNaN(numero) ? undefined : numero;
};

// ============================================================
// CONVERTIR A BOOLEANO
// ============================================================

const convertirBooleano = (valor) => {
  if (valor === undefined || valor === null) {
    return undefined;
  }

  if (typeof valor === 'boolean') {
    return valor;
  }

  return valor === 'true';
};

// ============================================================
// CONVERTIR A ARRAY
// ============================================================

const convertirArray = (valor) => {
  if (
    valor === undefined ||
    valor === null ||
    valor === ''
  ) {
    return [];
  }

  if (Array.isArray(valor)) {
    return valor;
  }

  try {
    const convertido = JSON.parse(valor);

    return Array.isArray(convertido)
      ? convertido
      : [convertido];
  } catch {
    return valor
      .split(',')
      .map((item) => item.trim())
      .filter(Boolean);
  }
};

// ============================================================
// CONVERTIR A STRING
// ============================================================

const convertirString = (valor) => {
  if (valor === undefined || valor === null) {
    return '';
  }

  if (Array.isArray(valor)) {
    return valor
      .map((item) => item.toString().trim())
      .filter(Boolean)
      .join(', ');
  }

  return valor.toString().trim();
};

// ============================================================
// CREAR SITIO TURÍSTICO
// ============================================================

const crearSitio = async (req, res) => {
  try {
    const {
      nombre,
      descripcion,
      direccion,
      ciudad,
      departamento,
      latitud,
      longitud,
      categoria,
      etiquetas,
      activo,
      telefono,
      correos,
      sitioWeb,
      horario,
      precioDesde
    } = req.body;

    if (!req.file) {
      return res.status(400).json({
        mensaje: 'La imagen principal es obligatoria.'
      });
    }

    const imagenPrincipal = req.file.path;

    const sitio = new SitioTuristico({
      nombre,
      descripcion,
      direccion,
      ciudad,
      departamento,
      latitud: convertirNumero(latitud),
      longitud: convertirNumero(longitud),
      categoria,
      etiquetas: convertirArray(etiquetas),
      activo: convertirBooleano(activo),
      telefono,
      correos: convertirString(correos),
      sitioWeb,
      imagen: imagenPrincipal,
      imagenes: [],
      horario,
      precioDesde: convertirNumero(precioDesde)
    });

    await sitio.save();

    return res.status(201).json({
      mensaje: 'Sitio turístico creado correctamente',
      sitio
    });
  } catch (error) {
    console.error(
      'Error al crear sitio turístico:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al crear el sitio turístico',
      error: error.message
    });
  }
};

// ============================================================
// OBTENER TODOS LOS SITIOS
// ============================================================

const obtenerSitios = async (req, res) => {
  try {
    const sitios = await SitioTuristico.find()
      .populate('categoria')
      .sort({ nombre: 1 });

    return res.status(200).json(sitios);
  } catch (error) {
    console.error(
      'Error al obtener sitios turísticos:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al obtener los sitios turísticos',
      error: error.message
    });
  }
};

// ============================================================
// OBTENER UN SITIO
// ============================================================

const obtenerSitio = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findById(
      req.params.id
    ).populate('categoria');

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    return res.status(200).json(sitio);
  } catch (error) {
    console.error(
      'Error al obtener sitio turístico:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al obtener sitio turístico',
      error: error.message
    });
  }
};

// ============================================================
// ACTUALIZAR SITIO TURÍSTICO
// ============================================================

const actualizarSitio = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findById(
      req.params.id
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    const {
      nombre,
      descripcion,
      direccion,
      ciudad,
      departamento,
      latitud,
      longitud,
      categoria,
      etiquetas,
      activo,
      telefono,
      correos,
      sitioWeb,
      horario,
      precioDesde
    } = req.body;

    if (nombre !== undefined) {
      sitio.nombre = nombre;
    }

    if (descripcion !== undefined) {
      sitio.descripcion = descripcion;
    }

    if (direccion !== undefined) {
      sitio.direccion = direccion;
    }

    if (ciudad !== undefined) {
      sitio.ciudad = ciudad;
    }

    if (departamento !== undefined) {
      sitio.departamento = departamento;
    }

    if (latitud !== undefined) {
      sitio.latitud = convertirNumero(latitud);
    }

    if (longitud !== undefined) {
      sitio.longitud = convertirNumero(longitud);
    }

    if (categoria !== undefined) {
      sitio.categoria = categoria;
    }

    if (etiquetas !== undefined) {
      sitio.etiquetas = convertirArray(etiquetas);
    }

    if (activo !== undefined) {
      sitio.activo = convertirBooleano(activo);
    }

    if (telefono !== undefined) {
      sitio.telefono = telefono;
    }

    if (correos !== undefined) {
      sitio.correos = convertirString(correos);
    }

    if (sitioWeb !== undefined) {
      sitio.sitioWeb = sitioWeb;
    }

    if (horario !== undefined) {
      sitio.horario = horario;
    }

    if (precioDesde !== undefined) {
      sitio.precioDesde = convertirNumero(precioDesde);
    }

    if (req.file) {
      sitio.imagen = req.file.path;
    }

    await sitio.save();

    return res.status(200).json({
      mensaje: 'Sitio turístico actualizado correctamente',
      sitio
    });
  } catch (error) {
    console.error(
      'Error al actualizar sitio turístico:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al actualizar el sitio turístico',
      error: error.message
    });
  }
};

// ============================================================
// ELIMINAR SITIO TURÍSTICO Y SU CUENTA ASOCIADA
// ============================================================

const eliminarSitio = async (req, res) => {
  try {
    const { id } = req.params;

    const sitio = await SitioTuristico.findById(id);

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    const resultadoCuenta = await CuentaSitio.deleteMany({
      sitioId: sitio._id
    });

    await SitioTuristico.findByIdAndDelete(sitio._id);

    return res.status(200).json({
      mensaje:
        'Sitio turístico y su cuenta asociada eliminados correctamente',
      sitioId: sitio._id.toString(),
      cuentasEliminadas: resultadoCuenta.deletedCount
    });
  } catch (error) {
    console.error(
      'Error al eliminar sitio turístico y su cuenta:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al eliminar el sitio turístico y su cuenta',
      error: error.message
    });
  }
};

// ============================================================
// OBTENER TODAS LAS CUENTAS DE SITIOS
// ============================================================

const obtenerCuentas = async (req, res) => {
  try {
    const cuentas = await CuentaSitio.find()
      .select('-password')
      .sort({ nombre: 1 })
      .lean();

    return res.status(200).json({
      cuentas: cuentas.map((cuenta) => ({
        id: cuenta._id.toString(),
        sitioId: cuenta.sitioId.toString(),
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono || '',
        activo: cuenta.activo
      }))
    });
  } catch (error) {
    console.error(
      'Error al obtener las cuentas de sitios:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al consultar las cuentas de sitios.'
    });
  }
};

// ============================================================
// ACTUALIZAR CUENTA DE SITIO
// ============================================================

const actualizarCuenta = async (req, res) => {
  try {
    const { cuentaId } = req.params;
    const { nombre, apellido, correo, telefono } = req.body;

    if (
      typeof nombre !== 'string' ||
      !nombre.trim() ||
      typeof apellido !== 'string' ||
      !apellido.trim() ||
      typeof correo !== 'string' ||
      !correo.trim()
    ) {
      return res.status(400).json({
        mensaje: 'Nombre, apellido y correo son obligatorios.'
      });
    }

    const cuenta = await CuentaSitio.findById(cuentaId);

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta de sitio no encontrada.'
      });
    }

    const correoNormalizado = correo.trim().toLowerCase();

    const correoExistente = await CuentaSitio.findOne({
      correo: correoNormalizado,
      _id: { $ne: cuenta._id }
    });

    if (correoExistente) {
      return res.status(409).json({
        mensaje: 'El correo ya está registrado en otra cuenta.'
      });
    }

    cuenta.nombre = nombre.trim();
    cuenta.apellido = apellido.trim();
    cuenta.correo = correoNormalizado;
    cuenta.telefono =
      typeof telefono === 'string' ? telefono.trim() : '';

    await cuenta.save();

    return res.status(200).json({
      mensaje: 'Cuenta actualizada correctamente.',
      cuenta: {
        id: cuenta._id.toString(),
        sitioId: cuenta.sitioId.toString(),
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono || '',
        activo: cuenta.activo
      }
    });
  } catch (error) {
    console.error(
      'Error al actualizar la cuenta:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al actualizar la cuenta.'
    });
  }
};

// ============================================================
// CAMBIAR ESTADO DE CUENTA
// ============================================================

const cambiarEstadoCuenta = async (req, res) => {
  try {
    const { cuentaId } = req.params;
    const { activo } = req.body;

    if (typeof activo !== 'boolean') {
      return res.status(400).json({
        mensaje: 'El estado debe ser verdadero o falso.'
      });
    }

    const cuenta = await CuentaSitio.findById(cuentaId);

    if (!cuenta) {
      return res.status(404).json({
        mensaje: 'Cuenta de sitio no encontrada.'
      });
    }

    cuenta.activo = activo;

    await cuenta.save();

    return res.status(200).json({
      mensaje: 'Estado de la cuenta actualizado correctamente.',
      cuenta: {
        id: cuenta._id.toString(),
        sitioId: cuenta.sitioId.toString(),
        nombre: cuenta.nombre,
        apellido: cuenta.apellido,
        correo: cuenta.correo,
        telefono: cuenta.telefono || '',
        activo: cuenta.activo
      }
    });
  } catch (error) {
    console.error(
      'Error al cambiar el estado de la cuenta:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al cambiar el estado de la cuenta.'
    });
  }
};

// ============================================================
// EXPORTAR CONTROLADORES
// ============================================================

module.exports = {
  crearSitio,
  obtenerSitios,
  obtenerSitio,
  actualizarSitio,
  eliminarSitio,
  obtenerCuentas,
  actualizarCuenta,
  cambiarEstadoCuenta
};