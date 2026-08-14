const MapaOffline = require('../../models/usuario/mapaoffline');

// OBTENER MAPAS
const obtenerMapas = async (req, res) => {
  try {
    const mapas = await MapaOffline.find({
      usuario: req.params.usuarioId
    });

    res.json(mapas);
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener mapas offline',
      error: error.message
    });
  }
};


// GUARDAR MAPA
const guardarMapa = async (req, res) => {
  try {
    const mapa = new MapaOffline(req.body);

    await mapa.save();

    res.status(201).json({
      mensaje: 'Mapa offline guardado correctamente',
      mapa
    });
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al guardar mapa offline',
      error: error.message
    });
  }
};


// ELIMINAR MAPA
const eliminarMapa = async (req, res) => {
  try {
    const mapa = await MapaOffline.findByIdAndDelete(
      req.params.id
    );

    if (!mapa) {
      return res.status(404).json({
        mensaje: 'Mapa no encontrado'
      });
    }

    res.json({
      mensaje: 'Mapa offline eliminado correctamente'
    });
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al eliminar mapa',
      error: error.message
    });
  }
};


module.exports = {
  obtenerMapas,
  guardarMapa,
  eliminarMapa
};