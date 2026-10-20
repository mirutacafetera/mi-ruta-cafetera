import 'package:flutter/material.dart';

import '../../models/usuario/avatar_cafetero_model.dart';
import '../../models/usuario/usuario_sesion_model.dart';
import '../../services/usuario/perfil_usuario_service.dart';
import '../../services/usuario/usuario_sesion_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/usuario/avatar_cafetero.dart';
import '../../widgets/usuario/avatar_cafetero_painter.dart';

// ============================================================
// CREAR / EDITAR AVATAR CAFETERO
// ============================================================
//
// Permite personalizar el avatar y decidir si se usa como foto
// de perfil. La foto de Google NO se modifica ni se elimina:
// solo se deja de mostrar mientras "usar avatar" esté activo.
// ============================================================

enum _Categoria {
  piel('Piel', Icons.face_rounded),
  peinado('Peinado', Icons.content_cut_rounded),
  colorPelo('Cabello', Icons.palette_rounded),
  ropa('Ropa', Icons.checkroom_rounded),
  sombrero('Sombrero', Icons.sports_baseball_rounded),
  accesorio('Accesorio', Icons.coffee_rounded),
  fondo('Fondo', Icons.landscape_rounded);

  const _Categoria(this.titulo, this.icono);

  final String titulo;
  final IconData icono;
}

class CrearAvatarScreen extends StatefulWidget {
  const CrearAvatarScreen({
    super.key,
  });

  @override
  State<CrearAvatarScreen> createState() =>
      _CrearAvatarScreenState();
}

class _CrearAvatarScreenState extends State<CrearAvatarScreen> {
  late AvatarCafeteroModel _avatar;
  late final AvatarCafeteroModel _original;
  late final bool _tieneFoto;

  _Categoria _categoria = _Categoria.piel;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();

    final UsuarioSesionModel? sesion =
        UsuarioSesionService.instance.sesionActual.value;

    // Si nunca configuró un avatar, al guardar se activa por
    // defecto: crearlo es señal de que quiere usarlo.
    final existente = sesion?.avatar;

