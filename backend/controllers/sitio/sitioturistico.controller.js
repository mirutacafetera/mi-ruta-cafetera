const mongoose = require('mongoose');
const SitioTuristico = require('../../models/sitio/sitioturistico');


// =====================================================
// OBTENER TODOS LOS SITIOS ACTIVOS
// =====================================================

const obtenerSitios = async (req, res) => {
  try {

    const sitios = await SitioTuristico
      .find({ activo: true })
      .populate('categoria');

    res.status(200).json(sitios);

  } catch (error) {

    console.error('Error al obtener sitios:', error);

    res.status(500).json({
      mensaje: 'Error al obtener sitios turísticos',
      error: error.message
    });
  }
};


// =====================================================
// OBTENER SITIO POR ID
// =====================================================

const obtenerSitio = async (req, res) => {
  try {

    const { id } = req.params;

    // Validar ID
    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de sitio turístico no válido'
      });
    }

    const sitio = await SitioTuristico
      .findById(id)
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
      mensaje: 'Error al obtener sitio turístico',
      error: error.message
    });
  }
};


// =====================================================
// CREAR SITIO
// =====================================================

const crearSitio = async (req, res) => {
  try {
    // insertMany acepta tanto un objeto único {} como un arreglo de objetos [{...}, {...}]
    const resultado = await SitioTuristico.insertMany(req.body);

    // Si enviamos un array cargará todos, si es un objeto único lo envuelve en array
    const ids = Array.isArray(resultado) 
      ? resultado.map(item => item._id) 
      : [resultado._id];

    // Traemos los datos creados haciendo el populate correspondiente
    const sitiosCreados = await SitioTuristico.find({ _id: { $in: ids } }).populate('categoria');

    res.status(201).json({
      mensaje: 'Sitio(s) turístico(s) creado(s) correctamente',
      sitios: sitiosCreados
    });

  } catch (error) {

    console.error('Error al crear sitio:', error);

    res.status(500).json({
      mensaje: 'Error al crear sitio turístico',
      error: error.message
    });
  }
};


// =====================================================
// ACTUALIZAR SITIO
// =====================================================

const actualizarSitio = async (req, res) => {
  try {

    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de sitio turístico no válido'
      });
    }

    const sitio = await SitioTuristico
      .findByIdAndUpdate(
        id,
        req.body,
        {
          new: true,
          runValidators: true
        }
      )
      .populate('categoria');

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
      mensaje: 'Error al actualizar sitio turístico',
      error: error.message
    });
  }
};


// =====================================================
// DESACTIVAR SITIO
// =====================================================

const desactivarSitio = async (req, res) => {
  try {

    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de sitio turístico no válido'
      });
    }

    const sitio = await SitioTuristico.findByIdAndUpdate(
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
      mensaje: 'Error al desactivar sitio turístico',
      error: error.message
    });
  }
};


// =====================================================
// ACTIVAR SITIO
// =====================================================

const activarSitio = async (req, res) => {
  try {

    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de sitio turístico no válido'
      });
    }

    const sitio = await SitioTuristico.findByIdAndUpdate(
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
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje: 'Sitio turístico activado correctamente',
      sitio
    });

  } catch (error) {

    console.error('Error al activar sitio:', error);

    res.status(500).json({
      mensaje: 'Error al activar sitio turístico',
      error: error.message
    });
  }
};


// =====================================================
// ELIMINAR SITIO
// =====================================================

const eliminarSitio = async (req, res) => {
  try {

    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de sitio turístico no válido'
      });
    }

    const sitio = await SitioTuristico.findByIdAndDelete(id);

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    res.status(200).json({
      mensaje: 'Sitio turístico eliminado correctamente'
    });

  } catch (error) {

    console.error('Error al eliminar sitio:', error);

    res.status(500).json({
      mensaje: 'Error al eliminar sitio turístico',
      error: error.message
    });
  }
};


module.exports = {
  obtenerSitios,
  obtenerSitio,
  crearSitio,
  actualizarSitio,
  desactivarSitio,
  activarSitio,
  eliminarSitio
};