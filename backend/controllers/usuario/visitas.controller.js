const Visita = require('../../models/usuario/visita');

// OBTENER VISITAS DEL USUARIO
const obtenerVisitas = async (req, res) => {
  try {
    const visitas = await Visita.find({
      usuario: req.params.usuarioId
    })
      .populate('sitio')
      .sort({ fechaVisita: -1 });

    res.json(visitas);

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al obtener visitas',
      error: error.message
    });
  }
};


// REGISTRAR VISITA
const registrarVisita = async (req, res) => {
  try {
    const visita = new Visita(req.body);

    await visita.save();

    res.status(201).json({
      mensaje: 'Visita registrada correctamente',
      visita
    });

  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al registrar visita',
      error: error.message
    });
  }
};


module.exports = {
  obtenerVisitas,
  registrarVisita
};