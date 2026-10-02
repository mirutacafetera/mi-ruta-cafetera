const mongoose = require('mongoose');

const SitioTuristico = require('../../models/admin/sitio');

// ======================================================
// OBTENER INFORMACIÓN DEL SITIO AUTENTICADO
// ======================================================

const obtenerInformacion = async (req, res) => {
  try {
    const sitioId = req.usuario.sitioId;

    if (!sitioId) {
      return res.status(400).json({
        mensaje: 'La cuenta no tiene un sitio asociado'
      });
    }

    if (!mongoose.Types.ObjectId.isValid(sitioId)) {
      return res.status(400).json({
        mensaje: 'El sitio asociado no es válido'
      });
    }

    const sitio = await SitioTuristico
      .findById(sitioId)
      .populate('categoria');

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    return res.status(200).json({
      sitio
    });

  } catch (error) {
    console.error(
      '❌ Error al obtener información del sitio:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al obtener la información del sitio',
      error: error.message
    });
  }
};


// ======================================================
// ACTUALIZAR INFORMACIÓN DEL SITIO AUTENTICADO
// ======================================================

const actualizarInformacion = async (req, res) => {
  try {
    const sitioId = req.usuario.sitioId;

    if (!sitioId) {
      return res.status(400).json({
        mensaje: 'La cuenta no tiene un sitio asociado'
      });
    }

    if (!mongoose.Types.ObjectId.isValid(sitioId)) {
      return res.status(400).json({
        mensaje: 'El sitio asociado no es válido'
      });
    }

    // ==================================================
    // CAMPOS PERMITIDOS PARA EL SITIO
    // ==================================================

    const camposPermitidos = [
      'nombre',
      'descripcion',
      'direccion',
      'ciudad',
      'departamento',
      'latitud',
      'longitud',
      'categoria',
      'etiquetas',
      'telefono',
      'correos',
      'sitioWeb',
      'horario',
      'precioDesde'
    ];

    const datosActualizar = {};

    for (const campo of camposPermitidos) {
      if (req.body[campo] !== undefined) {
        datosActualizar[campo] = req.body[campo];
      }
    }

    // ==================================================
    // VALIDACIONES BÁSICAS
    // ==================================================

    if (
      datosActualizar.nombre !== undefined &&
      (!datosActualizar.nombre ||
        datosActualizar.nombre.toString().trim().length < 2)
    ) {
      return res.status(400).json({
        mensaje: 'El nombre del sitio es obligatorio'
      });
    }

    if (
      datosActualizar.latitud !== undefined &&
      typeof datosActualizar.latitud !== 'number'
    ) {
      return res.status(400).json({
        mensaje: 'La latitud debe ser numérica'
      });
    }

    if (
      datosActualizar.longitud !== undefined &&
      typeof datosActualizar.longitud !== 'number'
    ) {
      return res.status(400).json({
        mensaje: 'La longitud debe ser numérica'
      });
    }

    if (
      datosActualizar.precioDesde !== undefined &&
      typeof datosActualizar.precioDesde !== 'number'
    ) {
      return res.status(400).json({
        mensaje: 'El precioDesde debe ser numérico'
      });
    }

    // ==================================================
    // ACTUALIZAR ÚNICAMENTE EL SITIO DEL TOKEN
    // ==================================================

    const sitioActualizado = await SitioTuristico
      .findByIdAndUpdate(
        sitioId,
        {
          $set: datosActualizar
        },
        {
          new: true,
          runValidators: true
        }
      )
      .populate('categoria');

    if (!sitioActualizado) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    return res.status(200).json({
      mensaje: 'Información del sitio actualizada correctamente',
      sitio: sitioActualizado
    });

  } catch (error) {
    console.error(
      '❌ Error al actualizar información del sitio:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al actualizar la información del sitio',
      error: error.message
    });
  }
};

// ======================================================
// SUBIR IMAGEN PRINCIPAL DEL SITIO
// ======================================================

const subirImagenPrincipal = async (req, res) => {
  try {
    const sitioId = req.usuario.sitioId;

    if (!sitioId) {
      return res.status(400).json({
        mensaje: 'La cuenta no tiene un sitio asociado'
      });
    }

    if (!mongoose.Types.ObjectId.isValid(sitioId)) {
      return res.status(400).json({
        mensaje: 'El sitio asociado no es válido'
      });
    }

    // ==================================================
    // VERIFICAR QUE SE RECIBIÓ UNA IMAGEN
    // ==================================================

    if (!req.file) {
      return res.status(400).json({
        mensaje: 'Debes seleccionar una imagen'
      });
    }

    // ==================================================
    // OBTENER EL SITIO DEL TOKEN
    // ==================================================

    const sitio = await SitioTuristico.findById(sitioId);

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    // ==================================================
    // GUARDAR URL DE CLOUDINARY
    // ==================================================

    sitio.imagen = req.file.path;

    await sitio.save();

    // ==================================================
    // DEVOLVER SITIO ACTUALIZADO
    // ==================================================

    const sitioActualizado = await SitioTuristico
      .findById(sitioId)
      .populate('categoria');

    return res.status(200).json({
      mensaje: 'Imagen principal actualizada correctamente',
      sitio: sitioActualizado
    });

  } catch (error) {
    console.error(
      '❌ Error al subir la imagen principal:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al subir la imagen principal',
      error: error.message
    });
  }
};


// ======================================================
// EXPORTAR
// ======================================================

module.exports = {
  obtenerInformacion,
  actualizarInformacion,
  subirImagenPrincipal
};