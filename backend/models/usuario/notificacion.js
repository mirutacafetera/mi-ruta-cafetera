const mongoose = require('mongoose');

// Una notificación tiene como destinatario a un usuario o a un sitio
// turístico (cuenta del establecimiento). Las anteriores solo tienen
// usuario y siguen siendo válidas.

const notificacionSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      required: function () {
        return !this.sitio;
      }
    },

    sitio: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      default: null
    },

    reserva: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Reserva',
      default: null
    },

    titulo: {
      type: String,
      required: true,
      trim: true
    },

    mensaje: {
      type: String,
      required: true,
      trim: true
    },

    tipo: {
      type: String,
      default: 'general'
    },

    leida: {
      type: Boolean,
      default: false
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

notificacionSchema.index({ sitio: 1, activo: 1, createdAt: -1 });

module.exports =
  mongoose.models.Notificacion ||
  mongoose.model('Notificacion', notificacionSchema);
