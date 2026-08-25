const mongoose = require('mongoose');

const SitioTuristico = require(
  '../../models/sitio/sitioturistico'
);

// ======================================================
// OBTENER TODOS LOS SITIOS TURÍSTICOS ACTIVOS
// ======================================================

const obtenerSitios = async (req, res) => {
  try {
    console.log(
      '📍 Consultando sitios turísticos activos...'
    );

    const sitios = await SitioTuristico
      .find({
        activo: true
      })
      .populate({
        path: 'categoria',
        match: {
          estado: true
        }
      })
      .sort({
        nombre: 1
      });

    // ==================================================
    // Eliminamos únicamente los sitios cuya categoría
    // no existe o está inactiva.
    // ==================================================

    const sitiosValidos = sitios.filter(
      (sitio) => sitio.categoria !== null
    );

    console.log(
      `📍 Sitios encontrados en MongoDB: ${sitios.length}`
    );

    console.log(
      `📍 Sitios enviados al frontend: ${sitiosValidos.length}`
    );

    res.status(200).json(
      sitiosValidos
    );

  } catch (error) {
    console.error(
      '❌ Error al obtener sitios turísticos:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al obtener sitios turísticos',

      error:
        error.message
    });
  }
};

// ======================================================
// OBTENER UN SITIO POR ID
// ======================================================

const obtenerSitio = async (req, res) => {
  try {
    const { id } = req.params;

    // --------------------------------------------------
    // Validar ObjectId
    // --------------------------------------------------

    if (
      !mongoose.Types.ObjectId.isValid(id)
    ) {
      return res.status(400).json({
        mensaje:
          'ID de sitio turístico no válido'
      });
    }

    // --------------------------------------------------
    // Buscar sitio
    // --------------------------------------------------

    const sitio = await SitioTuristico
      .findById(id)
      .populate('categoria');

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'Sitio turístico no encontrado'
      });
    }

    res.status(200).json(
      sitio
    );

  } catch (error) {
    console.error(
      '❌ Error al obtener sitio turístico:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al obtener sitio turístico',

      error:
        error.message
    });
  }
};

// ======================================================
// CREAR SITIO TURÍSTICO
// ======================================================

const crearSitio = async (req, res) => {
  try {
    // --------------------------------------------------
    // Permitir:
    //
    // POST con un solo sitio
    //
    // o
    //
    // POST con varios sitios
    // --------------------------------------------------

    const datos = Array.isArray(req.body)
      ? req.body
      : [req.body];

    // --------------------------------------------------
    // Normalizar activo
    //
    // Si no viene activo, será true.
    // --------------------------------------------------

    const datosNormalizados = datos.map(
      (item) => ({
        ...item,

        activo:
          typeof item.activo === 'boolean'
            ? item.activo
            : true
      })
    );

    // --------------------------------------------------
    // Crear sitios
    // --------------------------------------------------

    const resultado =
      await SitioTuristico.insertMany(
        datosNormalizados
      );

    // --------------------------------------------------
    // Obtener IDs creados
    // --------------------------------------------------

    const ids = resultado.map(
      (item) => item._id
    );

    // --------------------------------------------------
    // Volver a consultar con categoría poblada
    // --------------------------------------------------

    const sitiosCreados =
      await SitioTuristico
        .find({
          _id: {
            $in: ids
          }
        })
        .populate('categoria');

    console.log(
      `✅ Sitios creados: ${sitiosCreados.length}`
    );

    res.status(201).json({
      mensaje:
        'Sitio(s) turístico(s) creado(s) correctamente',

      sitios:
        sitiosCreados
    });

  } catch (error) {
    console.error(
      '❌ Error al crear sitio turístico:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al crear sitio turístico',

      error:
        error.message
    });
  }
};

// ======================================================
// ACTUALIZAR SITIO
// ======================================================

