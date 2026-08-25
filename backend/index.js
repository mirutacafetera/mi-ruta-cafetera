const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// ======================================================
// CONFIGURACIÓN GENERAL
// ======================================================

app.use(cors());

app.use(express.json());

app.use(express.urlencoded({ extended: true }));

// ======================================================
// IMPORTACIÓN DE RUTAS
// ======================================================

// ------------------------------------------------------
// RUTAS DE USUARIOS
// ------------------------------------------------------

const usuarioRoutes = require(
  './routes/usuario/usuario.routes'
);

const categoriaRoutes = require(
  './routes/usuario/categoria.routes'
);

const sitioRoutes = require(
  './routes/usuario/sitio.routes'
);

const resenaRoutes = require(
  './routes/usuario/resena.routes'
);

const favoritoRoutes = require(
  './routes/usuario/favorito.routes'
);

const mapaOfflineRoutes = require(
  './routes/usuario/mapasoffline.routes'
);

const notificacionRoutes = require(
  './routes/usuario/notificacion.routes'
);

const reservaRoutes = require(
  './routes/usuario/reserva.routes'
);

const rutaRoutes = require(
  './routes/usuario/ruta.routes'
);

const visitaRoutes = require(
  './routes/usuario/visita.routes'
);

// ------------------------------------------------------
// RUTAS DE ADMINISTRACIÓN
// ------------------------------------------------------

const administradorRoutes = require(
  './routes/admin/administrador.routes'
);

const adminSitiosRoutes = require(
  './routes/admin/sitios.routes'
);

const adminUsuariosRoutes = require(
  './routes/admin/usuarios.routes'
);

const adminResenasRoutes = require(
  './routes/admin/resenas.routes'
);

const adminContenidoRoutes = require(
  './routes/admin/contenido.routes'
);

const adminEstadisticasRoutes = require(
  './routes/admin/estadisticas.routes'
);

// ------------------------------------------------------
// RUTAS DE CUENTAS Y SITIOS
// ------------------------------------------------------

const cuentaSitiosRoutes = require(
  './routes/sitios/cuentaSitios.routes'
);

const sitioTuristicoRoutes = require(
  './routes/sitios/sitioturistico.routes'
);

const informacionRoutes = require(
  './routes/sitios/informacion.routes'
);

const multimediaRoutes = require(
  './routes/sitios/multimedia.routes'
);

const actividadesRoutes = require(
  './routes/sitios/actividades.routes'
);

const resenasSitioRoutes = require(
  './routes/sitios/resenas.routes'
);

const reservasSitioRoutes = require(
  './routes/sitios/reservas.routes'
);

const estadisticasSitioRoutes = require(
  './routes/sitios/estadisticas.routes'
);

const contenidoSitioRoutes = require(
  './routes/sitios/contenido.routes'
);

const categoriaSitioRoutes = require(
  './routes/sitios/categoria.routes'
);

// ======================================================
// RUTAS DE USUARIOS
// ======================================================

app.use(
  '/api/usuarios',
  usuarioRoutes
);

app.use(
  '/api/categorias',
  categoriaRoutes
);

app.use(
  '/api/sitios',
  sitioRoutes
);

app.use(
  '/api/resenas',
  resenaRoutes
);

app.use(
  '/api/favoritos',
  favoritoRoutes
);

app.use(
  '/api/mapas-offline',
  mapaOfflineRoutes
);

app.use(
  '/api/notificaciones',
  notificacionRoutes
);

app.use(
  '/api/reservas',
  reservaRoutes
);

app.use(
  '/api/rutas',
  rutaRoutes
);

app.use(
  '/api/visitas',
  visitaRoutes
);

// ======================================================
// RUTAS DE ADMINISTRACIÓN
// ======================================================

app.use(
  '/api/admin/administradores',
  administradorRoutes
);

app.use(
  '/api/admin/sitios',
  adminSitiosRoutes
);

app.use(
  '/api/admin/usuarios',
  adminUsuariosRoutes
);

