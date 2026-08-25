const Sitio = require('../../models/admin/sitio');

// =====================================================
// CREAR SITIO TURÍSTICO
// =====================================================

const crearSitio = async (req, res) => {
  try {
    const {
      correo,
      password,
      nombre,
      descripcion,
      categoria,
      direccion,
      ciudad,
      departamento,
      latitud,
      longitud,
      telefono,
      sitioWeb,
      imagen,
      imagenes,
      horario,
      precioDesde
    } = req.body;

    // Validar campos obligatorios
    if (
      !correo ||
      !password ||
      !nombre ||
      !descripcion ||
      !categoria ||
      latitud === undefined ||
      longitud === undefined
    ) {
      return res.status(400).json({
        mensaje: 'Faltan campos obligatorios'
      });
    }

    // Verificar si ya existe un sitio con ese correo
    const sitioExistente = await Sitio.findOne({ correo });

    if (sitioExistente) {
      return res.status(400).json({
        mensaje: 'Ya existe un sitio turístico con ese correo'
      });
    }

    // Crear sitio
    const sitio = new Sitio({
      correo,
      password,
      nombre,
      descripcion,
      categoria,
      direccion,
      ciudad,
      departamento,
      latitud,
      longitud,
      telefono,
      sitioWeb,
      imagen,
      imagenes,
      horario,
      precioDesde
    });

    await sitio.save();

    res.status(201).json({
      mensaje: 'Sitio turístico creado correctamente',
      sitio
    });

  } catch (error) {
    console.error('Error al crear sitio:', error);

    res.status(500).json({
      mensaje: 'Error al crear el sitio turístico',
      error: error.message
    });
  }
};


// =====================================================
// OBTENER TODOS LOS SITIOS
// =====================================================

const obtenerSitios = async (req, res) => {
  try {
    const sitios = await Sitio.find()
      .populate('categoria');

    res.status(200).json(sitios);

  } catch (error) {
    console.error('Error al obtener sitios:', error);

    res.status(500).json({
      mensaje: 'Error al obtener los sitios turísticos',
      error: error.message
    });
  }
};


// =====================================================
// OBTENER UN SITIO POR ID
// =====================================================

const obtenerSitioPorId = async (req, res) => {
  try {
    const sitio = await Sitio.findById(req.params.id)
      .populate('categoria');

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.status(200).json(sitio);

  } catch (error) {
    console.error('Error al obtener sitio:', error);

    res.status(500).json({
      mensaje: 'Error al obtener el sitio turístico',
      error: error.message
    });
  }
};


// =====================================================
// ACTUALIZAR SITIO
// =====================================================

const actualizarSitio = async (req, res) => {
  try {
    const sitio = await Sitio.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje: 'Sitio turístico actualizado correctamente',
      sitio
    });

  } catch (error) {
    console.error('Error al actualizar sitio:', error);

    res.status(500).json({
      mensaje: 'Error al actualizar el sitio turístico',
      error: error.message
    });
  }
};


// =====================================================
// DESACTIVAR SITIO
// =====================================================

const desactivarSitio = async (req, res) => {
  try {
    const sitio = await Sitio.findByIdAndUpdate(
      req.params.id,
      { activo: false },
      { new: true }
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje: 'Sitio turístico desactivado correctamente',
      sitio
    });

  } catch (error) {
    console.error('Error al desactivar sitio:', error);

    res.status(500).json({
      mensaje: 'Error al desactivar el sitio turístico',
      error: error.message
    });
  }
};


module.exports = {
  crearSitio,
  obtenerSitios,
  obtenerSitioPorId,
  actualizarSitio,
  desactivarSitio
};