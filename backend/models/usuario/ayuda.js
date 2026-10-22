const mongoose = require('mongoose');

const ayudaSchema = new mongoose.Schema(
  {
    // Remitente usuario visitante.
    // Se mantiene para conservar los reportes existentes.
    usuarioId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      default: null
    },

    // Remitente sitio turístico.
    sitioId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SitioTuristico',
      default: null
    },

    tipoRemitente: {
      type: String,
      enum: ['usuario', 'sitio'],
      default: 'usuario',
      required: true
    },

    tipoReporte: {
      type: String,
      enum: ['problema', 'sugerencia', 'mejora', 'otro'],
      default: 'problema',
      required: true
    },

    asunto: {
      type: String,
      required: true,
      trim: true,
      maxlength: 120
    },

    mensaje: {
      type: String,
      required: true,
      trim: true,
      maxlength: 3000
    },

    estado: {
      type: String,
      enum: ['pendiente', 'en_revision', 'resuelto'],
      default: 'pendiente'
    },

    respuestaAdmin: {
      type: String,
      default: null,
      trim: true,
      maxlength: 3000
    }
  },
  {
    timestamps: true
  }
);

// Facilita consultar los reportes de cada remitente.
ayudaSchema.index({ usuarioId: 1, createdAt: -1 });
ayudaSchema.index({ sitioId: 1, createdAt: -1 });
ayudaSchema.index({ tipoRemitente: 1, estado: 1, createdAt: -1 });

module.exports = mongoose.model('Ayuda', ayudaSchema);
