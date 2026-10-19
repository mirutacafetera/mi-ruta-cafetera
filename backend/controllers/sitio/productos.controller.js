const mongoose = require('mongoose');
const Producto = require('../../models/sitio/producto');
const SitioTuristico = require('../../models/admin/sitio');

const CATEGORIAS_PRODUCTO = [
  'Cafe',
  'Gastronomia',
  'Artesanias',
  'Dulces y postres',
  'Productos tipicos',
  'Otros'
];

const obtenerProductos = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID del sitio no es válido'
      });
    }

    const sitio = await SitioTuristico.findOne({
      _id: id,
      activo: true
    }).select('_id');

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'Sitio turístico no encontrado'
      });
    }

    const productos = await Producto.find({
      sitio: id,
      activo: true,
      estadoPublicacion: 'aprobado'
    }).sort({
      categoria: 1,
      nombre: 1
    });

    return res.status(200).json({
      productos
    });
  } catch (error) {
    console.error('Error al obtener productos:', error);

    return res.status(500).json({
      mensaje: 'No se pudieron obtener los productos'
    });
  }
};

const obtenerProductosPropietario = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID del sitio no es válido'
      });
    }

    if (String(req.usuario.sitioId) !== String(id)) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para gestionar este sitio'
      });
    }

    const productos = await Producto.find({
      sitio: id
    }).sort({
      updatedAt: -1
    });

    return res.status(200).json({
      productos
    });
  } catch (error) {
    console.error(
      'Error al obtener productos del propietario:',
      error
    );

    return res.status(500).json({
      mensaje: 'No se pudieron obtener tus productos'
    });
  }
};

const crearProducto = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      nombre,
      descripcion,
      precio,
      categoria
    } = req.body;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({
        mensaje: 'El ID del sitio no es válido'
      });
    }

    if (String(req.usuario.sitioId) !== String(id)) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para gestionar este sitio'
      });
    }

    if (
      typeof nombre !== 'string' ||
      !nombre.trim() ||
      nombre.trim().length > 120
    ) {
      return res.status(400).json({
        mensaje: 'El nombre es obligatorio y no puede superar 120 caracteres'
      });
    }

    if (
      typeof descripcion !== 'undefined' &&
      (
        typeof descripcion !== 'string' ||
        descripcion.trim().length > 1500
      )
    ) {
      return res.status(400).json({
        mensaje: 'La descripción no puede superar 1500 caracteres'
      });
    }

    const precioNumerico = Number(precio);

    if (
      precio === undefined ||
      precio === null ||
      precio === '' ||
      !Number.isFinite(precioNumerico) ||
      precioNumerico < 0
    ) {
      return res.status(400).json({
        mensaje: 'Debes indicar un precio válido igual o superior a cero'
      });
    }

    if (!CATEGORIAS_PRODUCTO.includes(categoria)) {
      return res.status(400).json({
        mensaje: 'Selecciona una categoría válida'
      });
    }

    const sitio = await SitioTuristico.findOne({
      _id: id,
      activo: true
    }).select('_id');

    if (!sitio) {
      return res.status(404).json({
        mensaje: 'El sitio turístico no existe o está inactivo'
      });
    }

    const producto = await Producto.create({
      sitio: id,
      nombre: nombre.trim(),
      descripcion: descripcion ? descripcion.trim() : '',
      precio: precioNumerico,
      categoria,
      activo: true,
      estadoPublicacion: 'borrador'
    });

    return res.status(201).json({
      mensaje: 'Producto creado correctamente',
      producto
    });
  } catch (error) {
    console.error('Error al crear producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudo crear el producto'
    });
  }
};

