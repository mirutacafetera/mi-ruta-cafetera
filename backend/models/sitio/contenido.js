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

    // Aquí se guarda el enlace real de la imagen,
    // video o audio
    url: {
      type: String,
      default: '',
      trim: true
    },

    idioma: {
      type: String,
      default: 'es',
      trim: true
    },

    activo: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true,
    collection: 'contenidos'
  }
);

const Contenido =
  mongoose.models.Contenido ||
  mongoose.model('Contenido', contenidoSchema);

module.exports = Contenido;