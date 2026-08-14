const mongoose = require('mongoose');

const contenidoSchema = new mongoose.Schema(
  {
    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true
    },

    tipo: {
      type: String,
      enum: [
        'imagen',
        'video',
        'audio',
        'descripcion',
        'traduccion'
      ],
      required: true
    },

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

    url: {
      type: String,
      default: ''
    },

    idioma: {
      type: String,
      default: 'es'
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

module.exports = mongoose.model('Contenido', contenidoSchema);