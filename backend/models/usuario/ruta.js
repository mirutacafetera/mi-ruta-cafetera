const mongoose = require('mongoose');

const rutaSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      required: true
    },

    nombre: {
      type: String,
      required: true,
      trim: true
    },

    descripcion: {
      type: String,
      default: '',
      trim: true
    },

    sitios: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Sitio'
      }
    ],

    tipo: {
      type: String,
      enum: ['personalizada', 'predefinida'],
      default: 'personalizada'
    },

    activa: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Ruta', rutaSchema);