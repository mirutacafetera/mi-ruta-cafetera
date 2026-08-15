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

const sitioAuthRoutes =
  require('./routes/sitios/auth.routes');

const sitioTuristicoRoutes =
  require('./routes/sitios/sitioturistico.routes');

const cuentaSitiosRoutes =
  require('./routes/sitios/cuentaSitios.routes');

const informacionRoutes =
  require('./routes/sitios/informacion.routes');

const multimediaRoutes =
  require('./routes/sitios/multimedia.routes');

const actividadesRoutes =
  require('./routes/sitios/actividades.routes');

const resenasSitioRoutes =
  require('./routes/sitios/resenas.routes');

const reservasSitioRoutes =
  require('./routes/sitios/reservas.routes');

const estadisticasSitioRoutes =
  require('./routes/sitios/estadisticas.routes');

const contenidoSitioRoutes =
  require('./routes/sitios/contenido.routes');


// =====================================================
// API USUARIO
// =====================================================

// Registro
// POST /api/usuarios/registrar

// Login
// POST /api/usuarios/login

// Perfil
// GET    /api/usuarios/:id
// PUT    /api/usuarios/:id
// DELETE /api/usuarios/:id

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

// Administración de administradores
// POST   /api/admin/administradores/registrar
// POST   /api/admin/administradores/login
// GET    /api/admin/administradores/:id
// PUT    /api/admin/administradores/:id
// DELETE /api/admin/administradores/:id

app.use(
  '/api/admin/administradores',
  administradorRoutes
);


// Administración de sitios
app.use(
  '/api/admin/sitios',
  adminSitiosRoutes
);


// Administración de usuarios
app.use(
  '/api/admin/usuarios',
  adminUsuariosRoutes
);


// Administración de reseñas
app.use(
  '/api/admin/resenas',
  adminResenasRoutes
);


// Administración de contenido
app.use(
  '/api/admin/contenido',
  adminContenidoRoutes
);


// Estadísticas administrativas
app.use(
  '/api/admin/estadisticas',
  adminEstadisticasRoutes
);


// =====================================================
// API SITIOS TURÍSTICOS
// =====================================================

// Autenticación de sitios turísticos
app.use(
  '/api/sitios/auth',
  sitioAuthRoutes
);


// Información general de sitios turísticos
app.use(
  '/api/sitiosturisticos',
  sitioTuristicoRoutes
);


// Cuentas de sitios
app.use(
  '/api/cuentas-sitios',
  cuentaSitiosRoutes
);


// Información
app.use(
  '/api/sitiosturisticos/informacion',
  informacionRoutes
);


// Multimedia
app.use(
  '/api/sitiosturisticos/multimedia',
  multimediaRoutes
);


// Actividades
app.use(
  '/api/sitiosturisticos/actividades',
  actividadesRoutes
);


// Reseñas
app.use(
  '/api/sitiosturisticos/resenas',
  resenasSitioRoutes
);


// Reservas
app.use(
  '/api/sitiosturisticos/reservas',
  reservasSitioRoutes
);


// Estadísticas
app.use(
  '/api/sitiosturisticos/estadisticas',
  estadisticasSitioRoutes
);


// Contenido
app.use(
  '/api/sitiosturisticos/contenido',
  contenidoSitioRoutes
);


// =====================================================
// RUTA PRINCIPAL
// =====================================================

app.get('/', (req, res) => {

  res.json({
    mensaje: 'API Mi Ruta Cafetera funcionando correctamente'
  });

});


// =====================================================
// SERVIDOR
// =====================================================

const PORT = process.env.PORT || 3000;

mongoose
  .connect(process.env.MONGO_URI)

  .then(() => {

    console.log(
      '✅ MongoDB conectado correctamente'
    );

    app.listen(PORT, () => {

      console.log(
        `Servidor funcionando en http://localhost:${PORT} ✈️`
      );

    });

  })

  .catch((error) => {

    console.error(
      '❌ Error al conectar con MongoDB:',
      error.message
    );

  });