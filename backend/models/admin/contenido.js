const mongoose = require('mongoose');

const contenidoSchema = new mongoose.Schema(
  {
    titulo: {
      type: String,
      required: true,
      trim: true
    },

    descripcion: {
      type: String,
      default: '',
      trim: true
    },

    tipo: {
      type: String,
      enum: [
        'inicio',
        'banner',
        'informacion',
        'promocion',
        'recomendacion',
        'general'
      ],
      default: 'general'
    },

    imagen: {
      type: String,
      default: ''
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

module.exports = mongoose.model('ContenidoAdmin', contenidoSchema);