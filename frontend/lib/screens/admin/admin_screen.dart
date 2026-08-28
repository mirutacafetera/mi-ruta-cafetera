import 'package:flutter/material.dart';

import '../../widgets/admin_drawer.dart';
import '../mapa_screen.dart';
import 'admin_sitio_list_screen.dart';

class AdminScreen extends StatefulWidget {
  final String nombre;
  final String email;

  const AdminScreen({
    super.key,
    required this.nombre,
    required this.email,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _opcionSeleccionada = 'inicio';

  void _cambiarOpcion(String opcion) {
    setState(() {
      _opcionSeleccionada = opcion;
    });
  }

  // =====================================================
  // ABRIR MAPA
  // =====================================================

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapaScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tituloPantalla()),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),

      drawer: AdminDrawer(
        nombre: widget.nombre,
        email: widget.email,
        onOpcionSeleccionada: _cambiarOpcion,
      ),

      body: _crearContenido(),
    );
  }

  // =====================================================
  // TÍTULO
  // =====================================================

  String _tituloPantalla() {
    switch (_opcionSeleccionada) {
      case 'inicio':
        return 'Panel de administración';

      case 'estadisticas':
        return 'Estadísticas';

      case 'sitios':
        return 'Sitios turísticos';

      case 'contenido':
        return 'Contenido';

      case 'resenas':
        return 'Reseñas';

      case 'usuarios':
        return 'Usuarios';

      case 'perfil':
        return 'Mi cuenta';

      default:
        return 'Panel de administración';
    }
  }

  // =====================================================
  // CONTENIDO
  // =====================================================

  Widget _crearContenido() {
    switch (_opcionSeleccionada) {
      case 'inicio':
        return _inicio();

      case 'estadisticas':
        return _proximamente('Estadísticas');

      case 'sitios':
        return _sitios();

      case 'contenido':
        return _proximamente('Contenido');

      case 'resenas':
        return _proximamente('Reseñas');

      case 'usuarios':
        return _proximamente('Usuarios');

      case 'perfil':
        return _perfil();

      case 'logout':
        return _inicio();

      default:
        return _inicio();
    }
  }

  // =====================================================
  // INICIO
  // =====================================================

  Widget _inicio() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 850,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // =================================================
              // BIENVENIDA
              // =================================================

              const Icon(
                Icons.admin_panel_settings,
                size: 70,
                color: Color(0xFF1B5E20),
              ),

              const SizedBox(height: 16),

              Text(
                'Bienvenido, ${widget.nombre}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Panel de administración\n'
                'Mi Ruta Cafetera',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 35),

              // =================================================
              // BOTÓN DEL MAPA
              // =================================================

              Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _abrirMapa,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1B5E20),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.map,
                            size: 32,
                            color: Color(0xFF1B5E20),
                          ),
                        ),

                        SizedBox(width: 18),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mapa turístico',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                'Visualiza los sitios turísticos, '
                                'categorías y rutas por carretera.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // GESTIÓN DE SITIOS
              // =================================================

              Card(
                elevation: 2,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.location_on,
                      color: Color(0xFF1B5E20),
                    ),
                  ),

                  title: const Text(
                    'Gestionar sitios turísticos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  subtitle: const Text(
                    'Crear, editar y administrar sitios turísticos.',
                  ),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  ),

                  onTap: () {
                    _cambiarOpcion('sitios');
                  },
                ),
              ),

              const SizedBox(height: 30),

              // =================================================
              // INFORMACIÓN DEL ADMINISTRADOR
              // =================================================

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF1B5E20),
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              widget.email,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // SITIOS TURÍSTICOS
  // =====================================================

  Widget _sitios() {
    return const AdminSitioListScreen();
  }

  // =====================================================
  // OPCIONES QUE TODAVÍA NO DESARROLLAMOS
  // =====================================================

  Widget _proximamente(String nombre) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction,
            size: 60,
            color: Colors.grey,
          ),

          const SizedBox(height: 15),

          Text(
            '$nombre\nPróximamente',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PERFIL
  // =====================================================

  Widget _perfil() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.admin_panel_settings,
            size: 70,
            color: Color(0xFF1B5E20),
          ),

          const SizedBox(height: 15),

          Text(
            widget.nombre,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(widget.email),
        ],
      ),
    );
  }
}