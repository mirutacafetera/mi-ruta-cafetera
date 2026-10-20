
const mongoose = require('mongoose');

// ============================================================
// AUDIOGUÍA
// ============================================================

const audioGuiaSchema = new mongoose.Schema(
  {
    titulo: {
      type: String,
      required: true,
      trim: true,
    },
    descripcion: {
      type: String,
      default: '',
      trim: true,
    },
    url: {
      type: String,
      required: true,
      trim: true,
    },
    duracion: {
      type: String,
      default: '',
      trim: true,
    },
    publicId: {
      type: String,
      default: '',
      trim: true,
    },
  },
  {
    _id: true,
  }
);

// ============================================================
// CONTENIDO TURÍSTICO
// ============================================================

const contenidoSchema = new mongoose.Schema(
  {
    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true,
    },

    // Campos conservados del modelo administrativo.
    tipo: {
      type: String,
      default: 'contenido',
      trim: true,
    },

    titulo: {
      type: String,
      required: true,
      trim: true,
    },

    descripcion: {
      type: String,
      default: '',
      trim: true,
    },

    url: {
      type: String,
      default: '',
      trim: true,
    },

    idioma: {
      type: String,
      default: 'es',
      trim: true,
    },

    // Imagen principal.
    imagenPrincipal: {
      type: String,
      default: '',
      trim: true,
    },

    // Galería de imágenes.
    imagenes: [
      {
        type: String,
        trim: true,
      },
    ],

    // Audioguías.
    audioGuias: [audioGuiaSchema],

    // Estado de revisión.
    estadoPublicacion: {
      type: String,
      enum: [
        'borrador',
        'pendiente_revision',
        'aprobado',
        'rechazado',
      ],
      default: 'pendiente_revision',
      index: true,
    },

    motivoRechazo: {
      type: String,
      default: '',
      trim: true,
    },

    activo: {
      type: Boolean,
      default: false,
    },

    revisadoPor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Administrador',
      default: null,
    },

    revisadoAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
    collection: 'contenidos',
  }
);

const ContenidoAdmin =
  mongoose.models.ContenidoAdmin ||
  mongoose.model('ContenidoAdmin', contenidoSchema);

module.exports = ContenidoAdmin;
