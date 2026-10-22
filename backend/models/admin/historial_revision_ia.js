
const mongoose = require('mongoose');

const historialRevisionIASchema = new mongoose.Schema(
  {
    tipoSolicitud: {
      type: String,
      enum: ['contenido', 'producto', 'actividad'],
      required: true,
      index: true,
    },

    solicitudId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      index: true,
    },

    sitioId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      required: true,
      index: true,
    },

    nombreSitio: {
      type: String,
      default: '',
    },

    nombreSolicitud: {
      type: String,
      default: '',
    },

    decision: {
      type: String,
      enum: ['aprobado', 'rechazado', 'pendiente_manual', 'error'],
      required: true,
      index: true,
    },

    motivo: {
      type: String,
      required: true,
    },

    criterios: {
      type: [String],
      default: [],
    },

    modeloIA: {
      type: String,
      default: 'openai/gpt-oss-20b',
    },

    fechaDecision: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
    collection: 'historial_revision_ia',
  },
);

historialRevisionIASchema.index({
  solicitudId: 1,
  tipoSolicitud: 1,
  createdAt: -1,
});

module.exports =
  mongoose.models.HistorialRevisionIA ||
  mongoose.model('HistorialRevisionIA', historialRevisionIASchema);
