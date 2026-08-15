const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

require('dotenv').config();

const app = express();


// =====================================================
// MIDDLEWARES
// =====================================================

app.use(cors());
app.use(express.json());

<<<<<<< HEAD
// RUTAS DE USUARIO
const authRoutes = require('./routes/usuario/auth.routes');
const usuarioRoutes = require('./routes/usuario/usuario.routes');
const categoriaRoutes = require('./routes/usuario/categoria.routes');
const sitioRoutes = require('./routes/usuario/sitio.routes');
const resenaRoutes = require('./routes/usuario/resena.routes');
const favoritoRoutes = require('./routes/usuario/favorito.routes');
const mapaOfflineRoutes = require('./routes/usuario/mapasoffline.routes');
const notificacionRoutes = require('./routes/usuario/notificacion.routes');
const reservaRoutes = require('./routes/usuario/reserva.routes');
const rutaRoutes = require('./routes/usuario/ruta.routes');
const visitaRoutes = require('./routes/usuario/visita.routes');

// RUTAS DE ADMINISTRADOR
const adminAuthRoutes = require('./routes/admin/auth.routes');
const administradorRoutes = require('./routes/admin/administrador.routes');
const adminSitiosRoutes = require('./routes/admin/sitios.routes');
const adminUsuariosRoutes = require('./routes/admin/usuarios.routes');
const adminResenasRoutes = require('./routes/admin/resenas.routes');
const adminContenidoRoutes = require('./routes/admin/contenido.routes');
const adminEstadisticasRoutes = require('./routes/admin/estadisticas.routes');

// RUTAS DE SITIOS TURÍSTICOS
const sitioAuthRoutes = require('./routes/sitios/auth.routes');
const sitioTuristicoRoutes = require('./routes/sitios/sitioturistico.routes');
const informacionRoutes = require('./routes/sitios/informacion.routes');
const multimediaRoutes = require('./routes/sitios/multimedia.routes');
const actividadesRoutes = require('./routes/sitios/actividades.routes');
const resenasSitioRoutes = require('./routes/sitios/resenas.routes');
const reservasSitioRoutes = require('./routes/sitios/reservas.routes');
const estadisticasSitioRoutes = require('./routes/sitios/estadisticas.routes');
const contenidoSitioRoutes = require('./routes/sitios/contenido.routes');

// ENDPOINTS DE USUARIO
app.use('/api/auth', authRoutes);
app.use('/api/usuarios', usuarioRoutes);
app.use('/api/categorias', categoriaRoutes);
app.use('/api/sitios', sitioRoutes);
app.use('/api/resenas', resenaRoutes);
app.use('/api/favoritos', favoritoRoutes);
app.use('/api/mapas-offline', mapaOfflineRoutes);
app.use('/api/notificaciones', notificacionRoutes);
app.use('/api/reservas', reservaRoutes);
app.use('/api/rutas', rutaRoutes);
app.use('/api/visitas', visitaRoutes);

// ENDPOINTS DE ADMINISTRADOR
app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/administradores', administradorRoutes);
app.use('/api/admin/sitios', adminSitiosRoutes);
app.use('/api/admin/usuarios', adminUsuariosRoutes);
app.use('/api/admin/resenas', adminResenasRoutes);
app.use('/api/admin/contenido', adminContenidoRoutes);
app.use('/api/admin/estadisticas', adminEstadisticasRoutes);

// ENDPOINTS DE SITIOS TURÍSTICOS
app.use('/api/sitios/auth', sitioAuthRoutes);
app.use('/api/sitiosturisticos', sitioTuristicoRoutes);
app.use('/api/sitiosturisticos/informacion', informacionRoutes);
app.use('/api/sitiosturisticos/multimedia', multimediaRoutes);
app.use('/api/sitiosturisticos/actividades', actividadesRoutes);
app.use('/api/sitiosturisticos/resenas', resenasSitioRoutes);
app.use('/api/sitiosturisticos/reservas', reservasSitioRoutes);
app.use('/api/sitiosturisticos/estadisticas', estadisticasSitioRoutes);
app.use('/api/sitiosturisticos/contenido', contenidoSitioRoutes);
=======

// =====================================================
// RUTAS DE USUARIO
// =====================================================

const usuarioRoutes =
  require('./routes/usuario/usuario.routes');

const categoriaRoutes =
  require('./routes/usuario/categoria.routes');

const sitioRoutes =
  require('./routes/usuario/sitio.routes');

const resenaRoutes =
  require('./routes/usuario/resena.routes');

const favoritoRoutes =
  require('./routes/usuario/favorito.routes');

const mapaOfflineRoutes =
  require('./routes/usuario/mapasoffline.routes');

const notificacionRoutes =
  require('./routes/usuario/notificacion.routes');

const reservaRoutes =
  require('./routes/usuario/reserva.routes');

const rutaRoutes =
  require('./routes/usuario/ruta.routes');

const visitaRoutes =
  require('./routes/usuario/visita.routes');


// =====================================================
// RUTAS DE ADMINISTRADOR
// =====================================================

