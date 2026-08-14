const Categoria = require('../../models/usuario/categoria');

// OBTENER TODAS LAS CATEGORÍAS
const obtenerCategorias = async (req, res) => {
  try {
    const categorias = await Categoria.find({ activo: true });

    res.json(categorias);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener categorías',
      error: error.message
    });
  }
};

module.exports = {
  obtenerCategorias
};

console.log('CARGANDO CATEGORIAS CONTROLLER');
console.log('obtenerCategorias:', typeof obtenerCategorias);