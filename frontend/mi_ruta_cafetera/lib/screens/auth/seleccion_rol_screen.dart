import 'package:flutter/material.dart';

import '../admin/admin_acceso_screen.dart';
import '../usuario/login_usuario_screen.dart';

class SeleccionRolScreen extends StatelessWidget {
  const SeleccionRolScreen({
    super.key,
  });

  // ============================================================
  // MENSAJE
  // ============================================================

  void _mostrarMensaje(
    BuildContext context,
    String mensaje,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown.shade700,
              Colors.brown.shade400,
              Colors.brown.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // =====================================================
                        // ICONO
                        // =====================================================

                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.brown.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_cafe_rounded,
                            size: 50,
                            color: Colors.brown.shade700,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =====================================================
                        // TITULO
                        // =====================================================

                        Text(
                          'Mi Ruta Mágica del Café',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade800,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Bienvenido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Selecciona cómo deseas ingresar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // =====================================================
                        // VISITANTE
                        // =====================================================

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const LoginUsuarioScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.person_rounded,
                            ),
                            label: const Text(
                              'Soy visitante',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.brown.shade700,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // =====================================================
                        // ADMINISTRADOR
                        // =====================================================

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AdminAccesoScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.admin_panel_settings_rounded,
                            ),
                            label: const Text(
                              'Administrador',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Colors.brown.shade700,
                              side: BorderSide(
                                color: Colors.brown.shade700,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // =====================================================
                        // SITIO TURÍSTICO
                        // =====================================================

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _mostrarMensaje(
                                context,
                                'Acceso de sitio turístico próximamente',
                              );
                            },
                            icon: const Icon(
                              Icons.storefront_rounded,
                            ),
                            label: const Text(
                              'Sitio turístico',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Colors.brown.shade700,
                              side: BorderSide(
                                color: Colors.brown.shade700,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // =====================================================
                        // VOLVER
                        // =====================================================

                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                          ),
                          label: const Text(
                            'Volver',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Colors.brown.shade700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // =====================================================
                        // PIE
                        // =====================================================

                        Text(
                          'Mi Ruta Mágica del Café',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}