const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

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

const administradorRoutes = require('./routes/admin/administrador.routes');
const adminSitiosRoutes = require('./routes/admin/sitios.routes');
const adminUsuariosRoutes = require('./routes/admin/usuarios.routes');
const adminResenasRoutes = require('./routes/admin/resenas.routes');
const adminContenidoRoutes = require('./routes/admin/contenido.routes');
const adminEstadisticasRoutes = require('./routes/admin/estadisticas.routes');

const cuentaSitiosRoutes = require('./routes/sitios/cuentaSitios.routes');
const sitioTuristicoRoutes = require('./routes/sitios/sitioturistico.routes');
const informacionRoutes = require('./routes/sitios/informacion.routes');
const multimediaRoutes = require('./routes/sitios/multimedia.routes');
const actividadesRoutes = require('./routes/sitios/actividades.routes');
const resenasSitioRoutes = require('./routes/sitios/resenas.routes');
const reservasSitioRoutes = require('./routes/sitios/reservas.routes');
const estadisticasSitioRoutes = require('./routes/sitios/estadisticas.routes');
const contenidoSitioRoutes = require('./routes/sitios/contenido.routes');
const categoriaSitioRoutes = require('./routes/sitios/categoria.routes');


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

app.use('/api/admin/administradores', administradorRoutes);
app.use('/api/admin/sitios', adminSitiosRoutes);
app.use('/api/admin/usuarios', adminUsuariosRoutes);
app.use('/api/admin/resenas', adminResenasRoutes);
app.use('/api/admin/contenido', adminContenidoRoutes);
app.use('/api/admin/estadisticas', adminEstadisticasRoutes);

app.use('/api/cuentas-sitios', cuentaSitiosRoutes);

app.use('/api/sitiosturisticos', sitioTuristicoRoutes);
app.use('/api/sitiosturisticos/informacion', informacionRoutes);
app.use('/api/sitiosturisticos/multimedia', multimediaRoutes);
app.use('/api/sitiosturisticos/actividades', actividadesRoutes);
app.use('/api/sitiosturisticos/resenas', resenasSitioRoutes);
app.use('/api/sitiosturisticos/reservas', reservasSitioRoutes);
app.use('/api/sitiosturisticos/estadisticas', estadisticasSitioRoutes);
app.use('/api/sitiosturisticos/contenido', contenidoSitioRoutes);
app.use('/api/categorias-sitios', categoriaSitioRoutes);

app.get('/', (req, res) => {
    res.json({
        mensaje: 'API Mi Ruta Cafetera funcionando correctamente'
    });
});

app.use((req, res) => {
    res.status(404).json({
        mensaje: 'Ruta no encontrada',
        ruta: req.originalUrl
    });
});

const PORT = process.env.PORT || 3000;

mongoose
    .connect(process.env.MONGO_URI)
    .then(() => {
        console.log('MongoDB conectado correctamente ✅');

        app.listen(PORT, () => {
            console.log(`Servidor funcionando en http://localhost:${PORT}🚀`);
        });
    })
    .catch((error) => {
        console.error('Error al conectar con MongoDB:', error.message);
    });