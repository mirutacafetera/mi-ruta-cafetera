
const dns = require('dns');

dns.setServers([
  '8.8.8.8',
  '1.1.1.1'
]);

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

app.use(
  express.urlencoded({
    extended: true
  })
);

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

const chatRoutes = require(
  './routes/usuario/chat.routes'
);

const ayudaRoutes = require(
  './routes/usuario/ayuda.routes'
);

const aiRoutes = require(
  './routes/usuario/ai.routes'
);

// ------------------------------------------------------
// RUTAS DE ADMINISTRACIÓN
// ------------------------------------------------------

const reservasAdminRoutes = require(
  './routes/admin/reservas.routes'
);

const administradorRoutes = require(
  './routes/admin/administrador.routes'
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

const adminAuthSitioRoutes = require(
  './routes/admin/authsitio.routes'
);

const adminSitioRoutes = require(
  './routes/admin/sitio.routes'
);

const categoriaSitioRoutes = require(
  './routes/admin/categoria.routes'
);

const adminAyudaRoutes = require(
  './routes/admin/ayuda.routes'
);

const adminActividadesRoutes = require(
  './routes/admin/actividades.routes'
);

const moderacionContenidoRoutes = require(
  './routes/admin/moderacionContenido.routes'
);

const adminProductosRoutes = require(
  './routes/admin/productos.routes'
);

// CHATBOT EXCLUSIVO DEL ADMINISTRADOR
const adminChatbotRoutes = require(
  './routes/admin/chatbot.routes'
);

// ------------------------------------------------------
// RUTAS DE CUENTAS Y SITIOS
// ------------------------------------------------------

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

const contenidoSitioRoutes = require(
  './routes/sitios/contenido.routes'
);

const authSitioRoutes = require(
  './routes/sitios/auth.routes'
);

const dashboardSitioRoutes = require(
  './routes/sitios/dashboard.routes'
);

const informacionSitioRoutes = require(
  './routes/sitios/informacion.routes'
);

const productosRoutes = require(
  './routes/sitios/productos.routes'
);

// ======================================================
// REGISTRO DE RUTAS DE USUARIOS
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

// CHATBOT PÚBLICO EXISTENTE
app.use(
  '/api/chat',
  chatRoutes
);

app.use(
  '/api/admin/reservas',
  reservasAdminRoutes
);

app.use(
  '/api/ayuda',
  ayudaRoutes
);

// Recomendaciones con IA (Groq)
app.use(
  '/api/v1/ai',
  aiRoutes
);

// ======================================================
// REGISTRO DE RUTAS DE ADMINISTRACIÓN
// ======================================================

// ------------------------------------------------------
// ADMINISTRADORES
// ------------------------------------------------------

app.use(
  '/api/admin/administradores',
  administradorRoutes
);

// ------------------------------------------------------
// USUARIOS
// ------------------------------------------------------

app.use(
  '/api/admin/usuarios',
  adminUsuariosRoutes
);

// ------------------------------------------------------
// RESEÑAS
// ------------------------------------------------------

app.use(
  '/api/admin/resenas',
  adminResenasRoutes
);

// ------------------------------------------------------
// CONTENIDO
// ------------------------------------------------------

app.use(
  '/api/admin/contenido',
  adminContenidoRoutes
);

// ------------------------------------------------------
// ESTADÍSTICAS
// ------------------------------------------------------

app.use(
  '/api/admin/estadisticas',
  adminEstadisticasRoutes
);

app.use(
  '/api/admin/ayuda',
  adminAyudaRoutes
);

// ======================================================
// CHATBOT EXCLUSIVO DEL ADMINISTRADOR
// ======================================================

app.use(
  '/api/admin/chatbot',
  adminChatbotRoutes
);

// ======================================================
// RUTAS DE CUENTAS Y SITIOS
// ======================================================

app.use(
  '/api/admin/authsitio',
  adminAuthSitioRoutes
);

app.use(
  '/api/admin/sitios',
  adminSitioRoutes
);

app.use(
  '/api/categorias-sitios',
  categoriaSitioRoutes
);

app.use(
  '/api/admin/actividades',
  adminActividadesRoutes
);

app.use(
  '/api/admin/moderacion-contenidos',
  moderacionContenidoRoutes
);

app.use(
  '/api/admin/productos',
  adminProductosRoutes
);

// ======================================================
// SUBRUTAS DE SITIOS TURÍSTICOS
// ======================================================

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
  '/api/sitiosturisticos/contenido',
  contenidoSitioRoutes
);

app.use(
  '/api/sitios/auth',
  authSitioRoutes
);

app.use(
  '/api/sitios/panel/dashboard',
  dashboardSitioRoutes
);

app.use(
  '/api/sitiosturisticos/informacion',
  informacionSitioRoutes
);

app.use(
  '/api/sitiosturisticos/productos',
  productosRoutes
);

// ======================================================
// RUTA PRINCIPAL
// ======================================================

app.get(
  '/',
  (req, res) => {
    res.status(200).json({
      mensaje:
        'API Mi Ruta Cafetera funcionando correctamente',
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
// CONFIGURACIÓN DEL SERVIDOR Y MONGODB
// ======================================================

const PORT = Number(process.env.PORT) || 3000;

const MONGO_URI =
  process.env.MONGO_URI ||
  'mongodb://127.0.0.1:27017/mirutacafetera';

// ======================================================
// CONEXIÓN A MONGODB E INICIO DEL SERVIDOR
// ======================================================

const iniciarServidor = async () => {
  try {
    await mongoose.connect(MONGO_URI);

    console.log('==========================================');
    console.log('✅ MongoDB conectado correctamente');
    console.log(`📦 Base de datos: ${mongoose.connection.name}`);
    console.log('==========================================');

    const servidor = app.listen(PORT, '0.0.0.0', () => {
      console.log('==========================================');
      console.log(`🚀 Servidor escuchando en el puerto ${PORT}`);
      console.log(`🏠 API local: http://localhost:${PORT}`);
      console.log(`📱 API para emulador: http://10.0.2.2:${PORT}`);
      console.log(`❤️ Health check: http://localhost:${PORT}/api/health`);
      console.log('🔐 Login administrador: /api/admin/administradores');
      console.log('📋 Actividades: /api/admin/actividades');
      console.log('📝 Moderación: /api/admin/moderacion-contenidos');
      console.log('🤖 Chatbot administrador: /api/admin/chatbot');
      console.log('==========================================');
    });

    servidor.on('error', (error) => {
      console.error(
        '❌ Error al iniciar el servidor:',
        error.message
      );

      if (error.code === 'EADDRINUSE') {
        console.error(`⚠️ El puerto ${PORT} ya está ocupado.`);
      }

      process.exitCode = 1;
    });
  } catch (error) {
    console.error('==========================================');
    console.error('❌ ERROR AL CONECTAR CON MONGODB');
    console.error(error.message);
    console.error('==========================================');

    process.exitCode = 1;
  }
};

iniciarServidor();
