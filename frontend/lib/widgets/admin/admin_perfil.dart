import 'package:flutter/material.dart';

class AdminPerfil extends StatelessWidget {
  final String nombre;
  final String email;

  const AdminPerfil({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),

          // Icono
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green.shade50,
            child: Icon(
              Icons.admin_panel_settings,
              size: 60,
              color: Colors.green.shade800,
            ),
          ),

          const SizedBox(height: 20),

          // Nombre
          Text(
            nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Correo
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 35),

          // Información
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.green.shade800,
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Nombre',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          nombre,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 30),

                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Colors.green.shade800,
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Correo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          email,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 30),

                  Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        color: Colors.green.shade800,
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Rol',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Text('Administrador'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}