const actualizarProducto = async (req, res) => {
  try {
    const { id, productoId } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(id) ||
      !mongoose.Types.ObjectId.isValid(productoId)
    ) {
      return res.status(400).json({
        mensaje: 'El ID del sitio o del producto no es válido'
      });
    }

    if (String(req.usuario.sitioId) !== String(id)) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para gestionar este sitio'
      });
    }

    const producto = await Producto.findOne({
      _id: productoId,
      sitio: id
    });

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado'
      });
    }

    const {
      nombre,
      descripcion,
      precio,
      categoria
    } = req.body;

    if (typeof nombre !== 'undefined') {
      if (
        typeof nombre !== 'string' ||
        !nombre.trim() ||
        nombre.trim().length > 120
      ) {
        return res.status(400).json({
          mensaje: 'El nombre es obligatorio y no puede superar 120 caracteres'
        });
      }

      producto.nombre = nombre.trim();
    }

    if (typeof descripcion !== 'undefined') {
      if (
        typeof descripcion !== 'string' ||
        descripcion.trim().length > 1500
      ) {
        return res.status(400).json({
          mensaje: 'La descripción no puede superar 1500 caracteres'
        });
      }

      producto.descripcion = descripcion.trim();
    }

    if (typeof precio !== 'undefined') {
      const precioNumerico = Number(precio);

      if (
        precio === null ||
        precio === '' ||
        !Number.isFinite(precioNumerico) ||
        precioNumerico < 0
      ) {
        return res.status(400).json({
          mensaje: 'Debes indicar un precio válido igual o superior a cero'
        });
      }

      producto.precio = precioNumerico;
    }

    if (typeof categoria !== 'undefined') {
      if (!CATEGORIAS_PRODUCTO.includes(categoria)) {
        return res.status(400).json({
          mensaje: 'Selecciona una categoría válida'
        });
      }

      producto.categoria = categoria;
    }

    producto.estadoPublicacion = 'borrador';
    producto.motivoRechazo = '';
    producto.revisadoPor = null;
    producto.revisadoAt = null;

    await producto.save();

    return res.status(200).json({
      mensaje: 'Producto actualizado. Debes enviarlo nuevamente a revisión.',
      producto
    });
  } catch (error) {
    console.error('Error al actualizar producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudo actualizar el producto'
    });
  }
};

const enviarProductoRevision = async (req, res) => {
  try {
    const { id, productoId } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(id) ||
      !mongoose.Types.ObjectId.isValid(productoId)
    ) {
      return res.status(400).json({
        mensaje: 'El ID del sitio o del producto no es válido'
      });
    }

    if (String(req.usuario.sitioId) !== String(id)) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para gestionar este sitio'
      });
    }

    const producto = await Producto.findOne({
      _id: productoId,
      sitio: id
    });

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado'
      });
    }

    if (
      !producto.nombre.trim() ||
      !producto.categoria ||
      producto.precio < 0
    ) {
      return res.status(400).json({
        mensaje: 'Completa la información obligatoria antes de enviarlo a revisión'
      });
    }

    if (!producto.imagenPrincipal) {
      return res.status(400).json({
        mensaje: 'Debes subir al menos una fotografía antes de enviarlo a revisión'
      });
    }

    if (producto.estadoPublicacion === 'pendiente_revision') {
      return res.status(400).json({
        mensaje: 'El producto ya está pendiente de revisión'
      });
    }

    if (producto.estadoPublicacion === 'aprobado') {
      return res.status(400).json({
        mensaje: 'El producto ya está aprobado'
      });
    }

    producto.estadoPublicacion = 'pendiente_revision';
    producto.motivoRechazo = '';
    producto.revisadoPor = null;
    producto.revisadoAt = null;

    await producto.save();

    return res.status(200).json({
      mensaje: 'Producto enviado a revisión correctamente',
      producto
    });
  } catch (error) {
    console.error(
      'Error al enviar producto a revisión:',
      error
    );

    return res.status(500).json({
      mensaje: 'No se pudo enviar el producto a revisión'
    });
  }
};

const eliminarProducto = async (req, res) => {
  try {
    const { id, productoId } = req.params;

    if (
      !mongoose.Types.ObjectId.isValid(id) ||
      !mongoose.Types.ObjectId.isValid(productoId)
    ) {
      return res.status(400).json({
        mensaje: 'El ID del sitio o del producto no es válido'
      });
    }

    if (String(req.usuario.sitioId) !== String(id)) {
      return res.status(403).json({
        mensaje: 'No tienes permiso para gestionar este sitio'
      });
    }

    const producto = await Producto.findOneAndDelete({
      _id: productoId,
      sitio: id
    });

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado'
      });
    }

    return res.status(200).json({
      mensaje: 'Producto eliminado correctamente'
    });
  } catch (error) {
    console.error('Error al eliminar producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudo eliminar el producto'
    });
  }
};

