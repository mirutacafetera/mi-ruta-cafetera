const mongoose = require('mongoose');

const Ruta = require('../../models/usuario/ruta');
const SitioTuristico = require('../../models/admin/sitio');

// ============================================================
// OBTENER RUTAS DE UN USUARIO
// ============================================================

const obtenerRutas = async (req, res) => {
  try {
    const { usuarioId } = req.params;

    // --------------------------------------------------------
    // VALIDAR ID DEL USUARIO
    // --------------------------------------------------------

    if (!mongoose.Types.ObjectId.isValid(usuarioId)) {
      return res.status(400).json({
        ok: false,
        mensaje: 'El ID del usuario no es válido.'
      });
    }

    // --------------------------------------------------------
    // VALIDAR PROPIETARIO
    // --------------------------------------------------------

    if (
      !req.usuario ||
      !req.usuario.id ||
      req.usuario.id !== usuarioId
    ) {
      return res.status(403).json({
        ok: false,
        mensaje:
          'No tienes permiso para consultar las rutas de este usuario.'
      });
    }

    const ahora = new Date();

    // --------------------------------------------------------
    // OBTENER RUTAS
    // --------------------------------------------------------

    const rutas = await Ruta.find({
      $or: [
        {
          usuario: usuarioId,
          tipo: 'personalizada',
          activa: true,
          $or: [
            { expiraEn: null },
            { expiraEn: { $gt: ahora } }
          ]
        },
        {
          tipo: 'predefinida',
          activa: true
        }
      ]
    })
      .populate('sitios')
      .sort({
        tipo: 1,
        nombre: 1
      });

    return res.status(200).json({
      ok: true,
      rutas
    });
  } catch (error) {
    console.error(
      'Error al obtener rutas:',
      error
    );

    return res.status(500).json({
      ok: false,
      mensaje: 'Error al obtener rutas.',
      error: error.message
    });
  }
};

// ============================================================
// OBTENER RUTAS PREDEFINIDAS
// ============================================================
//
// Endpoint público:
//
// GET /api/rutas/predefinidas
//
// Devuelve únicamente rutas:
// - tipo: predefinida
// - activa: true
//
// Las rutas predefinidas no pertenecen a ningún usuario
// y son permanentes.
// ============================================================

const obtenerRutasPredefinidas = async (req, res) => {
  try {
    const rutas = await Ruta.find({
      tipo: 'predefinida',
      activa: true
    })
      .populate('sitios')
      .sort({
        nombre: 1
      });

    return res.status(200).json({
      ok: true,
      rutas
    });
  } catch (error) {
    console.error(
      'Error al obtener rutas predefinidas:',
      error
    );

    return res.status(500).json({
      ok: false,
      mensaje: 'Error al obtener rutas predefinidas.',
      error: error.message
    });
  }
};

// ============================================================
// CREAR RUTA
// ============================================================

