const mongoose = require('mongoose');

const visitaSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      required: true
    },

    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Sitio',
      required: true
    },

    fechaVisita: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Visita', visitaSchema);