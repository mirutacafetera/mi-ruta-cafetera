const mongoose = require('mongoose');

const actividadSchema = new mongoose.Schema(
  {
    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true
    },

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

    imagenPrincipal: {
      type: String,
      default: ''
    },

    imagenes: {
      type: [String],
      default: []
    },

    activo: {
      type: Boolean,
      default: true
    },

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

    motivoRechazo: {
      type: String,
      default: '',
      trim: true
    },

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