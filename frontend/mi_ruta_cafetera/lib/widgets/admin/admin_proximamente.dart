import 'package:flutter/material.dart';

class AdminProximamente extends StatelessWidget {
  final String nombre;

  const AdminProximamente({
    super.key,
    required this.nombre,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 15,
          ),
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
}