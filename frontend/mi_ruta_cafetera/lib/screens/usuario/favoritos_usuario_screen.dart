import 'package:flutter/material.dart';

import '../../models/sitio_turistico_model.dart';
import '../../services/favorito_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/publico/sitio_card.dart';
import 'detalle_sitio_usuario_screen.dart';

class FavoritosUsuarioScreen extends StatefulWidget {
  final String usuarioId;
  final String token;

  const FavoritosUsuarioScreen({
    super.key,
    required this.usuarioId,
    required this.token,
  });

  @override
  State<FavoritosUsuarioScreen> createState() =>
      _FavoritosUsuarioScreenState();
}

class _FavoritosUsuarioScreenState
    extends State<FavoritosUsuarioScreen> {
  final FavoritoService _favoritoService =
      FavoritoService.instance;

  List<FavoritoItem> _favoritos = [];

  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  // ============================================================
  // CARGAR FAVORITOS
  // ============================================================

  Future<void> _cargarFavoritos() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final favoritos =
          await _favoritoService.obtenerFavoritos(
        widget.usuarioId,
        token: widget.token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _favoritos = favoritos;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cargando = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // ELIMINAR FAVORITO
  // ============================================================

  Future<void> _eliminarFavorito(
    int index,
  ) async {
    if (index < 0 ||
        index >= _favoritos.length) {
      return;
    }

    final favorito = _favoritos[index];

    try {
      await _favoritoService.eliminarFavorito(
        favorito.id,
        token: widget.token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _favoritos.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sitio eliminado de favoritos.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // ABRIR DETALLE
  // ============================================================

  Future<void> _abrirDetalle(
    FavoritoItem favorito,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DetalleSitioUsuarioScreen(
          sitio: favorito.sitio,
          imagen: _imagenSitio(
            favorito.sitio,
          ),
          esFavorito: true,
          onFavorite: () async {
            await _eliminarFavoritoPorId(
              favorito.id,
            );
          },
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    await _cargarFavoritos();
  }

  // ============================================================
  // ELIMINAR FAVORITO POR ID
  // ============================================================

  Future<void> _eliminarFavoritoPorId(
    String favoritoId,
  ) async {
    await _favoritoService.eliminarFavorito(
      favoritoId,
      token: widget.token,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _favoritos.removeWhere(
        (favorito) =>
            favorito.id == favoritoId,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sitio eliminado de favoritos.',
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Mis favoritos',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _construirContenido(),
    );
  }

  Widget _construirContenido() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _estadoError();
    }

    if (_favoritos.isEmpty) {
      return _estadoVacio();
    }

    return RefreshIndicator(
      onRefresh: _cargarFavoritos,
      child: ListView.separated(
        padding: const EdgeInsets.all(
          AppDimensions.spacingMd,
        ),
        itemCount: _favoritos.length,
        separatorBuilder: (_, _) =>
            const SizedBox(
          height: AppDimensions.spacingMd,
        ),
        itemBuilder: (
          context,
          index,
        ) {
          final favorito =
              _favoritos[index];

          final sitio =
              favorito.sitio;

          return SitioCard(
            sitio: sitio,
            imagen: _imagenSitio(sitio),
            onFavorite: () =>
                _eliminarFavorito(index),
            onTap: () =>
                _abrirDetalle(favorito),
          );
        },
      ),
    );
  }

  // ============================================================
  // ESTADO VACÍO
  // ============================================================

  Widget _estadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            Text(
              'Aún no tienes favoritos',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppDimensions.spacingSm,
            ),
            Text(
              'Guarda los sitios que quieras '
              'visitar para encontrarlos '
              'fácilmente.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO ERROR
  // ============================================================

  Widget _estadoError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AppDimensions.spacingLg,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            const Text(
              'No pudimos cargar tus favoritos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: AppDimensions.spacingMd,
            ),
            ElevatedButton(
              onPressed: _cargarFavoritos,
              child: const Text(
                'Intentar nuevamente',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMAGEN DEL SITIO
  // ============================================================

  String _imagenSitio(
    SitioTuristicoModel sitio,
  ) {
    final categoria =
        _normalizarTexto(
      sitio.categoriaNombre,
    );

    if (categoria.contains('cafe')) {
      return 'assets/images/sitios/cafe.jpg';
    }

    if (categoria.contains('artesania')) {
      return 'assets/images/sitios/artesanias.jpg';
    }

    if (categoria.contains('gastronom')) {
      return 'assets/images/sitios/gastronomia.jpeg';
    }

    if (categoria.contains('alojamiento') ||
        categoria.contains('hotel') ||
        categoria.contains('hospedaje')) {
      return 'assets/images/sitios/alojamiento.jpg';
    }

    if (categoria.contains('famil')) {
      return 'assets/images/sitios/familiares.jpeg';
    }

    if (categoria.contains('naturaleza') ||
        categoria.contains('ecoturismo') ||
        categoria.contains('senderismo')) {
      return 'assets/images/sitios/naturaleza.jpeg';
    }

    if (categoria.contains('cultura') ||
        categoria.contains('historia') ||
        categoria.contains('patrimonio')) {
      return 'assets/images/sitios/cultura.jpg';
    }

    if (categoria.contains('aventura')) {
      return 'assets/images/sitios/aventuras.jpeg';
    }

    if (categoria.contains('mirador') ||
        categoria.contains('paisaje')) {
      return 'assets/images/sitios/miradores.jpeg';
    }

    return 'assets/images/bienvenida/paisaje.jpg';
  }

  String _normalizarTexto(
    String texto,
  ) {
    return texto
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('ñ', 'n')
        .replaceAll('Ñ', 'N')
        .toLowerCase()
        .trim();
  }
}