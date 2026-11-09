import 'package:flutter/material.dart';

import '../mapa_page.dart';

class RelojPage extends StatelessWidget {
  final bool rutaActiva;
  final double distancia;
  final int tiempoEstimado;

  const RelojPage({
    super.key,
    this.rutaActiva = false,
    this.distancia = 0,
    this.tiempoEstimado = 0,
  });

  void _abrirMapa(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapaPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF20A39E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'BUSCAPET WEARABLE',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: _construirModulo(context),
        ),
      ),
    );
  }

  Widget _construirModulo(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF20A39E),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF20A39E).withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          color: const Color(0xFF101414),
          padding: const EdgeInsets.all(16),
          child: rutaActiva
              ? _contenidoRutaActiva()
              : _contenidoSinRuta(context),
        ),
      ),
    );
  }

  Widget _contenidoRutaActiva() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'BUSCAPET',
          style: TextStyle(
            color: Color(0xFF20A39E),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        const Icon(
          Icons.navigation,
          color: Color(0xFF20A39E),
          size: 29,
        ),
        const SizedBox(height: 3),
        const Text(
          'RUTA HACIA MASCOTA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          '${distancia.toStringAsFixed(1)} km',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'DISTANCIA',
          style: TextStyle(
            color: Color(0xFF20A39E),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$tiempoEstimado min',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'TIEMPO ESTIMADO',
          style: TextStyle(
            color: Color(0xFF20A39E),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _contenidoSinRuta(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'BUSCAPET',
          style: TextStyle(
            color: Color(0xFF20A39E),
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        const Icon(
          Icons.pets,
          color: Colors.white,
          size: 43,
        ),
        const SizedBox(height: 8),
        const Text(
          'RUTA A MASCOTA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: 174,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _abrirMapa(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF20A39E),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            icon: const Icon(Icons.navigation, size: 20),
            label: const Text(
              'INICIAR RUTA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
