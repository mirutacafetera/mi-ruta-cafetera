const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const usuarioSchema = new mongoose.Schema(
  {
    // =====================================================
    // DATOS DEL USUARIO
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

    ciudad: {
      type: String,
      trim: true
    },

    fotoPerfil: {
      type: String,
      default: null
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
    },


    // =====================================================
    // ROL DEL USUARIO
    // =====================================================

    rol: {
      type: String,
      enum: ['usuario', 'admin'],
      default: 'usuario'
    }
  },
  {
    timestamps: true
  }
);


// =====================================================
// ENCRIPTACIÓN DE CONTRASEÑA
// =====================================================

usuarioSchema.pre('save', async function () {

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

usuarioSchema.methods.compararPassword = async function (
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

const Usuario = mongoose.model(
  'Usuario',
  usuarioSchema
);


// =====================================================
// EXPORTAR MODELO
// =====================================================

module.exports = Usuario;