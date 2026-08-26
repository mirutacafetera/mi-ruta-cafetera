const SitioTuristico = require('../../models/admin/authsitio');

const crearSitio = async (req, res) => {
  try {
    const {
      correo,
      password,
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

    const sitioExistente = await SitioTuristico.findOne({ correo });

    if (sitioExistente) {
      return res.status(400).json({
        mensaje: 'El correo ya está registrado'
      });
    }

    const sitio = new SitioTuristico({
      correo,
      password,
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

const obtenerSitios = async (req, res) => {
  try {
    const sitios = await SitioTuristico.find()
      .populate('categoria');

    res.status(200).json(sitios);
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener los sitios turísticos',
      error: error.message
    });
  }
};

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
    res.status(500).json({
      mensaje: 'Error al obtener el sitio turístico',
      error: error.message
    });
  }
};

const actualizarSitio = async (req, res) => {
  try {
    const sitio = await SitioTuristico.findByIdAndUpdate(
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
    res.status(500).json({
      mensaje: 'Error al actualizar el sitio turístico',
      error: error.message
    });
  }
};

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