app.use(
  '/api/admin/resenas',
  adminResenasRoutes
);

app.use(
  '/api/admin/contenido',
  adminContenidoRoutes
);

app.use(
  '/api/admin/estadisticas',
  adminEstadisticasRoutes
);

// ======================================================
// RUTAS DE CUENTAS Y CATEGORÍAS DE SITIOS
// ======================================================

app.use(
  '/api/cuentas-sitios',
  cuentaSitiosRoutes
);

app.use(
  '/api/categorias-sitios',
  categoriaSitioRoutes
);

// ======================================================
// SUBRUTAS DE SITIOS TURÍSTICOS
// ======================================================

app.use(
  '/api/sitiosturisticos/informacion',
  informacionRoutes
);

app.use(
  '/api/sitiosturisticos/multimedia',
  multimediaRoutes
);

app.use(
  '/api/sitiosturisticos/actividades',
  actividadesRoutes
);

app.use(
  '/api/sitiosturisticos/resenas',
  resenasSitioRoutes
);

app.use(
  '/api/sitiosturisticos/reservas',
  reservasSitioRoutes
);

app.use(
  '/api/sitiosturisticos/estadisticas',
  estadisticasSitioRoutes
);

app.use(
  '/api/sitiosturisticos/contenido',
  contenidoSitioRoutes
);

// ======================================================
// SITIOS TURÍSTICOS PRINCIPALES
// ======================================================
//
// IMPORTANTE:
// Esta ruta va DESPUÉS de las subrutas anteriores.
//

app.use(
  '/api/sitiosturisticos',
  sitioTuristicoRoutes
);

// ======================================================
// RUTA PRINCIPAL
// ======================================================

app.get(
  '/',
  (req, res) => {
    res.status(200).json({
      mensaje:
        'API Mi Ruta Mágica del Café funcionando correctamente',
      estado: 'OK'
    });
  }
);

// ======================================================
// RUTA DE PRUEBA DE CONEXIÓN
// ======================================================

app.get(
  '/api/health',
  (req, res) => {
    res.status(200).json({
      servidor: 'OK',
      mongodb:
        mongoose.connection.readyState === 1
          ? 'CONECTADO'
          : 'NO CONECTADO'
    });
  }
);

// ======================================================
// 404 - RUTA NO ENCONTRADA
// ======================================================

app.use(
  (req, res) => {
    res.status(404).json({
      mensaje: 'Ruta no encontrada',
      ruta: req.originalUrl
    });
  }
);

// ======================================================
// MANEJO GLOBAL DE ERRORES
// ======================================================

app.use(
  (err, req, res, next) => {
    console.error(
      '❌ Error no capturado:',
      err.stack
    );

    res.status(500).json({
      mensaje:
        'Error interno del servidor',
      error: err.message
    });
  }
);

// ======================================================
// MONGODB
// ======================================================

const PORT =
  process.env.PORT || 3000;

const MONGO_URI =
  process.env.MONGO_URI ||
  'mongodb://127.0.0.1:27017/mirutacafetera';

// ======================================================
// CONEXIÓN A MONGODB
// ======================================================

mongoose
  .connect(MONGO_URI)
  .then(() => {
    console.log(
      '=========================================='
    );

    console.log(
      '✅ MongoDB conectado correctamente'
    );

    console.log(
      `📦 Base de datos: ${
        mongoose.connection.name
      }`
    );

    console.log(
      '=========================================='
    );

    // --------------------------------------------------
    // INICIAR SERVIDOR
    // --------------------------------------------------

    app.listen(
      PORT,
      () => {
        console.log(
          `🚀 Servidor funcionando en http://localhost:${PORT}`
        );

        console.log(
          '📍 API de sitios: /api/sitiosturisticos'
        );

        console.log(
          '📂 API de categorías: /api/categorias-sitios'
        );

        console.log(
          '❤️ Health check: /api/health'
        );

        console.log(
          '=========================================='
        );
      }
    );
  })
  .catch(
    (error) => {
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
  );