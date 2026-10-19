import 'package:flutter/material.dart';

import '../models/publicacion.dart';

class DetallePublicacionPage extends StatelessWidget {
  final Publicacion publicacion;

  const DetallePublicacionPage({
    super.key,
    required this.publicacion,
  });

  @override
  Widget build(BuildContext context) {
    final bool encontrada =
        publicacion.tipo.toLowerCase().contains('encontr');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF20A39E),
        foregroundColor: Colors.white,
        title: const Text('Detalle de la publicación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // foto de la mascota
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                height: 260,
                child: publicacion.urlImagen.trim().isNotEmpty
                    ? Image.network(
                        publicacion.urlImagen,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF20A39E),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _imagenRespaldo();
                        },
                      )
                    : _imagenRespaldo(),
              ),
            ),

            const SizedBox(height: 20),

            // nombre de la mascota
            Center(
              child: Text(
                publicacion.nombreMascota.isEmpty
                    ? 'Mascota sin nombre'
                    : publicacion.nombreMascota,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF555555),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // tipo de publicación
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: encontrada
                      ? const Color(0xFF20A39E)
                      : const Color(0xFFFF7A59),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  publicacion.tipo.isEmpty
                      ? 'Publicación'
                      : publicacion.tipo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // información de la mascota
            const Text(
              'Información de la mascota',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),

            const SizedBox(height: 12),

            _dato('Especie', publicacion.especie),
            _dato('Raza', publicacion.raza),
            _dato('Color', publicacion.color),
            _dato('Tamaño', publicacion.tamano),
            _dato('Sexo', publicacion.sexo),

            const SizedBox(height: 20),

            // ubicación
            const Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),

            const SizedBox(height: 8),

            _dato('Localidad', publicacion.ubicacion),

            const SizedBox(height: 20),

            // descripción
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              publicacion.descripcion.isEmpty
                  ? 'Sin descripción disponible.'
                  : publicacion.descripcion,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),

            // indicador de publicación destacada
            if (publicacion.destacada) ...[
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Color(0xFFFF7A59),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Publicación destacada',
                    style: TextStyle(
                      color: Color(0xFFFF7A59),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // muestra una imagen de respaldo cuando no hay foto disponible
  Widget _imagenRespaldo() {
    return Container(
      color: const Color(0xFFF7F9F6),
      child: const Center(
        child: Icon(
          Icons.pets,
          size: 100,
          color: Color(0xFF20A39E),
        ),
      ),
    );
  }

  // muestra un dato de la mascota
  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$titulo:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor.isEmpty ? 'No indicado' : valor,
              style: const TextStyle(
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
