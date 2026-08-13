const mongoose = require('mongoose');

const favoritoSchema = new mongoose.Schema(
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
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Favorito', favoritoSchema);