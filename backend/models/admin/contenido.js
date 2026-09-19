const mongoose = require('mongoose');

const contenidoSchema = new mongoose.Schema(
  {
    // Sitio turístico al que pertenece el contenido
    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true
    },

    // Tipo de contenido
    tipo: {
      type: String,
      required: true,
      trim: true
    },

    // Título del contenido
    titulo: {
      type: String,
      required: true,
      trim: true
    },

    // Descripción del contenido
    descripcion: {
      type: String,
      default: '',
      trim: true
    },

    // URL o enlace relacionado con el contenido
    url: {
      type: String,
      default: '',
      trim: true
    },

    // Idioma del contenido
    idioma: {
      type: String,
      default: 'es',
      trim: true
    },

    // Estado del contenido
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