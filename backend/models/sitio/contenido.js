const mongoose = require('mongoose');

/**
 * Audio guía asociada a un contenido turístico.
 */
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
  },
  {
    _id: true,
  }
);

/**
 * Contenido turístico publicado por un sitio.
 */
const contenidoSchema = new mongoose.Schema(
  {
    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true,
    },

    titulo: {
      type: String,
      required: true,
      trim: true,
    },

    descripcion: {
      type: String,
      required: true,
      trim: true,
    },

    // Imagen principal que representa el contenido.
    imagenPrincipal: {
      type: String,
      default: '',
      trim: true,
    },

    // Imágenes adicionales utilizadas para el carrusel.
    imagenes: [
      {
        type: String,
        trim: true,
      },
    ],

    // Audio guías asociadas al contenido.
    audioGuias: [audioGuiaSchema],

    /**
     * Flujo de publicación.
     *
     * borrador:
     * El sitio está trabajando en el contenido.
     *
     * pendiente_revision:
     * El sitio lo envió al administrador.
     *
     * aprobado:
     * Puede mostrarse públicamente.
     *
     * rechazado:
     * El administrador solicitó cambios.
     */
    estadoPublicacion: {
      type: String,
      enum: [
        'borrador',
        'pendiente_revision',
        'aprobado',
        'rechazado',
      ],
      default: 'borrador',
    },

    motivoRechazo: {
      type: String,
      default: '',
      trim: true,
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

    /**
     * Activo/desactivado.
     *
     * El sitio puede desactivar contenido.
     * La eliminación permanente será responsabilidad
     * del administrador.
     */
    activo: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
    collection: 'contenidos',
  }
);

const Contenido =
  mongoose.models.Contenido ||
  mongoose.model('Contenido', contenidoSchema);

module.exports = Contenido;