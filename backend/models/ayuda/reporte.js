const mongoose = require('mongoose');

const reporteSchema = new mongoose.Schema(
  {
    tipoRemitente: {
      type: String,
      enum: ['usuario', 'sitio'],
      required: true
    },

    remitenteId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true
    },

    asunto: {
      type: String,
      required: true,
      trim: true,
      minlength: 3
    },

    mensaje: {
      type: String,
      required: true,
      trim: true,
      minlength: 5
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

module.exports = mongoose.model('Reporte', reporteSchema);