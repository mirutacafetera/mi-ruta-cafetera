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
      default: ''
    },

    ubicacion: {
      latitud: {
        type: Number,
        default: 0
      },

      longitud: {
        type: Number,
        default: 0
      }
    },

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

    activo: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Sitio', sitioSchema);