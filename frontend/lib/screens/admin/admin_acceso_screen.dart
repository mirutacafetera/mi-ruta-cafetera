import 'package:flutter/material.dart';

import '../../services/admin/admin_login_screen.dart';

class AdminAccesoScreen extends StatelessWidget {
  const AdminAccesoScreen({super.key});

  // =====================================================
  // ABRIR LOGIN
  // =====================================================

  void _abrirLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
    );
  }

  // =====================================================
  // VOLVER
  // =====================================================

  void _volver(BuildContext context) {
    Navigator.pop(context);
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
                constraints:
                    const BoxConstraints(
                  maxWidth: 450,
                ),
                child: Card(
                  elevation: 8,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        // =================================================
                        // ICONO
                        // =================================================

                        Container(
                          width: 90,
                          height: 90,
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.brown.shade100,
                            shape:
                                BoxShape.circle,
                          ),
                          child: Icon(
                            Icons
                                .admin_panel_settings,
                            size: 52,
                            color:
                                Colors.brown.shade800,
                          ),
                        ),

                        const SizedBox(
                          height: 22,
                        ),

                        // =================================================
                        // TÍTULO
                        // =================================================

                        Text(
                          'Acceso de administrador',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Colors.brown.shade900,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Text(
                          'Esta sección está destinada únicamente a administradores autorizados.',
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color:
                                Colors.grey.shade700,
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // =================================================
                        // INICIAR SESIÓN
                        // =================================================

                        SizedBox(
                          width:
                              double.infinity,
                          height: 52,
                          child:
                              ElevatedButton.icon(
                            onPressed: () =>
                                _abrirLogin(
                              context,
                            ),
                            icon:
                                const Icon(
                              Icons.login,
                            ),
                            label:
                                const Text(
                              'Iniciar sesión',
                              style:
                                  TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  Colors.brown
                                      .shade800,
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // VOLVER
                        // =================================================

                        TextButton.icon(
                          onPressed: () =>
                              _volver(context),
                          icon:
                              const Icon(
                            Icons.arrow_back,
                          ),
                          label:
                              const Text(
                            'Volver',
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