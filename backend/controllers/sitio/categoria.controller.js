const Categoria = require('../../models/sitio/categoria.js');

const obtenerCategorias = async (req, res) => {
    try {
        const categorias = await Categoria.find();

        res.status(200).json(categorias);
    } catch (error) {
        res.status(500).json({
            mensaje: 'Error al obtener las categorías',
            error: error.message
        });
    }
};

const obtenerCategoria = async (req, res) => {
    try {
        const categoria = await Categoria.findById(req.params.id);

        if (!categoria) {
            return res.status(404).json({
                mensaje: 'Categoría no encontrada'
            });
        }

        res.status(200).json(categoria);
    } catch (error) {
        res.status(500).json({
            mensaje: 'Error al obtener la categoría',
            error: error.message
        });
    }
};

const crearCategoria = async (req, res) => {
    try {
        const { nombre, descripcion } = req.body;

        const categoriaExistente = await Categoria.findOne({ nombre });

        if (categoriaExistente) {
            return res.status(400).json({
                mensaje: 'La categoría ya existe'
            });
        }

        const categoria = new Categoria({
            nombre,
            descripcion
        });

        const categoriaGuardada = await categoria.save();

        res.status(201).json({
            mensaje: 'Categoría creada correctamente',
            categoria: categoriaGuardada
        });
    } catch (error) {
        res.status(500).json({
            mensaje: 'Error al crear la categoría',
            error: error.message
        });
    }
};

const actualizarCategoria = async (req, res) => {
    try {
        const categoria = await Categoria.findByIdAndUpdate(
            req.params.id,
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
        res.status(500).json({
            mensaje: 'Error al actualizar la categoría',
            error: error.message
        });
    }
};

const eliminarCategoria = async (req, res) => {
    try {
        const categoria = await Categoria.findByIdAndDelete(
            req.params.id
        );

        if (!categoria) {
            return res.status(404).json({
                mensaje: 'Categoría no encontrada'
            });
        }

        res.status(200).json({
            mensaje: 'Categoría eliminada correctamente'
        });
    } catch (error) {
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