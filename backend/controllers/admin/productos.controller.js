
const mongoose = require('mongoose');

const Producto = require('../../models/sitio/producto');
const HistorialRevisionIA = require('../../models/admin/historial_revision_ia');

async function agregarEvaluacionIA(productos) {
  const lista = Array.isArray(productos) ? productos : [productos];
  const ids = lista.filter(Boolean).map(producto => producto._id);

  if (ids.length === 0) {
    return Array.isArray(productos) ? [] : null;
  }

  const historial = await HistorialRevisionIA.find({
    tipoSolicitud: 'producto',
    solicitudId: { $in: ids }
  })
    .sort({ createdAt: -1 })
    .lean();

  const evaluaciones = new Map();

  for (const registro of historial) {
    const id = registro.solicitudId.toString();

    if (!evaluaciones.has(id)) {
      evaluaciones.set(id, registro);
    }
  }

  const resultado = lista.filter(Boolean).map(producto => {
    const objeto = producto.toObject
      ? producto.toObject()
      : { ...producto };

    const evaluacion = evaluaciones.get(producto._id.toString());

    return {
      ...objeto,
      evaluacionIA: evaluacion
        ? {
            decision: evaluacion.decision,
            motivo: evaluacion.motivo,
            criterios: evaluacion.criterios || [],
            modeloIA: evaluacion.modeloIA,
            fechaDecision: evaluacion.fechaDecision
          }
        : null
    };
  });

  return Array.isArray(productos) ? resultado : resultado[0] || null;
}

const obtenerProductosPendientes = async (req, res) => {
  try {
    const productos = await Producto.find({
      estadoPublicacion: 'pendiente_revision'
    })
      .populate('sitio', 'nombre ciudad departamento')
      .sort({ createdAt: -1 })
      .lean();

    return res.status(200).json({
      productos: await agregarEvaluacionIA(productos)
    });
  } catch (error) {
    console.error('Error al obtener productos pendientes:', error);

    return res.status(500).json({
      mensaje: 'No se pudieron obtener los productos pendientes'
    });
  }
};

const obtenerProductosPorEstado = async (req, res) => {
  try {
    const { estado } = req.params;
    const estadosPermitidos = ['aprobado', 'rechazado'];

    if (!estadosPermitidos.includes(estado)) {
      return res.status(400).json({
        mensaje: 'El estado solicitado no es válido'
      });
    }

    const productos = await Producto.find({
      estadoPublicacion: estado
    })
      .populate('sitio', 'nombre ciudad departamento')
      .sort({ revisadoAt: -1, createdAt: -1 })
      .lean();

    return res.status(200).json({
      productos: await agregarEvaluacionIA(productos)
    });
  } catch (error) {
    console.error('Error al obtener productos por estado:', error);

    return res.status(500).json({
      mensaje: 'No se pudieron obtener los productos por estado'
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
      .populate('sitio', 'nombre ciudad departamento')
      .lean();

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado'
      });
    }

    return res.status(200).json({
      producto: await agregarEvaluacionIA(producto)
    });
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
      .populate('sitio', 'nombre ciudad departamento')
      .lean();

    return res.status(200).json({
      mensaje: 'Producto aprobado correctamente',
      producto: await agregarEvaluacionIA(productoActualizado)
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
      .populate('sitio', 'nombre ciudad departamento')
      .lean();

    return res.status(200).json({
      mensaje: 'Producto rechazado correctamente',
      producto: await agregarEvaluacionIA(productoActualizado)
    });
  } catch (error) {
    console.error('Error al rechazar producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudo rechazar el producto'
    });
  }
};

// ELIMINAR PRODUCTO
const eliminarProducto = async (req, res) => {
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

    await Producto.findByIdAndDelete(id);

    return res.status(200).json({
      mensaje: 'Producto eliminado correctamente',
      id
    });
  } catch (error) {
    console.error('Error al eliminar producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudo eliminar el producto'
    });
  }
};

module.exports = {
  obtenerProductosPendientes,
  obtenerProductosPorEstado,
  obtenerProducto,
  aprobarProducto,
  rechazarProducto,
  eliminarProducto
};
