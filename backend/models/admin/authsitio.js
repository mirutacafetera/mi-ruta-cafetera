const mongoose = require('mongoose');

const sitioTuristicoSchema = new mongoose.Schema(
  {
    correo: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true
    },

    password: {
      type: String,
      required: true
    },

    nombre: {
      type: String,
      required: true,
      trim: true
    },

    descripcion: {
      type: String,
      trim: true,
      default: 'Sin descripción'
    },

    direccion: {
      type: String,
      trim: true,
      default: ''
    },

    ciudad: {
      type: String,
      trim: true,
      default: 'Garzón'
    },

    departamento: {
      type: String,
      trim: true,
      default: 'Huila'
    },

    latitud: {
      type: Number,
      required: true
    },

    longitud: {
      type: Number,
      required: true
    },

    categoria: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'CategoriaSitio',
      required: true
    },

    etiquetas: [
      {
        type: String,
        trim: true
      }
    ],

    activo: {
      type: Boolean,
      default: true
    },

    telefono: {
      type: String,
      trim: true,
      default: ''
    },

    correos: {
      type: String,
      trim: true,
      default: ''
    },

    sitioWeb: {
      type: String,
      trim: true,
      default: ''
    },

    imagen: {
      type: String,
      trim: true,
      default: ''
    },

    imagenes: [
      {
        type: String,
        trim: true
      }
    ],

    horario: {
      type: String,
      trim: true,
      default: ''
    },

    precioDesde: {
      type: Number,
      default: 0
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model(
  'SitioTuristico',
  sitioTuristicoSchema
);