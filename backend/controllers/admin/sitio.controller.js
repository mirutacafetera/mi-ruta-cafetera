const SitioTuristico = require('../../models/admin/sitio');

// ======================================================
// CREAR SITIO TURÍSTICO
// ======================================================

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
      imagen,
      imagenes,
      horario,
      precioDesde
    } = req.body;

    const sitio = new SitioTuristico({
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
    console.error(error);

    res.status(500).json({
      mensaje: 'Error al crear el sitio turístico',
      error: error.message
    });
  }
};

// ======================================================
// OBTENER TODOS LOS SITIOS
// ======================================================

const obtenerSitios = async (req, res) => {
  try {
    const sitios = await SitioTuristico.find()
      .populate('categoria')
      .sort({ nombre: 1 });

    res.status(200).json(sitios);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      mensaje: 'Error al obtener los sitios turísticos',
      error: error.message
    });
  }
};

// ======================================================
// OBTENER UN SITIO
// ======================================================

const obtenerSitio = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findById(req.params.id)
      .populate('categoria');

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.status(200).json(sitio);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      mensaje: 'Error al obtener el sitio turístico',
      error: error.message
    });
  }
};

// ======================================================
// ACTUALIZAR SITIO
// ======================================================

const actualizarSitio = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findByIdAndUpdate(
      req.params.id,
      req.body,
      {
        new: true,
        runValidators: true
      }
    ).populate('categoria');

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
    console.error(error);

    res.status(500).json({
      mensaje: 'Error al actualizar el sitio turístico',
      error: error.message
    });
  }
};

// ======================================================
// ELIMINAR SITIO
// ======================================================

const eliminarSitio = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findByIdAndDelete(
      req.params.id
    );

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje: 'Sitio turístico eliminado correctamente'
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      mensaje: 'Error al eliminar el sitio turístico',
      error: error.message
    });
  }
};

module.exports = {
  crearSitio,
  obtenerSitios,
  obtenerSitio,
  actualizarSitio,
  eliminarSitio
};