const mongoose = require('mongoose');

const actividadSchema = new mongoose.Schema(
  {
    // ======================================================
    // SITIO AL QUE PERTENECE
    // ======================================================

    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true
    },

    // ======================================================
    // INFORMACIÓN DE LA ACTIVIDAD
    // ======================================================

    nombre: {
      type: String,
      required: true,
      trim: true
    },

    descripcion: {
      type: String,
      default: '',
      trim: true
    },

    precio: {
      type: Number,
      default: 0
    },

    horario: {
      type: String,
      default: '',
      trim: true
    },

    duracion: {
      type: String,
      default: '',
      trim: true
    },

    // ======================================================
    // ESTADO OPERATIVO
    // ======================================================

    activo: {
      type: Boolean,
      default: true
    },

    // ======================================================
    // ESTADO DE PUBLICACIÓN
    // ======================================================

    estadoPublicacion: {
      type: String,
      enum: [
        'borrador',
        'pendiente_revision',
        'aprobado',
        'rechazado'
      ],
      default: 'borrador'
    },

    // ======================================================
    // INFORMACIÓN DE RECHAZO
    // ======================================================

    motivoRechazo: {
      type: String,
      default: '',
      trim: true
    },

    // ======================================================
    // INFORMACIÓN DE LA REVISIÓN
    // ======================================================

    revisadoPor: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Administrador',
      default: null
    },

    revisadoAt: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true
  }
);

module.exports = mongoose.model('Actividad', actividadSchema);