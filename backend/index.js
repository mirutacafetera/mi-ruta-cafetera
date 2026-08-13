const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

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

const adminAuthRoutes = require('./routes/admin/auth.routes');
const adminSitiosRoutes = require('./routes/admin/sitios.routes');
const adminUsuariosRoutes = require('./routes/admin/usuarios.routes');
const adminResenasRoutes = require('./routes/admin/resenas.routes');
const adminContenidoRoutes = require('./routes/admin/contenido.routes');
const adminEstadisticasRoutes = require('./routes/admin/estadisticas.routes');

const sitioTuristicoRoutes = require('./routes/sitios/sitioturistico.routes');
const informacionRoutes = require('./routes/sitios/informacion.routes');
const multimediaRoutes = require('./routes/sitios/multimedia.routes');
const actividadesRoutes = require('./routes/sitios/actividades.routes');
const resenasSitioRoutes = require('./routes/sitios/resenas.routes');
const reservasSitioRoutes = require('./routes/sitios/reservas.routes');
const estadisticasSitioRoutes = require('./routes/sitios/estadisticas.routes');
const contenidoSitioRoutes = require('./routes/sitios/contenido.routes');

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

app.use('/api/admin/auth', adminAuthRoutes);
app.use('/api/admin/sitios', adminSitiosRoutes);
app.use('/api/admin/usuarios', adminUsuariosRoutes);
app.use('/api/admin/resenas', adminResenasRoutes);
app.use('/api/admin/contenido', adminContenidoRoutes);
app.use('/api/admin/estadisticas', adminEstadisticasRoutes);

app.use('/api/sitiosturisticos', sitioTuristicoRoutes);
app.use('/api/sitiosturisticos/informacion', informacionRoutes);
app.use('/api/sitiosturisticos/multimedia', multimediaRoutes);
app.use('/api/sitiosturisticos/actividades', actividadesRoutes);
app.use('/api/sitiosturisticos/resenas', resenasSitioRoutes);
app.use('/api/sitiosturisticos/reservas', reservasSitioRoutes);
app.use('/api/sitiosturisticos/estadisticas', estadisticasSitioRoutes);
app.use('/api/sitiosturisticos/contenido', contenidoSitioRoutes);

app.get('/', (req, res) => {
  res.json({
    mensaje: 'API Mi Ruta Cafetera funcionando correctamente'
  });
});

const PORT = process.env.PORT || 3000;

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB conectado correctamente');
  })
  .catch((error) => {
    console.error('Error al conectar con MongoDB:');
    console.error(error.message);
  })
  .finally(() => {
    app.listen(PORT, () => {
      console.log(`Servidor funcionando en http://localhost:${PORT}`);
    });
  });