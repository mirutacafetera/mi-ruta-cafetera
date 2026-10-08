const SitioTuristico = require('../../models/admin/sitio');

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

  return Number.isNaN(numero)
    ? undefined
    : numero;
};

// ============================================================
// CONVERTIR A BOOLEANO
// ============================================================

const convertirBooleano = (valor) => {
  if (
    valor === undefined ||
    valor === null
  ) {
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
  if (
    valor === undefined ||
    valor === null
  ) {
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

    // ========================================================
    // IMAGEN PRINCIPAL
    // ========================================================

    if (!req.file) {
      return res.status(400).json({
        mensaje: 'La imagen principal es obligatoria.'
      });
    }

    const imagenPrincipal = req.file.path;

    // ========================================================
    // CREAR SITIO
    // ========================================================

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

      // CORREGIDO:
      // El modelo espera STRING
      correos: convertirString(correos),

      sitioWeb,

      // Imagen principal de Cloudinary
      imagen: imagenPrincipal,

      // No manejamos imágenes adicionales
      imagenes: [],

      horario,

      precioDesde: convertirNumero(precioDesde)
    });

    await sitio.save();

    // ========================================================
    // RESPUESTA
    // ========================================================

    res.status(201).json({
      mensaje: 'Sitio turístico creado correctamente',
      sitio
    });
  } catch (error) {
    console.error(
      'Error al crear sitio turístico:',
      error
    );

    res.status(500).json({
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

    res.status(200).json(sitios);
  } catch (error) {
    console.error(
      'Error al obtener sitios turísticos:',
      error
    );

    res.status(500).json({
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
    const sitio =
      await SitioTuristico.findById(
        req.params.id
      ).populate('categoria');

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.status(200).json(sitio);
  } catch (error) {
    console.error(
      'Error al obtener sitio turístico:',
      error
    );

    res.status(500).json({
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
    const sitio =
      await SitioTuristico.findById(
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

    // ========================================================
    // DATOS BÁSICOS
    // ========================================================

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

    // ========================================================
    // UBICACIÓN
    // ========================================================

    if (latitud !== undefined) {
      sitio.latitud =
        convertirNumero(latitud);
    }

    if (longitud !== undefined) {
      sitio.longitud =
        convertirNumero(longitud);
    }

    // ========================================================
    // CATEGORÍA
    // ========================================================

    if (categoria !== undefined) {
      sitio.categoria = categoria;
    }

    // ========================================================
    // ETIQUETAS
    // ========================================================

    if (etiquetas !== undefined) {
      sitio.etiquetas =
        convertirArray(etiquetas);
    }

    // ========================================================
    // ESTADO
    // ========================================================

    if (activo !== undefined) {
      sitio.activo =
        convertirBooleano(activo);
    }

    // ========================================================
    // CONTACTO
    // ========================================================

    if (telefono !== undefined) {
      sitio.telefono = telefono;
    }

    if (correos !== undefined) {
      // CORREGIDO:
      // El modelo espera STRING
      sitio.correos =
        convertirString(correos);
    }

    if (sitioWeb !== undefined) {
      sitio.sitioWeb = sitioWeb;
    }

    // ========================================================
    // INFORMACIÓN TURÍSTICA
    // ========================================================

    if (horario !== undefined) {
      sitio.horario = horario;
    }

    if (precioDesde !== undefined) {
      sitio.precioDesde =
        convertirNumero(precioDesde);
    }

    // ========================================================
    // NUEVA IMAGEN PRINCIPAL
    // ========================================================

    if (req.file) {
      sitio.imagen = req.file.path;
    }

    // ========================================================
    // GUARDAR CAMBIOS
    // ========================================================

    await sitio.save();

    res.status(200).json({
      mensaje:
        'Sitio turístico actualizado correctamente',
      sitio
    });
  } catch (error) {
    console.error(
      'Error al actualizar sitio turístico:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al actualizar el sitio turístico',
      error: error.message
    });
  }
};

// ============================================================
// ELIMINAR SITIO TURÍSTICO
// ============================================================

const eliminarSitio = async (req, res) => {
  try {
    const sitio =
      await SitioTuristico.findByIdAndDelete(
        req.params.id
      );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje:
        'Sitio turístico eliminado correctamente'
    });
  } catch (error) {
    console.error(
      'Error al eliminar sitio turístico:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al eliminar el sitio turístico',
      error: error.message
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
  eliminarSitio
};