    _original = existente ?? const AvatarCafeteroModel();
    _avatar = existente ?? const AvatarCafeteroModel(usar: true);
    _tieneFoto = (sesion?.fotoPerfil ?? '').trim().isNotEmpty;
  }

  bool get _huboCambios => _avatar != _original;

  // ============================================================
  // OPCIONES POR CATEGORÍA
  // ============================================================

  List<String> _opciones(_Categoria c) {
    switch (c) {
      case _Categoria.piel:
        return AvatarCafeteroModel.pieles;
      case _Categoria.peinado:
        return AvatarCafeteroModel.peinados;
      case _Categoria.colorPelo:
        return AvatarCafeteroModel.coloresPelo;
      case _Categoria.ropa:
        return AvatarCafeteroModel.ropas;
      case _Categoria.sombrero:
        return AvatarCafeteroModel.sombreros;
      case _Categoria.accesorio:
        return AvatarCafeteroModel.accesorios;
      case _Categoria.fondo:
        return AvatarCafeteroModel.fondos;
    }
  }

  String _valorActual(_Categoria c) {
    switch (c) {
      case _Categoria.piel:
        return _avatar.piel;
      case _Categoria.peinado:
        return _avatar.peinado;
      case _Categoria.colorPelo:
        return _avatar.colorPelo;
      case _Categoria.ropa:
        return _avatar.ropa;
      case _Categoria.sombrero:
        return _avatar.sombrero;
      case _Categoria.accesorio:
        return _avatar.accesorio;
      case _Categoria.fondo:
        return _avatar.fondo;
    }
  }

  AvatarCafeteroModel _con(
    AvatarCafeteroModel base,
    _Categoria c,
    String id,
  ) {
    switch (c) {
      case _Categoria.piel:
        return base.copyWith(piel: id);
      case _Categoria.peinado:
        return base.copyWith(peinado: id);
      case _Categoria.colorPelo:
        return base.copyWith(colorPelo: id);
      case _Categoria.ropa:
        return base.copyWith(ropa: id);
      case _Categoria.sombrero:
        return base.copyWith(sombrero: id);
      case _Categoria.accesorio:
        return base.copyWith(accesorio: id);
      case _Categoria.fondo:
        return base.copyWith(fondo: id);
    }
  }

  // Categorías que se muestran como muestra de color.
  Color? _muestraColor(_Categoria c, String id) {
    switch (c) {
      case _Categoria.piel:
        return AvatarCafeteroPaleta.piel(id);
      case _Categoria.colorPelo:
        return AvatarCafeteroPaleta.pelo(id);
      case _Categoria.ropa:
        return AvatarCafeteroPaleta.ropa(id);
      default:
        return null;
    }
  }

  // ============================================================
  // GUARDAR
  // ============================================================

  Future<void> _guardar() async {
    if (_guardando) {
      return;
    }

    setState(() => _guardando = true);

    final resultado =
        await PerfilUsuarioService.actualizarAvatar(_avatar);

    if (!mounted) {
      return;
    }

    setState(() => _guardando = false);

    final mensaje = (resultado['mensaje'] ?? '').toString();

    if (resultado['exito'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensaje.isEmpty ? 'Avatar guardado.' : mensaje,
          ),
        ),
      );

      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content: Text(
          mensaje.isEmpty
              ? 'No fue posible guardar el avatar.'
              : mensaje,
        ),
      ),
    );
  }

  Future<bool> _confirmarSalida() async {
    if (!_huboCambios) {
      return true;
    }

    final salir = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('¿Descartar cambios?'),
          content: const Text(
            'Tienes cambios sin guardar en tu avatar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Seguir editando'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Descartar'),
            ),
          ],
        );
      },
    );

    return salir == true;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_huboCambios,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }

        final navigator = Navigator.of(context);
        final salir = await _confirmarSalida();

        if (salir && mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mi avatar cafetero'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(
                    AppDimensions.pageHorizontal,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _construirVistaPrevia(),
                      const SizedBox(
                        height: AppDimensions.spacingLg,
                      ),
                      _construirUso(),
                      const SizedBox(
                        height: AppDimensions.sectionGap,
                      ),
                      _construirCategorias(),
                      const SizedBox(
                        height: AppDimensions.spacingLg,
                      ),
                      _construirOpciones(),
                    ],
                  ),
                ),
              ),
              _construirBarraGuardar(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // VISTA PREVIA
  // ============================================================

  Widget _construirVistaPrevia() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      decoration: BoxDecoration(
        color: AppColors.surfaceGreen,
        borderRadius: BorderRadius.circular(
          AppDimensions.heroRadius,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingXs),
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          child: AvatarCafetero(
            avatar: _avatar,
            size: 180,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // USAR AVATAR COMO FOTO DE PERFIL
  // ============================================================

  Widget _construirUso() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(
          AppDimensions.cardRadius,
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: _avatar.usar,
        onChanged: (valor) {
          setState(() => _avatar = _avatar.copyWith(usar: valor));
        },
        activeThumbColor: AppColors.secondary,
        title: const Text(
          'Usar mi avatar como foto de perfil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          _tieneFoto
              ? 'Tu foto de Google no se elimina; puedes volver a '
                  'mostrarla cuando quieras.'
              : 'Se mostrará en tu perfil y en tus reseñas.',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORÍAS
  // ============================================================

  Widget _construirCategorias() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _Categoria.values.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, indice) {
          final c = _Categoria.values[indice];
          final activa = c == _categoria;

          return ChoiceChip(
            selected: activa,
            onSelected: (_) => setState(() => _categoria = c),
            avatar: Icon(
              c.icono,
              size: AppDimensions.iconSm,
              color: activa ? AppColors.white : AppColors.primary,
            ),
            label: Text(c.titulo),
            labelStyle: TextStyle(
              color: activa ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.cream,
            showCheckmark: false,
            side: const BorderSide(color: AppColors.border),
          );
        },
      ),
    );
  }

  // ============================================================
  // OPCIONES
  // ============================================================

  Widget _construirOpciones() {
    final opciones = _opciones(_categoria);
    final actual = _valorActual(_categoria);

    return Wrap(
      spacing: AppDimensions.spacingMd,
      runSpacing: AppDimensions.spacingMd,
      children: [
        for (final id in opciones)
          _OpcionAvatar(
            etiqueta: AvatarCafeteroModel.etiqueta(id),
            seleccionada: id == actual,
            color: _muestraColor(_categoria, id),
            vistaPrevia: _con(_avatar, _categoria, id),
            onTap: () {
              setState(() {
                _avatar = _con(_avatar, _categoria, id);
              });
            },
          ),
      ],
    );
  }

  // ============================================================
  // BARRA INFERIOR
  // ============================================================

  Widget _construirBarraGuardar() {
    final puedeGuardar = !_guardando && _huboCambios;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pageHorizontal,
        AppDimensions.spacingMd,
        AppDimensions.pageHorizontal,
        AppDimensions.spacingMd,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SizedBox(
        height: AppDimensions.buttonHeightLarge,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: puedeGuardar ? _guardar : null,
          icon: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check_rounded),
          label: Text(_guardando ? 'Guardando…' : 'Guardar avatar'),
        ),
      ),
    );
  }
}

// ======================================================================
// OPCIÓN INDIVIDUAL
// ======================================================================

class _OpcionAvatar extends StatelessWidget {
  final String etiqueta;
  final bool seleccionada;
  final Color? color;
  final AvatarCafeteroModel vistaPrevia;
  final VoidCallback onTap;

  const _OpcionAvatar({
    required this.etiqueta,
    required this.seleccionada,
    required this.color,
    required this.vistaPrevia,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const lado = 72.0;

    final contenido = color != null
        ? Container(
            width: lado - 16,
            height: lado - 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
          )
        : AvatarCafetero(avatar: vistaPrevia, size: lado - 8);

    return Semantics(
      button: true,
      selected: seleccionada,
      label: etiqueta,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: SizedBox(
          width: lado + 8,
          child: Column(
            children: [
              Container(
                width: lado,
                height: lado,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: seleccionada
                        ? AppColors.secondary
                        : AppColors.border,
                    width: seleccionada ? 3 : 1,
                  ),
                ),
                child: contenido,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                etiqueta,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: seleccionada
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight:
                      seleccionada ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
