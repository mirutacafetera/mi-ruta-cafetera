const mongoose = require('mongoose');

const Categoria = require(
  '../../models/sitio/categoria.js'
);

const obtenerCategorias = async (req, res) => {
  try {
    const categorias = await Categoria
      .find({ estado: true })
      .sort({ nombre: 1 });

    res.status(200).json(categorias);
  } catch (error) {
    console.error(
      'Error al obtener categorías:',
      error
    );

    res.status(500).json({
      mensaje: 'Error al obtener las categorías',
      error: error.message
    });
  }
};

const obtenerCategoria = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de categoría no válido'
      });
    }

    const categoria = await Categoria.findById(id);

    if (!categoria) {
      return res.status(404).json({
        mensaje: 'Categoría no encontrada'
      });
    }

    res.status(200).json(categoria);
  } catch (error) {
    console.error(
      'Error al obtener categoría:',
      error
    );

    res.status(500).json({
      mensaje: 'Error al obtener la categoría',
      error: error.message
    });
  }
};

const crearCategoria = async (req, res) => {
  try {
    const {
      nombre,
      descripcion,
      icono
    } = req.body;

    if (!nombre || !nombre.trim()) {
      return res.status(400).json({
        mensaje: 'El nombre de la categoría es obligatorio'
      });
    }

    const categoriaExistente =
      await Categoria.findOne({
        nombre: nombre.trim()
      });

    if (categoriaExistente) {
      return res.status(400).json({
        mensaje: 'La categoría ya existe'
      });
    }

    const categoria = new Categoria({
      nombre: nombre.trim(),
      descripcion: descripcion || '',
      icono: icono || 'location_on'
    });

    const categoriaGuardada =
      await categoria.save();

    res.status(201).json({
      mensaje: 'Categoría creada correctamente',
      categoria: categoriaGuardada
    });
  } catch (error) {
    console.error(
      'Error al crear categoría:',
      error
    );

    res.status(500).json({
      mensaje: 'Error al crear la categoría',
      error: error.message
    });
  }
};

const actualizarCategoria = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de categoría no válido'
      });
    }

    const categoria =
      await Categoria.findByIdAndUpdate(
        id,
        req.body,
        {
          new: true,
          runValidators: true
        }
      );

    if (!categoria) {
      return res.status(404).json({
        mensaje: 'Categoría no encontrada'
      });
    }

    res.status(200).json({
      mensaje: 'Categoría actualizada correctamente',
      categoria
    });
  } catch (error) {
    console.error(
      'Error al actualizar categoría:',
      error
    );

    res.status(500).json({
      mensaje: 'Error al actualizar la categoría',
      error: error.message
    });
  }
};

const eliminarCategoria = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de categoría no válido'
      });
    }

    const categoria =
      await Categoria.findByIdAndUpdate(
        id,
        {
          estado: false
        },
        {
          new: true
        }
      );

    if (!categoria) {
      return res.status(404).json({
        mensaje: 'Categoría no encontrada'
      });
    }

    res.status(200).json({
      mensaje: 'Categoría desactivada correctamente',
      categoria
    });
  } catch (error) {
    console.error(
      'Error al eliminar categoría:',
      error
    );

    res.status(500).json({
      mensaje: 'Error al eliminar la categoría',
      error: error.message
    });
  }
};

module.exports = {
  obtenerCategorias,
  obtenerCategoria,
  crearCategoria,
  actualizarCategoria,
  eliminarCategoria
};