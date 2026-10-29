
const mongoose = require('mongoose');

const productoSchema = new mongoose.Schema(
  {
    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true,
      index: true
    },

    nombre: {
      type: String,
      required: true,
      trim: true,
      maxlength: 120
    },

    descripcion: {
      type: String,
      default: '',
      trim: true,
      maxlength: 1500
    },

    precio: {
      type: Number,
      required: true,
      min: 0
    },

    categoria: {
      type: String,
      required: true,
      trim: true,
      enum: [
        'Cafe',
        'Gastronomia',
        'Artesanias',
        'Dulces y postres',
        'Productos tipicos',
        'Otros'
      ]
    },

    imagenPrincipal: {
      type: String,
      default: ''
    },

    imagenes: {
      type: [String],
      default: []
    },

    activo: {
      type: Boolean,
      default: true
    },

    // Ocultamiento exclusivo del panel administrativo.
    ocultoEnAdmin: {
      type: Boolean,
      default: false,
      index: true
    },

    estadoPublicacion: {
      type: String,
      enum: [
        'borrador',
        'pendiente_revision',
        'aprobado',
        'rechazado'
      ],
      default: 'borrador',
      index: true
    },

    motivoRechazo: {
      type: String,
      default: '',
      trim: true
    },

    revisadoPor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Administrador',
      default: null
    },

    revisadoAt: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true,
    collection: 'productos'
  }
);

productoSchema.index({
  sitio: 1,
  activo: 1,
  estadoPublicacion: 1
});

module.exports =
  mongoose.models.Producto ||
  mongoose.model('Producto', productoSchema);
