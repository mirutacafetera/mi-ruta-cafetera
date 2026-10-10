const mongoose = require('mongoose');

const favoritoSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      required: true
    },

    // El controlador (favoritos.controller.js) lee y escribe
    // este campo como "sitio" y lo puebla con populate('sitio').
    // Los sitios viven en el modelo SitioTuristico.
    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Favorito', favoritoSchema);