const mongoose = require('mongoose');

const ayudaSchema = new mongoose.Schema(
  {
    usuarioId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      required: true
    },

    asunto: {
      type: String,
      required: true,
      trim: true
    },

    mensaje: {
      type: String,
      required: true,
      trim: true
    },

    estado: {
      type: String,
      enum: ['pendiente', 'en_revision', 'resuelto'],
      default: 'pendiente'
    },

    respuestaAdmin: {
      type: String,
      default: null,
      trim: true
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Ayuda', ayudaSchema);