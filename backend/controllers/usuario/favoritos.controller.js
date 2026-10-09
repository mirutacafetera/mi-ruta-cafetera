const mongoose = require('mongoose');

const Favorito = require('../../models/usuario/favorito');

/**
 * =========================================================
 * OBTENER FAVORITOS DEL USUARIO AUTENTICADO
 * =========================================================
 *
 * GET
 * /api/favoritos/:usuarioId
 *
 * El usuarioId de la URL se conserva para no romper
 * la integración actual de Flutter.
 *
 * Sin embargo, la identidad real del usuario se obtiene
 * desde el JWT mediante req.usuario.id.
 */
const obtenerFavoritos = async (req, res) => {
  try {
    const usuarioAutenticado = req.usuario?.id;
    const usuarioSolicitado = req.params.usuarioId;

    if (!usuarioAutenticado) {
      return res.status(401).json({
        mensaje: 'Usuario no autenticado'
      });
    }

    if (!usuarioSolicitado) {
      return res.status(400).json({
        mensaje: 'No se proporcionó el usuario'
      });
    }

    if (
      !mongoose.Types.ObjectId.isValid(
        usuarioSolicitado
      )
    ) {
      return res.status(400).json({
        mensaje: 'Identificador de usuario inválido'
      });
    }

    /*
     * Evitamos que un usuario consulte los favoritos
     * pertenecientes a otra cuenta.
     */
    if (
      usuarioAutenticado.toString() !==
      usuarioSolicitado.toString()
    ) {
      return res.status(403).json({
        mensaje:
          'No tienes permiso para consultar estos favoritos'
      });
    }

    const favoritos = await Favorito.find({
      usuario: usuarioAutenticado
    })
      .populate('sitio')
      .sort({ createdAt: -1 });

    return res.status(200).json(favoritos);

  } catch (error) {
    console.error(
      'Error al obtener favoritos:',
      error
    );

    return res.status(500).json({
      mensaje: 'Error al obtener favoritos',
      error: error.message
    });
  }
};


/**
 * =========================================================
 * AGREGAR FAVORITO
 * =========================================================
 *
 * POST
 * /api/favoritos
 *
 * Body esperado desde Flutter:
 *
 * {
 *   "usuario": "...",
 *   "sitio": "..."
 * }
 *
 * El campo usuario se conserva por compatibilidad,
 * pero NO se utiliza para determinar el propietario.
 *
 * El propietario real será req.usuario.id.
 */
const agregarFavorito = async (req, res) => {
  try {
    const usuario = req.usuario?.id;
    const { sitio } = req.body;

    if (!usuario) {
      return res.status(401).json({
        mensaje: 'Usuario no autenticado'
      });
    }

    if (!sitio) {
      return res.status(400).json({
        mensaje:
          'Debes proporcionar el sitio que deseas agregar'
      });
    }

    if (
      !mongoose.Types.ObjectId.isValid(sitio)
    ) {
      return res.status(400).json({
        mensaje:
          'El identificador del sitio no es válido'
      });
    }

    /*
     * Evitar duplicados.
     */
    const existe = await Favorito.findOne({
      usuario,
      sitio
    });

    if (existe) {
      return res.status(400).json({
        mensaje:
          'El sitio ya está en favoritos'
      });
    }

    const favorito = new Favorito({
      usuario,
      sitio
    });

    await favorito.save();

    /*
     * Devolvemos también el sitio completo para que
     * Flutter pueda utilizar inmediatamente la respuesta.
     */
    await favorito.populate('sitio');

    return res.status(201).json({
      mensaje:
        'Sitio agregado a favoritos',
      favorito
    });

  } catch (error) {
    console.error(
      'Error al agregar favorito:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al agregar favorito',
      error: error.message
    });
  }
};


/**
 * =========================================================
 * ELIMINAR FAVORITO
 * =========================================================
 *
 * DELETE
 * /api/favoritos/:id
 *
 * Solo el propietario del favorito puede eliminarlo.
 */
const eliminarFavorito = async (req, res) => {
  try {
    const usuario = req.usuario?.id;
    const favoritoId = req.params.id;

    if (!usuario) {
      return res.status(401).json({
        mensaje: 'Usuario no autenticado'
      });
    }

    if (
      !mongoose.Types.ObjectId.isValid(
        favoritoId
      )
    ) {
      return res.status(400).json({
        mensaje:
          'Identificador de favorito inválido'
      });
    }

    /*
     * Buscamos por ID del favorito Y por usuario.
     *
     * Esto impide que un usuario elimine favoritos
     * pertenecientes a otra cuenta.
     */
    const favorito =
      await Favorito.findOneAndDelete({
        _id: favoritoId,
        usuario
      });

    if (!favorito) {
      return res.status(404).json({
        mensaje:
          'Favorito no encontrado o no tienes permiso para eliminarlo'
      });
    }

    return res.status(200).json({
      mensaje:
        'Sitio eliminado de favoritos'
    });

  } catch (error) {
    console.error(
      'Error al eliminar favorito:',
      error
    );

    return res.status(500).json({
      mensaje:
        'Error al eliminar favorito',
      error: error.message
    });
  }
};


/**
 * =========================================================
 * EXPORTAR
 * =========================================================
 */

module.exports = {
  obtenerFavoritos,
  agregarFavorito,
  eliminarFavorito
};