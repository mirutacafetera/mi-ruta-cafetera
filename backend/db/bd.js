const mongoose = require('mongoose');

// ======================================================
// CONEXIÓN A MONGODB
// ======================================================

const conectarBD = async () => {
  try {
    const MONGO_URI =
      process.env.MONGO_URI ||
      'mongodb://127.0.0.1:27017/mirutacafetera';

    await mongoose.connect(MONGO_URI);

    console.log(
      '=========================================='
    );

    console.log(
      '✅ MongoDB conectado correctamente'
    );

    console.log(
      `📦 Base de datos: ${mongoose.connection.name}`
    );

    console.log(
      '=========================================='
    );

  } catch (error) {

    console.error(
      '=========================================='
    );

    console.error(
      '❌ ERROR AL CONECTAR CON MONGODB'
    );

    console.error(
      error.message
    );

    console.error(
      '=========================================='
    );

    process.exit(1);
  }
};

// ======================================================
// EXPORTAR FUNCIÓN
// ======================================================

module.exports = conectarBD;