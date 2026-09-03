const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const administradorSchema = new mongoose.Schema(
  {
    // =====================================================
    // DATOS DEL ADMINISTRADOR
    // =====================================================

    nombre: {
      type: String,
      required: true,
      trim: true
    },

    apellido: {
      type: String,
      required: true,
      trim: true
    },

    correo: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true
    },

    password: {
      type: String,
      required: true,
      minlength: 6,
      select: false
    },

    telefono: {
      type: String,
      trim: true
    },

    // =====================================================
    // ESTADO DEL ADMINISTRADOR
    // =====================================================

    activo: {
      type: Boolean,
      default: true
    },

    // =====================================================
    // VERIFICACIÓN DE CUENTA
    // =====================================================

    isVerified: {
      type: Boolean,
      default: false
    },

    codigoVerificacion: {
      type: String,
      default: null
    },

    codigoVerificacionExpiracion: {
      type: Date,
      default: null
    },

    // =====================================================
    // RECUPERACIÓN DE CONTRASEÑA
    // =====================================================

    codigoRecuperacion: {
      type: String,
      default: null
    },

    codigoRecuperacionExpiracion: {
      type: Date,
      default: null
    },

    tokenRecuperacion: {
      type: String,
      default: null
    },

    tokenRecuperacionExpiracion: {
      type: Date,
      default: null
    }
  },
  {
    timestamps: true
  }
);


// =====================================================
// ENCRIPTACIÓN DE CONTRASEÑA
// =====================================================

administradorSchema.pre('save', async function () {

  // Si la contraseña no fue modificada,
  // no se vuelve a encriptar.

  if (!this.isModified('password')) {
    return;
  }

  const salt = await bcrypt.genSalt(10);

  this.password = await bcrypt.hash(
    this.password,
    salt
  );
});


// =====================================================
// COMPARAR CONTRASEÑA
// =====================================================

administradorSchema.methods.compararPassword = async function (
  passwordIngresada
) {

  return await bcrypt.compare(
    passwordIngresada,
    this.password
  );
};


// =====================================================
// CREAR MODELO
// =====================================================

const Administrador = mongoose.model(
  'Administrador',
  administradorSchema
);


// =====================================================
// EXPORTAR MODELO
// =====================================================

module.exports = Administrador;