const crearRuta = async (req, res) => {
  try {
    const {
      nombre,
      descripcion,
      sitios,
      tipo = 'personalizada',
      activa = true
    } = req.body;

    // El usuario nunca se toma del body.
    // Para rutas personalizadas se obtiene del token.
    let usuario = null;

    // --------------------------------------------------------
    // VALIDAR TIPO
    // --------------------------------------------------------

    if (
      !['personalizada', 'predefinida'].includes(tipo)
    ) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'El tipo de ruta debe ser personalizada o predefinida.'
      });
    }

    // --------------------------------------------------------
    // VALIDAR NOMBRE
    // --------------------------------------------------------

    if (
      typeof nombre !== 'string' ||
      nombre.trim().length === 0
    ) {
      return res.status(400).json({
        ok: false,
        mensaje: 'El nombre de la ruta es obligatorio.'
      });
    }

    // --------------------------------------------------------
    // VALIDAR SITIOS
    // --------------------------------------------------------

    if (!Array.isArray(sitios)) {
      return res.status(400).json({
        ok: false,
        mensaje: 'El campo sitios debe ser un arreglo.'
      });
    }

    if (sitios.length === 0) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'La ruta debe contener al menos un sitio.'
      });
    }

    if (sitios.length > 4) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'Una ruta no puede contener más de 4 sitios.'
      });
    }

    // --------------------------------------------------------
    // VALIDAR IDS DE SITIOS
    // --------------------------------------------------------

    const idsInvalidos = sitios.filter(
      (id) => !mongoose.Types.ObjectId.isValid(id)
    );

    if (idsInvalidos.length > 0) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'Uno o más IDs de sitios turísticos no son válidos.'
      });
    }

    // --------------------------------------------------------
    // EVITAR SITIOS DUPLICADOS
    // --------------------------------------------------------

    const sitiosUnicos = [
      ...new Set(
        sitios.map(
          (id) => id.toString()
        )
      )
    ];

    if (sitiosUnicos.length !== sitios.length) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'La ruta no puede contener sitios repetidos.'
      });
    }

    // --------------------------------------------------------
    // COMPROBAR QUE LOS SITIOS EXISTAN
    // --------------------------------------------------------

    const sitiosExistentes =
      await SitioTuristico.find({
        _id: {
          $in: sitiosUnicos
        }
      }).select('_id');

    if (
      sitiosExistentes.length !==
      sitiosUnicos.length
    ) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'Uno o más sitios turísticos no existen en la base de datos.'
      });
    }

    // --------------------------------------------------------
    // RUTA PERSONALIZADA
    // --------------------------------------------------------

    if (tipo === 'personalizada') {
      // La ruta personalizada siempre pertenece
      // al usuario autenticado.
      if (
        !req.usuario ||
        !req.usuario.id
      ) {
        return res.status(401).json({
          ok: false,
          mensaje:
            'Debes iniciar sesión para crear una ruta personalizada.'
        });
      }

      usuario = req.usuario.id;

      if (
        !mongoose.Types.ObjectId.isValid(usuario)
      ) {
        return res.status(400).json({
          ok: false,
          mensaje:
            'El ID del usuario autenticado no es válido.'
        });
      }

      // ------------------------------------------------------
      // LIMITE DE 2 RUTAS PERSONALIZADAS
      // ------------------------------------------------------

      const ahora = new Date();

      const cantidadRutasPersonalizadas =
        await Ruta.countDocuments({
          usuario,
          tipo: 'personalizada',
          activa: true,
          $or: [
            { expiraEn: null },
            { expiraEn: { $gt: ahora } }
          ]
        });

      if (cantidadRutasPersonalizadas >= 2) {
        return res.status(400).json({
          ok: false,
          mensaje:
            'Has alcanzado el límite de 2 rutas personalizadas. ' +
            'Elimina una ruta o espera a que expire para crear otra.'
        });
      }
    }

    // --------------------------------------------------------
    // RUTA PREDEFINIDA
    // --------------------------------------------------------

    // Las rutas predefinidas no pertenecen a usuarios.
    if (tipo === 'predefinida') {
      usuario = null;
    }

    // --------------------------------------------------------
    // EXPIRACIÓN
    // --------------------------------------------------------

    const expiraEn =
      tipo === 'personalizada'
        ? new Date(
            Date.now() +
            24 * 60 * 60 * 1000
          )
        : null;

    // --------------------------------------------------------
    // CREAR DOCUMENTO
    // --------------------------------------------------------

    const ruta = new Ruta({
      usuario:
        tipo === 'personalizada'
          ? usuario
          : null,

      nombre:
        nombre.trim(),

      descripcion:
        typeof descripcion === 'string'
          ? descripcion.trim()
          : '',

      sitios:
        sitiosUnicos,

      tipo,

      activa,

      expiraEn
    });

    await ruta.save();

    await ruta.populate('sitios');

    return res.status(201).json({
      ok: true,
      mensaje:
        'Ruta creada correctamente.',
      ruta
    });
  } catch (error) {
    console.error(
      'Error al crear ruta:',
      error
    );

    return res.status(500).json({
      ok: false,
      mensaje:
        'Error al crear ruta.',
      error: error.message
    });
  }
};

// ============================================================
// ACTUALIZAR RUTA
// ============================================================

