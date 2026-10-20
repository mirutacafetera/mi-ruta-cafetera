const mongoose = require('mongoose');
const Producto = require('../../models/sitio/producto');

const obtenerProductosPendientes = async (req, res) => {
  try {
    const productos = await Producto.find({
      estadoPublicacion: 'pendiente_revision'
    })
      .populate('sitio', 'nombre ciudad departamento')
      .sort({ createdAt: -1 });

    return res.status(200).json({ productos });
  } catch (error) {
    console.error('Error al obtener productos pendientes:', error);

    return res.status(500).json({
      mensaje: 'No se pudieron obtener los productos pendientes'
    });
  }
};

const obtenerProducto = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID del producto no es válido'
      });
    }

    const producto = await Producto.findById(id)
      .populate('sitio', 'nombre ciudad departamento');

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado'
      });
    }

    return res.status(200).json({ producto });
  } catch (error) {
    console.error('Error al obtener producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudo obtener el producto'
    });
  }
};

const aprobarProducto = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID del producto no es válido'
      });
    }

    const producto = await Producto.findById(id);

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado'
      });
    }

    if (producto.estadoPublicacion !== 'pendiente_revision') {
      return res.status(400).json({
        mensaje: 'El producto no está pendiente de revisión'
      });
    }

    if (!producto.imagenPrincipal) {
      return res.status(400).json({
        mensaje: 'El producto debe tener una fotografía principal'
      });
    }

    producto.estadoPublicacion = 'aprobado';
    producto.motivoRechazo = '';
    producto.revisadoPor = req.usuario.id;
    producto.revisadoAt = new Date();

    await producto.save();

    const productoActualizado = await Producto.findById(producto._id)
      .populate('sitio', 'nombre ciudad departamento');

    return res.status(200).json({
      mensaje: 'Producto aprobado correctamente',
      producto: productoActualizado
    });
  } catch (error) {
    console.error('Error al aprobar producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudo aprobar el producto'
    });
  }
};

const rechazarProducto = async (req, res) => {
  try {
    const { id } = req.params;
    const { motivoRechazo } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID del producto no es válido'
      });
    }

    if (
      typeof motivoRechazo !== 'string' ||
      motivoRechazo.trim().length < 3
    ) {
      return res.status(400).json({
        mensaje: 'Debes indicar el motivo del rechazo'
      });
    }

    const producto = await Producto.findById(id);

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado'
      });
    }

    if (producto.estadoPublicacion !== 'pendiente_revision') {
      return res.status(400).json({
        mensaje: 'El producto no está pendiente de revisión'
      });
    }

    producto.estadoPublicacion = 'rechazado';
    producto.motivoRechazo = motivoRechazo.trim();
    producto.revisadoPor = req.usuario.id;
    producto.revisadoAt = new Date();

    await producto.save();

    const productoActualizado = await Producto.findById(producto._id)
      .populate('sitio', 'nombre ciudad departamento');

    return res.status(200).json({
      mensaje: 'Producto rechazado correctamente',
      producto: productoActualizado
    });
  } catch (error) {
    console.error('Error al rechazar producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudo rechazar el producto'
    });
  }
};

module.exports = {
  obtenerProductosPendientes,
  obtenerProducto,
  aprobarProducto,
  rechazarProducto
};