
const mongoose = require('mongoose');

const verificacionCuentaSitioSchema = new mongoose.Schema(
  {
    cuentaId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'authSitio',
      required: true
    },

    adminId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true
    },

    correoDestino: {
      type: String,
      required: true,
      lowercase: true,
      trim: true
    },

    codigoHash: {
      type: String,
      required: true,
      select: false
    },

    expiracion: {
      type: Date,
      required: true
    },

    cambios: {
      correo: {
        type: String,
        lowercase: true,
        trim: true,
        default: null
      },

      passwordHash: {
        type: String,
        default: null,
        select: false
      }
    }
  },
  {
    timestamps: true,
    collection: 'verificaciones_cuentas_sitio'
  }
);

// Elimina automáticamente las verificaciones vencidas.
verificacionCuentaSitioSchema.index(
  { expiracion: 1 },
  { expireAfterSeconds: 0 }
);

// Facilita localizar la verificación de cada administrador y cuenta.
verificacionCuentaSitioSchema.index({
  cuentaId: 1,
  adminId: 1
});

const VerificacionCuentaSitio =
  mongoose.models.VerificacionCuentaSitio ||
  mongoose.model(
    'VerificacionCuentaSitio',
    verificacionCuentaSitioSchema
  );

module.exports = VerificacionCuentaSitio;