const administradorRoutes =
  require('./routes/admin/administrador.routes');

const adminSitiosRoutes =
  require('./routes/admin/sitios.routes');

const adminUsuariosRoutes =
  require('./routes/admin/usuarios.routes');

const adminResenasRoutes =
  require('./routes/admin/resenas.routes');

const adminContenidoRoutes =
  require('./routes/admin/contenido.routes');

const adminEstadisticasRoutes =
  require('./routes/admin/estadisticas.routes');


// =====================================================
// RUTAS DE SITIOS TURÍSTICOS
// =====================================================

// Cuenta del sitio / Login
const cuentaSitiosRoutes =
  require('./routes/sitios/cuentaSitios.routes');

// Información general del sitio turístico
const sitioTuristicoRoutes =
  require('./routes/sitios/sitioturistico.routes');

// Información adicional
const informacionRoutes =
  require('./routes/sitios/informacion.routes');

// Multimedia
const multimediaRoutes =
  require('./routes/sitios/multimedia.routes');

// Actividades
const actividadesRoutes =
  require('./routes/sitios/actividades.routes');

// Reseñas
const resenasSitioRoutes =
  require('./routes/sitios/resenas.routes');

// Reservas
const reservasSitioRoutes =
  require('./routes/sitios/reservas.routes');

// Estadísticas
const estadisticasSitioRoutes =
  require('./routes/sitios/estadisticas.routes');

// Contenido
const contenidoSitioRoutes =
  require('./routes/sitios/contenido.routes');


// =====================================================
// API USUARIO
// =====================================================

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


// =====================================================
// API ADMINISTRADOR
// =====================================================

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


// =====================================================
// API CUENTA DE SITIOS TURÍSTICOS
// =====================================================

// Login:
// POST /api/cuentas-sitios/login

app.use(
  '/api/cuentas-sitios',
  cuentaSitiosRoutes
);


// =====================================================
// API SITIOS TURÍSTICOS
// =====================================================

// GET    /api/sitiosturisticos
// GET    /api/sitiosturisticos/:id
// POST   /api/sitiosturisticos
// PUT    /api/sitiosturisticos/:id
// PATCH  /api/sitiosturisticos/:id/activar
// PATCH  /api/sitiosturisticos/:id/desactivar
// DELETE /api/sitiosturisticos/:id

app.use(
  '/api/sitiosturisticos',
  sitioTuristicoRoutes
);


// =====================================================
// INFORMACIÓN DE SITIOS
// =====================================================

app.use(
  '/api/sitiosturisticos/informacion',
  informacionRoutes
);


// =====================================================
// MULTIMEDIA
// =====================================================

app.use(
  '/api/sitiosturisticos/multimedia',
  multimediaRoutes
);


// =====================================================
// ACTIVIDADES
// =====================================================

app.use(
  '/api/sitiosturisticos/actividades',
  actividadesRoutes
);


// =====================================================
// RESEÑAS DE SITIOS
// =====================================================

app.use(
  '/api/sitiosturisticos/resenas',
  resenasSitioRoutes
);


// =====================================================
// RESERVAS DE SITIOS
// =====================================================

app.use(
  '/api/sitiosturisticos/reservas',
  reservasSitioRoutes
);


// =====================================================
// ESTADÍSTICAS DE SITIOS
// =====================================================

app.use(
  '/api/sitiosturisticos/estadisticas',
  estadisticasSitioRoutes
);


// =====================================================
// CONTENIDO DE SITIOS
// =====================================================

app.use(
  '/api/sitiosturisticos/contenido',
  contenidoSitioRoutes
);


// =====================================================
// RUTA PRINCIPAL
// =====================================================
>>>>>>> 326b3f8cbc81c005790ca8b246b18c1fdd4c4325

// RUTA PRINCIPAL
app.get('/', (req, res) => {

  res.json({
    mensaje: 'API Mi Ruta Cafetera funcionando correctamente'
  });

});

<<<<<<< HEAD
// SERVIDOR
=======

// =====================================================
// MANEJO DE RUTA NO ENCONTRADA
// =====================================================

app.use((req, res) => {

  res.status(404).json({
    mensaje: 'Ruta no encontrada',
    ruta: req.originalUrl
  });

});


// =====================================================
// CONEXIÓN A MONGODB Y SERVIDOR
// =====================================================

>>>>>>> 326b3f8cbc81c005790ca8b246b18c1fdd4c4325
const PORT = process.env.PORT || 3000;

mongoose
  .connect(process.env.MONGO_URI)

  .then(() => {

    console.log(
      '✅ MongoDB conectado correctamente'
    );

    app.listen(PORT, () => {
<<<<<<< HEAD
      console.log(`🚀 Servidor funcionando en http://localhost:${PORT}`);
=======

      console.log(
        `🚀 Servidor funcionando en http://localhost:${PORT}`
      );

>>>>>>> 326b3f8cbc81c005790ca8b246b18c1fdd4c4325
    });

  })

  .catch((error) => {

    console.error(
      '❌ Error al conectar con MongoDB:',
      error.message
    );

  });