const mongoose = require('mongoose');

const rutaSchema = new mongoose.Schema(
  {
    usuario: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Usuario',
      default: null
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

      sitios: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'SitioTuristico'
      }
    ],
    tipo: {
      type: String,
      enum: ['personalizada', 'predefinida'],
      default: 'personalizada'
    },

    activa: {
      type: Boolean,
      default: true
    },

    expiraEn: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true
  }
);

// ============================================================
// TTL
// ============================================================
// MongoDB eliminará automáticamente los documentos cuando
// llegue la fecha almacenada en expiraEn.
//
// Las rutas predefinidas tienen expiraEn = null,
// por lo tanto nunca son eliminadas por este índice.
// ============================================================

rutaSchema.index(
  { expiraEn: 1 },
  {
    expireAfterSeconds: 0
  }
);

module.exports = mongoose.model('Ruta', rutaSchema);