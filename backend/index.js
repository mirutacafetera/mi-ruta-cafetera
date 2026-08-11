const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

const PORT = 3000;

const client = new MongoClient(process.env.MONGO_URI);

async function iniciarServidor() {
  try {
    await client.connect();

    console.log('✅ MongoDB Atlas conectado correctamente');

    const db = client.db('mi_ruta_cafetera');

    app.get('/', (req, res) => {
      res.json({
        mensaje: 'API Mi Ruta Cafetera funcionando'
      });
    });

    app.listen(PORT, () => {
      console.log(`🚀 Servidor ejecutándose en http://localhost:${PORT}`);
    });

  } catch (error) {
    console.error('❌ Error al conectar con MongoDB:', error);
  }
}

iniciarServidor();