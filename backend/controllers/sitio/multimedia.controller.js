
const mongoose = require('mongoose');

const SitioTuristico = require('../../models/admin/sitio');
const Actividad = require('../../models/sitio/actividad');
const Contenido = require('../../models/sitio/contenido');
const Producto = require('../../models/sitio/producto');

// ======================================================
// OBTENER TODAS LAS IMÁGENES DEL SITIO
// Incluye sitio, actividades, historias y productos.
// ======================================================

const obtenerMultimedia = async (req, res) => {
  try {
    const sitioId = String(req.params.id || '');
    const sitioSesion = String(req.usuario?.sitioId || '');

    if (!mongoose.Types.ObjectId.isValid(sitioId)) {
      return res.status(400).json({
        mensaje: 'El ID del sitio no es válido.',
      });
    }

    // La galería es privada para la cuenta propietaria.
    if (!sitioSesion || sitioSesion !== sitioId) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para consultar esta galería.',
      });
    }

    const sitio = await SitioTuristico.findById(sitioId)
      .select('_id nombre imagen imagenes')
      .lean();

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'El sitio turístico no existe.',
      });
    }

    // Consultamos todos los registros del propietario,
    // independientemente de su estado de publicación.
    const [actividades, contenidos, productos] =
      await Promise.all([
        Actividad.find({ sitio: sitioId })
          .select('_id nombre imagenPrincipal imagenes')
          .lean(),

        // lean() permite recuperar también campos antiguos,
        // como tipo y url, si existen en documentos previos.
        Contenido.find({ sitio: sitioId }).lean(),

        Producto.find({ sitio: sitioId })
          .select(
            '_id nombre imagenPrincipal imagenes'
          )
          .lean(),
      ]);

    const imagenes = [];
    const urlsRegistradas = new Set();

    const agregarImagen = ({
      url,
      titulo,
      descripcion = '',
      origen,
      origenId,
    }) => {
      if (typeof url !== 'string') return;

      const urlLimpia = url.trim();

      if (!urlLimpia || urlsRegistradas.has(urlLimpia)) {
        return;
      }

      // Solo fotografías accesibles por URL.
      if (!/^https?:\/\//i.test(urlLimpia)) {
        return;
      }

      urlsRegistradas.add(urlLimpia);

      imagenes.push({
        id: `${origenId || sitioId}_${imagenes.length}`,
        tipo: 'imagen',
        titulo: titulo || 'Fotografía',
        descripcion: descripcion || '',
        url: urlLimpia,
        idioma: 'es',
        activo: true,
        origen,
        origenId: String(origenId || sitioId),
      });
    };

    // --------------------------------------------------
    // 1. FOTOGRAFÍAS GENERALES DEL SITIO
    // --------------------------------------------------

    agregarImagen({
      url: sitio.imagen,
      titulo: `${sitio.nombre} · Imagen principal`,
      origen: 'Sitio turístico',
      origenId: sitio._id,
    });

    for (const url of sitio.imagenes || []) {
      agregarImagen({
        url,
        titulo: `${sitio.nombre} · Galería del sitio`,
        origen: 'Sitio turístico',
        origenId: sitio._id,
      });
    }

    // --------------------------------------------------
    // 2. ACTIVIDADES
    // --------------------------------------------------

    for (const actividad of actividades) {
      agregarImagen({
        url: actividad.imagenPrincipal,
        titulo: `${actividad.nombre} · Imagen principal`,
        origen: 'Actividad',
        origenId: actividad._id,
      });

      for (const url of actividad.imagenes || []) {
        agregarImagen({
          url,
          titulo: actividad.nombre,
          origen: 'Actividad',
          origenId: actividad._id,
        });
      }
    }

    // --------------------------------------------------
    // 3. HISTORIAS Y CONTENIDO
    // --------------------------------------------------

    for (const contenido of contenidos) {
      agregarImagen({
        url: contenido.imagenPrincipal,
        titulo: contenido.titulo,
        descripcion: contenido.descripcion,
        origen: 'Historia y contenido',
        origenId: contenido._id,
      });

      for (const url of contenido.imagenes || []) {
        agregarImagen({
          url,
          titulo: contenido.titulo,
          descripcion: contenido.descripcion,
          origen: 'Historia y contenido',
          origenId: contenido._id,
        });
      }

      // Compatibilidad con documentos multimedia antiguos
      // que guardaban una imagen mediante tipo y url.
      if (
        contenido.tipo === 'imagen' &&
        contenido.url
      ) {
        agregarImagen({
          url: contenido.url,
          titulo: contenido.titulo,
          descripcion: contenido.descripcion,
          origen: 'Multimedia',
          origenId: contenido._id,
        });
      }
    }

    // --------------------------------------------------
    // 4. PRODUCTOS TURÍSTICOS
    // --------------------------------------------------

    for (const producto of productos) {
      agregarImagen({
        url: producto.imagenPrincipal,
        titulo: `${producto.nombre} · Imagen principal`,
        origen: 'Producto',
        origenId: producto._id,
      });

      for (const url of producto.imagenes || []) {
        agregarImagen({
          url,
          titulo: producto.nombre,
          origen: 'Producto',
          origenId: producto._id,
        });
      }
    }

    return res.status(200).json(imagenes);
  } catch (error) {
    console.error(
      'Error al obtener la galería completa:',
      error
    );

    return res.status(500).json({
      mensaje: 'No fue posible obtener la galería completa.',
    });
  }
};