const actualizarSitio = async (req, res) => {
  try {
    const { id } = req.params;

    // --------------------------------------------------
    // Validar ID
    // --------------------------------------------------

    if (
      !mongoose.Types.ObjectId.isValid(id)
    ) {
      return res.status(400).json({
        mensaje:
          'ID de sitio turístico no válido'
      });
    }

    // --------------------------------------------------
    // Actualizar
    // --------------------------------------------------

    const sitio =
      await SitioTuristico.findByIdAndUpdate(
        id,
        req.body,
        {
          new: true,
          runValidators: true
        }
      )
      .populate('categoria');

    // --------------------------------------------------
    // Verificar existencia
    // --------------------------------------------------

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje:
        'Sitio turístico actualizado correctamente',

      sitio:
        sitio
    });

  } catch (error) {
    console.error(
      '❌ Error al actualizar sitio turístico:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al actualizar sitio turístico',

      error:
        error.message
    });
  }
};

// ======================================================
// DESACTIVAR SITIO
// ======================================================

const desactivarSitio = async (req, res) => {
  try {
    const { id } = req.params;

    // --------------------------------------------------
    // Validar ID
    // --------------------------------------------------

    if (
      !mongoose.Types.ObjectId.isValid(id)
    ) {
      return res.status(400).json({
        mensaje:
          'ID de sitio turístico no válido'
      });
    }

    // --------------------------------------------------
    // IMPORTANTE:
    // Utilizamos "activo", porque ese es el campo real
    // de MongoDB.
    // --------------------------------------------------

    const sitio =
      await SitioTuristico.findByIdAndUpdate(
        id,
        {
          activo: false
        },
        {
          new: true
        }
      );

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje:
        'Sitio turístico desactivado correctamente',

      sitio:
        sitio
    });

  } catch (error) {
    console.error(
      '❌ Error al desactivar sitio:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al desactivar sitio turístico',

      error:
        error.message
    });
  }
};

// ======================================================
// ACTIVAR SITIO
// ======================================================

const activarSitio = async (req, res) => {
  try {
    const { id } = req.params;

    // --------------------------------------------------
    // Validar ID
    // --------------------------------------------------

    if (
      !mongoose.Types.ObjectId.isValid(id)
    ) {
      return res.status(400).json({
        mensaje:
          'ID de sitio turístico no válido'
      });
    }

    // --------------------------------------------------
    // Activar
    // --------------------------------------------------

    const sitio =
      await SitioTuristico.findByIdAndUpdate(
        id,
        {
          activo: true
        },
        {
          new: true
        }
      );

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje:
        'Sitio turístico activado correctamente',

      sitio:
        sitio
    });

  } catch (error) {
    console.error(
      '❌ Error al activar sitio:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al activar sitio turístico',

      error:
        error.message
    });
  }
};

// ======================================================
// ELIMINAR SITIO
// ======================================================

const eliminarSitio = async (req, res) => {
  try {
    const { id } = req.params;

    // --------------------------------------------------
    // Validar ID
    // --------------------------------------------------

    if (
      !mongoose.Types.ObjectId.isValid(id)
    ) {
      return res.status(400).json({
        mensaje:
          'ID de sitio turístico no válido'
      });
    }

    // --------------------------------------------------
    // Eliminar
    // --------------------------------------------------

    const sitio =
      await SitioTuristico.findByIdAndDelete(
        id
      );

    if (!sitio) {
      return res.status(404).json({
        mensaje:
          'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje:
        'Sitio turístico eliminado correctamente'
    });

  } catch (error) {
    console.error(
      '❌ Error al eliminar sitio turístico:',
      error
    );

    res.status(500).json({
      mensaje:
        'Error al eliminar sitio turístico',

      error:
        error.message
    });
  }
};

// ======================================================
// EXPORTACIONES
// ======================================================

module.exports = {
  obtenerSitios,
  obtenerSitio,
  crearSitio,
  actualizarSitio,
  desactivarSitio,
  activarSitio,
  eliminarSitio
};