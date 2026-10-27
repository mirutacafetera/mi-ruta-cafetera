import 'package:flutter/material.dart';

import '../../../l10n/textos.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_dimensions.dart';

// =====================================================
// COMPONENTES COMPARTIDOS DEL DETALLE DEL SITIO
//
// Reúnen lo que antes estaba repetido en la pantalla del
// sitio, el detalle de actividades, productos, historias y
// el detalle desde el mapa. Todos usan los colores y las
// medidas definidas en lib/theme/.
// =====================================================

/// Une la imagen principal con las adicionales, sin vacías
/// ni repetidas y conservando el orden.
List<String> unirImagenesDetalle(
  String principal,
  Iterable<String> otras,
) {
  final resultado = <String>[];
  final primera = principal.trim();

  if (primera.isNotEmpty) {
    resultado.add(primera);
  }

  for (final imagen in otras) {
    final url = imagen.trim();

    if (url.isNotEmpty && !resultado.contains(url)) {
      resultado.add(url);
    }
  }

  return resultado;
}

/// Precio en pesos colombianos con separador de miles.
/// Ejemplo: 25000 → "$ 25.000 COP".
String formatearPrecioCop(num valor) {
  final esEntero = valor % 1 == 0;
  final texto = valor.toStringAsFixed(esEntero ? 0 : 2);
  final partes = texto.split('.');

  final miles = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );

  final numero = partes.length > 1 ? '$miles,${partes[1]}' : miles;

  return Textos.t('\$ {0} COP', [numero]);
}

/// Decoración de las tarjetas del detalle del sitio.
BoxDecoration decoracionTarjetaDetalle({
  Color color = AppColors.sitioSurface,
  double radio = AppDimensions.sitioPanelCardRadius,
  bool conSombra = true,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radio),
    border: Border.all(color: AppColors.sitioBorder),
    boxShadow: conSombra
        ? const [
            BoxShadow(
              color: AppColors.sitioCardShadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ]
        : null,
  );
}

// =====================================================
// ENCABEZADO DE SECCIÓN
// =====================================================

