const mongoose = require('mongoose');

const resenaSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      required: true
    },

    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true
    },

    calificacion: {
      type: Number,
      required: true,
      min: 1,
      max: 5
    },

    comentario: {
      type: String,
      required: true,
      trim: true
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

module.exports = mongoose.model('Resena', resenaSchema);