// ======================================================
// SUBIR IMAGEN A LA GALERÍA GENERAL
// Se conserva el flujo actual.
// ======================================================

const subirImagen = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        mensaje: 'Debes seleccionar una imagen.',
      });
    }

    if (!req.usuario?.sitioId) {
      return res.status(403).json({
        mensaje: 'La cuenta no tiene un sitio turístico asociado.',
      });
    }

    const contenido = await Contenido.create({
      sitio: req.usuario.sitioId,
      tipo: 'imagen',
      titulo:
        req.body.titulo?.trim() ||
        req.file.originalname,
      descripcion: req.body.descripcion?.trim() || '',
      url: req.file.path,
      idioma: req.body.idioma?.trim() || 'es',
      activo: true,
    });

    return res.status(201).json({
      mensaje: 'Imagen subida correctamente.',
      multimedia: contenido,
    });
  } catch (error) {
    console.error('Error al subir imagen:', error);

    return res.status(500).json({
      mensaje: 'Error al subir la imagen.',
      error: error.message,
    });
  }
};

// ======================================================
// ACTUALIZAR MULTIMEDIA
// ======================================================

const actualizarMultimedia = async (req, res) => {
  try {
    const contenido = await Contenido.findOne({
      _id: req.params.id,
      sitio: req.usuario.sitioId,
    });

    if (!contenido) {
      return res.status(404).json({
        mensaje:
          'Contenido multimedia no encontrado o no pertenece a este sitio',
      });
    }

    contenido.titulo =
      req.body.titulo ?? contenido.titulo;

    contenido.descripcion =
      req.body.descripcion ?? contenido.descripcion;

    contenido.url =
      req.body.url ?? contenido.url;

    contenido.idioma =
      req.body.idioma ?? contenido.idioma;

    contenido.activo =
      req.body.activo ?? contenido.activo;

    await contenido.save();

    return res.status(200).json({
      mensaje: 'Multimedia actualizada correctamente.',
      multimedia: contenido,
    });
  } catch (error) {
    console.error('Error al actualizar multimedia:', error);

    return res.status(500).json({
      mensaje: 'Error al actualizar multimedia.',
      error: error.message,
    });
  }
};

module.exports = {
  obtenerMultimedia,
  subirImagen,
  actualizarMultimedia,
};