const subirImagenesProducto = async (req, res) => {
  try {
    const producto = await Producto.findOne({
      _id: req.params.productoId,
      sitio: req.usuario.sitioId
    });

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado o no pertenece a este sitio'
      });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        mensaje: 'Debes seleccionar al menos una imagen'
      });
    }

    const imagenesActuales = Array.isArray(producto.imagenes)
      ? producto.imagenes
      : [];

    const cantidadActual =
      (producto.imagenPrincipal ? 1 : 0) +
      imagenesActuales.length;

    if (cantidadActual + req.files.length > 10) {
      return res.status(400).json({
        mensaje: 'Un producto puede tener máximo 10 imágenes'
      });
    }

    const urls = req.files
      .map((file) => file.path)
      .filter(Boolean);

    if (urls.length === 0) {
      return res.status(400).json({
        mensaje: 'No fue posible obtener las imágenes subidas'
      });
    }

    if (!producto.imagenPrincipal) {
      producto.imagenPrincipal = urls[0];
      producto.imagenes.push(...urls.slice(1));
    } else {
      producto.imagenes.push(...urls);
    }

    if (
      producto.estadoPublicacion === 'aprobado' ||
      producto.estadoPublicacion === 'rechazado'
    ) {
      producto.estadoPublicacion = 'borrador';
      producto.motivoRechazo = '';
      producto.revisadoPor = null;
      producto.revisadoAt = null;
    }

    await producto.save();

    return res.status(201).json({
      mensaje: 'Imágenes agregadas correctamente',
      producto
    });
  } catch (error) {
    console.error('Error al subir imágenes del producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudieron subir las imágenes del producto'
    });
  }
};

const eliminarImagenProducto = async (req, res) => {
  try {
    const producto = await Producto.findOne({
      _id: req.params.productoId,
      sitio: req.usuario.sitioId
    });

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado o no pertenece a este sitio'
      });
    }

    const { url } = req.body;

    if (!url) {
      return res.status(400).json({
        mensaje: 'Debes indicar la URL de la imagen'
      });
    }

    if (producto.imagenPrincipal === url) {
      return res.status(400).json({
        mensaje: 'Selecciona otra imagen principal antes de eliminar esta'
      });
    }

    const cantidadAntes = producto.imagenes.length;

    producto.imagenes = producto.imagenes.filter(
      (imagen) => imagen !== url
    );

    if (producto.imagenes.length === cantidadAntes) {
      return res.status(404).json({
        mensaje: 'La imagen no pertenece a este producto'
      });
    }

    if (
      producto.estadoPublicacion === 'aprobado' ||
      producto.estadoPublicacion === 'rechazado'
    ) {
      producto.estadoPublicacion = 'borrador';
      producto.motivoRechazo = '';
      producto.revisadoPor = null;
      producto.revisadoAt = null;
    }

    await producto.save();

    return res.status(200).json({
      mensaje: 'Imagen eliminada correctamente',
      producto
    });
  } catch (error) {
    console.error('Error al eliminar imagen del producto:', error);

    return res.status(500).json({
      mensaje: 'No se pudo eliminar la imagen del producto'
    });
  }
};

const establecerImagenPrincipalProducto = async (req, res) => {
  try {
    const producto = await Producto.findOne({
      _id: req.params.productoId,
      sitio: req.usuario.sitioId
    });

    if (!producto) {
      return res.status(404).json({
        mensaje: 'Producto no encontrado o no pertenece a este sitio'
      });
    }

    const { url } = req.body;

    if (!url) {
      return res.status(400).json({
        mensaje: 'Debes indicar la URL de la imagen'
      });
    }

    if (producto.imagenPrincipal === url) {
      return res.status(200).json({
        mensaje: 'La imagen ya es la principal',
        producto
      });
    }

    const indice = producto.imagenes.indexOf(url);

    if (indice === -1) {
      return res.status(404).json({
        mensaje: 'La imagen no pertenece a este producto'
      });
    }

    const imagenPrincipalAnterior = producto.imagenPrincipal;

    producto.imagenPrincipal = url;
    producto.imagenes[indice] = imagenPrincipalAnterior;

    if (
      producto.estadoPublicacion === 'aprobado' ||
      producto.estadoPublicacion === 'rechazado'
    ) {
      producto.estadoPublicacion = 'borrador';
      producto.motivoRechazo = '';
      producto.revisadoPor = null;
      producto.revisadoAt = null;
    }

    await producto.save();

    return res.status(200).json({
      mensaje: 'Imagen principal actualizada correctamente',
      producto
    });
  } catch (error) {
    console.error('Error al establecer imagen principal:', error);

    return res.status(500).json({
      mensaje: 'No se pudo establecer la imagen principal'
    });
  }
};

module.exports = {
  obtenerProductos,
  obtenerProductosPropietario,
  crearProducto,
  actualizarProducto,
  enviarProductoRevision,
  eliminarProducto,
  subirImagenesProducto,
  eliminarImagenProducto,
  establecerImagenPrincipalProducto
};