const actualizarRuta = async (req, res) => {
  try {
    const { id } = req.params;

    // --------------------------------------------------------
    // VALIDAR ID
    // --------------------------------------------------------

    if (
      !mongoose.Types.ObjectId.isValid(id)
    ) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'El ID de la ruta no es válido.'
      });
    }

    // --------------------------------------------------------
    // BUSCAR RUTA
    // --------------------------------------------------------

    const ruta =
      await Ruta.findById(id);

    if (!ruta) {
      return res.status(404).json({
        ok: false,
        mensaje:
          'Ruta no encontrada.'
      });
    }

    // --------------------------------------------------------
    // VALIDAR PROPIETARIO
    // --------------------------------------------------------

    if (
      !req.usuario ||
      !req.usuario.id ||
      !ruta.usuario ||
      ruta.usuario.toString() !== req.usuario.id
    ) {
      return res.status(403).json({
        ok: false,
        mensaje:
          'No tienes permiso para modificar esta ruta.'
      });
    }

    // --------------------------------------------------------
    // NO MODIFICAR RUTAS PREDEFINIDAS
    // --------------------------------------------------------

    if (
      ruta.tipo === 'predefinida'
    ) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'Las rutas predefinidas se administran como rutas permanentes.'
      });
    }

    // --------------------------------------------------------
    // SITIOS
    // --------------------------------------------------------

    if (
      req.body.sitios !== undefined
    ) {
      if (
        !Array.isArray(
          req.body.sitios
        )
      ) {
        return res.status(400).json({
          ok: false,
          mensaje:
            'El campo sitios debe ser un arreglo.'
        });
      }

      if (
        req.body.sitios.length === 0 ||
        req.body.sitios.length > 4
      ) {
        return res.status(400).json({
          ok: false,
          mensaje:
            'La ruta debe contener entre 1 y 4 sitios.'
        });
      }

      const idsInvalidos =
        req.body.sitios.filter(
          (sitioId) =>
            !mongoose.Types.ObjectId.isValid(
              sitioId
            )
        );

      if (
        idsInvalidos.length > 0
      ) {
        return res.status(400).json({
          ok: false,
          mensaje:
            'Uno o más IDs de sitios no son válidos.'
        });
      }

      const sitiosUnicos = [
        ...new Set(
          req.body.sitios.map(
            (sitioId) =>
              sitioId.toString()
          )
        )
      ];

      if (
        sitiosUnicos.length !==
        req.body.sitios.length
      ) {
        return res.status(400).json({
          ok: false,
          mensaje:
            'La ruta no puede contener sitios repetidos.'
        });
      }

      const cantidadExistente =
        await SitioTuristico.countDocuments({
          _id: {
            $in: sitiosUnicos
          }
        });

      if (
        cantidadExistente !==
        sitiosUnicos.length
      ) {
        return res.status(400).json({
          ok: false,
          mensaje:
            'Uno o más sitios turísticos no existen.'
        });
      }

      ruta.sitios =
        sitiosUnicos;
    }

    // --------------------------------------------------------
    // CAMPOS PERMITIDOS
    // --------------------------------------------------------

    if (
      req.body.nombre !== undefined
    ) {
      const nombre =
        String(
          req.body.nombre
        ).trim();

      if (nombre.length === 0) {
        return res.status(400).json({
          ok: false,
          mensaje:
            'El nombre de la ruta es obligatorio.'
        });
      }

      ruta.nombre = nombre;
    }

    if (
      req.body.descripcion !== undefined
    ) {
      ruta.descripcion =
        String(
          req.body.descripcion
        ).trim();
    }

    if (
      req.body.activa !== undefined
    ) {
      ruta.activa =
        Boolean(
          req.body.activa
        );
    }

    await ruta.save();

    await ruta.populate(
      'sitios'
    );

    return res.status(200).json({
      ok: true,
      mensaje:
        'Ruta actualizada correctamente.',
      ruta
    });
  } catch (error) {
    console.error(
      'Error al actualizar ruta:',
      error
    );

    return res.status(500).json({
      ok: false,
      mensaje:
        'Error al actualizar ruta.',
      error: error.message
    });
  }
};

// ============================================================
// ELIMINAR RUTA
// ============================================================

const eliminarRuta = async (req, res) => {
  try {
    const { id } = req.params;

    // --------------------------------------------------------
    // VALIDAR ID
    // --------------------------------------------------------

    if (
      !mongoose.Types.ObjectId.isValid(id)
    ) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'El ID de la ruta no es válido.'
      });
    }

    // --------------------------------------------------------
    // BUSCAR RUTA
    // --------------------------------------------------------

    const ruta =
      await Ruta.findById(id);

    if (!ruta) {
      return res.status(404).json({
        ok: false,
        mensaje:
          'Ruta no encontrada.'
      });
    }

    // --------------------------------------------------------
    // VALIDAR PROPIETARIO
    // --------------------------------------------------------

    if (
      !req.usuario ||
      !req.usuario.id ||
      !ruta.usuario ||
      ruta.usuario.toString() !== req.usuario.id
    ) {
      return res.status(403).json({
        ok: false,
        mensaje:
          'No tienes permiso para eliminar esta ruta.'
      });
    }

    // --------------------------------------------------------
    // NO ELIMINAR RUTAS PREDEFINIDAS
    // --------------------------------------------------------

    if (
      ruta.tipo === 'predefinida'
    ) {
      return res.status(400).json({
        ok: false,
        mensaje:
          'Las rutas predefinidas son permanentes y no se eliminan mediante este endpoint.'
      });
    }

    // --------------------------------------------------------
    // ELIMINAR
    // --------------------------------------------------------

    await Ruta.findByIdAndDelete(
      id
    );

    return res.status(200).json({
      ok: true,
      mensaje:
        'Ruta eliminada correctamente.'
    });
  } catch (error) {
    console.error(
      'Error al eliminar ruta:',
      error
    );

    return res.status(500).json({
      ok: false,
      mensaje:
        'Error al eliminar ruta.',
      error: error.message
    });
  }
};

// ============================================================
// EXPORTAR
// ============================================================

module.exports = {
  obtenerRutas,
  obtenerRutasPredefinidas,
  crearRuta,
  actualizarRuta,
  eliminarRuta
};