const mongoose = require('mongoose');

const sitioSchema = new mongoose.Schema(
  {
    nombre: {
      type: String,
      required: true,
      trim: true
    },

    descripcion: {
      type: String,
      default: 'Sin descripción',
      trim: true
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

    // ==========================================================
    // UBICACIÓN
    // ==========================================================

    latitud: {
      type: Number,
      required: true
    },

    longitud: {
      type: Number,
      required: true
    },

    // ==========================================================
    // CATEGORÍA
    // ==========================================================

    categoria: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Categoria',
      required: true
    },

    // ==========================================================
    // MULTIMEDIA
    // ==========================================================

    fotos: [
      {
        type: String
      }
    ],

    videos: [
      {
        type: String
      }
    ],

    // ==========================================================
    // ESTADO
    // ==========================================================

    activo: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true,
    collection: 'sitioturisticos'
  }
);

module.exports = mongoose.model('Sitio', sitioSchema);