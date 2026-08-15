const mongoose = require('mongoose');

const sitioTuristicoSchema = new mongoose.Schema(
  {
    nombre: {
      type: String,
      required: true,
      trim: true
    },

    descripcion: {
      type: String,
      required: true,
      trim: true
    },

    categoria: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Categoria',
      required: true
    },

    direccion: {
      type: String,
      default: '',
      trim: true
    },

    ciudad: {
      type: String,
      default: 'Garzón',
      trim: true
    },

    departamento: {
      type: String,
      default: 'Huila',
      trim: true
    },

    latitud: {
      type: Number,
      required: true
    },

    longitud: {
      type: Number,
      required: true
    },

    telefono: {
      type: String,
      default: '',
      trim: true
    },

    correos: {
      type: String,
      default: '',
      trim: true,
      lowercase: true
    },

    sitioWeb: {
      type: String,
      default: '',
      trim: true
    },

    imagen: {
      type: String,
      default: '',
      trim: true
    },

    imagenes: {
      type: [String],
      default: []
    },

    horario: {
      type: String,
      default: '',
      trim: true
    },

    precioDesde: {
      type: Number,
      default: 0,
      min: 0
    },

    activo: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('SitioTuristico', sitioTuristicoSchema);