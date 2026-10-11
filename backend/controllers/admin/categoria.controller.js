
const mongoose = require('mongoose');

const Categoria = require(
  '../../models/admin/categoria.js'
);

// ============================================================
// OBTENER TODAS LAS CATEGORÍAS ACTIVAS
// ============================================================

const obtenerCategorias = async (req, res) => {
  try {
    const categorias = await Categoria
      .find({ estado: true })
      .sort({ nombre: 1 });

    return res.status(200).json(categorias);
  } catch (error) {
    console.error('Error al obtener categorías:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener las categorías',
      error: error.message
    });
  }
};

// ============================================================
// OBTENER UNA CATEGORÍA
// ============================================================

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

    return res.status(200).json(categoria);
  } catch (error) {
    console.error('Error al obtener categoría:', error);

    return res.status(500).json({
      mensaje: 'Error al obtener la categoría',
      error: error.message
    });
  }
};

// ============================================================
// CREAR CATEGORÍA
// ============================================================

const crearCategoria = async (req, res) => {
  try {
    const { nombre, descripcion, icono } = req.body;

    if (!nombre || !nombre.trim()) {
      return res.status(400).json({
        mensaje: 'El nombre de la categoría es obligatorio'
      });
    }

    const categoriaExistente = await Categoria.findOne({
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

    const categoriaGuardada = await categoria.save();

    return res.status(201).json({
      mensaje: 'Categoría creada correctamente',
      categoria: categoriaGuardada
    });
  } catch (error) {
    console.error('Error al crear categoría:', error);

    return res.status(500).json({
      mensaje: 'Error al crear la categoría',
      error: error.message
    });
  }
};

// ============================================================
// ACTUALIZAR CATEGORÍA
// ============================================================

const actualizarCategoria = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de categoría no válido'
      });
    }

    const categoria = await Categoria.findByIdAndUpdate(
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

    return res.status(200).json({
      mensaje: 'Categoría actualizada correctamente',
      categoria
    });
  } catch (error) {
    console.error('Error al actualizar categoría:', error);

    return res.status(500).json({
      mensaje: 'Error al actualizar la categoría',
      error: error.message
    });
  }
};

// ============================================================
// ELIMINAR CATEGORÍA DEFINITIVAMENTE
// ============================================================

const eliminarCategoria = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'ID de categoría no válido'
      });
    }

    const categoria = await Categoria.findByIdAndDelete(id);

    if (!categoria) {
      return res.status(404).json({
        mensaje: 'Categoría no encontrada'
      });
    }

    return res.status(200).json({
      mensaje: 'Categoría eliminada correctamente',
      categoria
    });
  } catch (error) {
    console.error('Error al eliminar categoría:', error);

    return res.status(500).json({
      mensaje: 'Error al eliminar la categoría',
      error: error.message
    });
  }
};

// ============================================================
// EXPORTACIONES
// ============================================================

module.exports = {
  obtenerCategorias,
  obtenerCategoria,
  crearCategoria,
  actualizarCategoria,
  eliminarCategoria
};