class EncabezadoSeccionDetalle extends StatelessWidget {
  const EncabezadoSeccionDetalle({
    super.key,
    required this.icono,
    required this.titulo,
    this.descripcion,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.pageHorizontal,
    ),
  });

  final IconData icono;
  final String titulo;
  final String? descripcion;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final texto = descripcion?.trim() ?? '';

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppDimensions.sitioHeaderIconSize,
            height: AppDimensions.sitioHeaderIconSize,
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.sitioBorder),
            ),
            child: Icon(
              icono,
              color: AppColors.sitioPrimary,
              size: AppDimensions.iconLg,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.sitioPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
                if (texto.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    texto,
                    style: const TextStyle(
                      color: AppColors.sitioTextSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppDimensions.spacingSm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// =====================================================
// ETIQUETA (CHIP)
// =====================================================

class EtiquetaDetalle extends StatelessWidget {
  const EtiquetaDetalle({
    super.key,
    required this.texto,
    this.icono,
    this.traducir = false,
    this.mayusculas = false,
  });

  /// Si [traducir] es verdadero, [texto] es una clave de traducción;
  /// si no, es un dato (por ejemplo, una etiqueta que viene de MongoDB).
  final String texto;
  final IconData? icono;
  final bool traducir;
  final bool mayusculas;

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(
      color: AppColors.sitioPrimary,
      fontSize: mayusculas ? 11 : 12,
      fontWeight: mayusculas ? FontWeight.w800 : FontWeight.w700,
      letterSpacing: mayusculas ? 0.6 : 0.2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.badgeHorizontalPadding,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.sitioSurfaceGreen,
        borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
        border: Border.all(color: AppColors.sitioBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(
              icono,
              size: AppDimensions.iconSm,
              color: AppColors.sitioPrimary,
            ),
            const SizedBox(width: AppDimensions.spacingXs + 2),
          ],
          Flexible(
            child: traducir
                ? Tr(
                    texto,
                    style: estilo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    texto,
                    style: estilo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// FILA DE DATO (ícono + título + valor)
// =====================================================

class FilaDatoDetalle extends StatelessWidget {
  const FilaDatoDetalle({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
  });

  final IconData icono;
  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: decoracionTarjetaDetalle(
        color: AppColors.sitioSurfaceSoft,
        radio: AppDimensions.radiusMd,
        conSombra: false,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSm + 1),
            decoration: BoxDecoration(
              color: AppColors.sitioSurfaceGreen,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              icono,
              color: AppColors.sitioPrimary,
              size: AppDimensions.iconMd,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColors.sitioTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  valor,
                  style: const TextStyle(
                    color: AppColors.sitioTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// TARJETA DE ESTADO (cargando con error, vacío, etc.)
// =====================================================

class TarjetaEstadoDetalle extends StatelessWidget {
  const TarjetaEstadoDetalle({
    super.key,
    required this.icono,
    required this.titulo,
    this.descripcion,
    this.accion,
  });

  final IconData icono;
  final String titulo;
  final String? descripcion;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final texto = descripcion?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: decoracionTarjetaDetalle(
        color: AppColors.sitioSurfaceSoft,
        conSombra: false,
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.sitioSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sitioBorder),
            ),
            child: Icon(
              icono,
              size: AppDimensions.categoryIconLarge,
              color: AppColors.sitioPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.sitioTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (texto.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.sitioTextSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
          if (accion != null) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            accion!,
          ],
        ],
      ),
    );
  }
}

// =====================================================
// IMAGEN NO DISPONIBLE
// =====================================================

class PlaceholderImagenDetalle extends StatelessWidget {
  const PlaceholderImagenDetalle({
    super.key,
    this.icono = Icons.photo_camera_back_outlined,
    this.mensaje,
    this.compacto = false,
  });

  final IconData icono;

  /// Clave de traducción del mensaje (opcional).
  final String? mensaje;

  /// En miniaturas solo se muestra el ícono.
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sitioSurfaceGreen,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            size: compacto ? AppDimensions.iconLg : 44,
            color: AppColors.sitioPrimary,
          ),
          if (!compacto && mensaje != null) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Tr(
              mensaje!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.sitioTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =====================================================
// CARRUSEL DE IMÁGENES CON MINIATURAS
//
// Gestos en móvil; flechas visibles en pantallas amplias
// (web y escritorio), donde no se desliza con el mouse.
// =====================================================

class CarruselImagenesDetalle extends StatefulWidget {
  const CarruselImagenesDetalle({
    super.key,
    required this.imagenes,
    this.aspectRatio = 16 / 9,
    this.mostrarMiniaturas = true,
  });

  final List<String> imagenes;
  final double aspectRatio;
  final bool mostrarMiniaturas;

  @override
  State<CarruselImagenesDetalle> createState() =>
      _CarruselImagenesDetalleState();
}

class _CarruselImagenesDetalleState extends State<CarruselImagenesDetalle> {
  final PageController _controller = PageController();

  int _pagina = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ir(int destino) {
    if (destino < 0 || destino >= widget.imagenes.length) return;

    _controller.animateToPage(
      destino,
      duration: const Duration(milliseconds: AppDimensions.animationNormal),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagenes = widget.imagenes;
    final total = imagenes.length;
    final variasImagenes = total > 1;
    final mostrarFlechas =
        variasImagenes && MediaQuery.sizeOf(context).width >= 700;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: total,
                  onPageChanged: (pagina) {
                    setState(() => _pagina = pagina);
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      imagenes[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progreso) {
                        if (progreso == null) return child;

                        final esperado = progreso.expectedTotalBytes;

                        return ColoredBox(
                          color: AppColors.sitioSurfaceGreen,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.sitioPrimary,
                              value: esperado == null
                                  ? null
                                  : progreso.cumulativeBytesLoaded / esperado,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, _, _) {
                        return const PlaceholderImagenDetalle(
                          icono: Icons.broken_image_outlined,
                          mensaje: 'Imagen no disponible',
                        );
                      },
                    );
                  },
                ),
                if (mostrarFlechas) ...[
                  Positioned(
                    left: AppDimensions.spacingSm,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _FlechaCarrusel(
                        icono: Icons.chevron_left_rounded,
                        tooltip: Textos.t('Anterior'),
                        onPressed:
                            _pagina > 0 ? () => _ir(_pagina - 1) : null,
                      ),
                    ),
                  ),
                  Positioned(
                    right: AppDimensions.spacingSm,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _FlechaCarrusel(
                        icono: Icons.chevron_right_rounded,
                        tooltip: Textos.t('Siguiente'),
                        onPressed: _pagina < total - 1
                            ? () => _ir(_pagina + 1)
                            : null,
                      ),
                    ),
                  ),
                ],
                if (variasImagenes)
                  Positioned(
                    right: AppDimensions.spacingMd,
                    bottom: AppDimensions.spacingMd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMd,
                        vertical: AppDimensions.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.68),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.chipRadius,
                        ),
                      ),
                      child: Text(
                        '${_pagina + 1} / $total',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (variasImagenes && widget.mostrarMiniaturas) ...[
          const SizedBox(height: AppDimensions.spacingMd),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: total,
              separatorBuilder: (_, _) => const SizedBox(
                width: AppDimensions.spacingSm,
              ),
              itemBuilder: (context, index) {
                final seleccionada = _pagina == index;

                return Semantics(
                  button: true,
                  selected: seleccionada,
                  label: Textos.t('Foto {0} de {1}', [index + 1, total]),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _ir(index),
                      child: AnimatedContainer(
                        duration: const Duration(
                          milliseconds: AppDimensions.animationFast,
                        ),
                        width: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                          border: Border.all(
                            color: seleccionada
                                ? AppColors.sitioPrimary
                                : AppColors.sitioBorder,
                            width: seleccionada ? 3 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          imagenes[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return const PlaceholderImagenDetalle(
                              icono: Icons.broken_image_outlined,
                              compacto: true,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _FlechaCarrusel extends StatelessWidget {
  const _FlechaCarrusel({
    required this.icono,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icono;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.black.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        iconSize: AppDimensions.navigationIcon,
        color: AppColors.white,
        disabledColor: AppColors.white.withValues(alpha: 0.35),
        icon: Icon(icono),
      ),
    );
  }
}
