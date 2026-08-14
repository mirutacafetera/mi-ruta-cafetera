const mongoose = require('mongoose');

const notificacionSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      required: true
    },

    titulo: {
      type: String,
      required: true,
      trim: true
    },

    mensaje: {
      type: String,
      required: true,
      trim: true
    },

    tipo: {
      type: String,
      default: 'general'
    },

    leida: {
      type: Boolean,
      default: false
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

module.exports = mongoose.model('Notificacion', notificacionSchema);