import 'package:flutter/material.dart';

import '../viewmodel/inicio_view_model.dart';
import 'mapa_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final InicioViewModel _viewModel = InicioViewModel();

  int _opcionSeleccionada = 0;

  @override
  void initState() {
    super.initState();

    _viewModel.addListener(_actualizarPantalla);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_actualizarPantalla);
    _viewModel.dispose();

    super.dispose();
  }

  void _actualizarPantalla() {
    setState(() {});
  }

  void _abrirMapa() {
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
      body: SafeArea(
        child: Column(
          children: [
            // encabezado
            Container(
              height: 64,
              width: double.infinity,
              color: const Color(0xFF20A39E),
              child: Row(
                children: [
                  const SizedBox(width: 10),

                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 32,
                  ),

                  const SizedBox(width: 6),

                  const Text(
                    'BuscaPet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  const SizedBox(width: 42),
                ],
              ),
            ),

            // contenido
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // imagen principal
                    SizedBox(
                      width: double.infinity,
                      height: 210,
                      child: Image.asset(
                        'assets/images/hero.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // botones principales
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _botonPrincipal(
                              texto: 'PERDÍ MI\nMASCOTA',
                              color: const Color(0xFF20A39E),
                              icono: Icons.pets,
                              onPressed: () {},
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _botonPrincipal(
                              texto: 'ENCONTRÉ UNA\nMASCOTA',
                              color: const Color(0xFFFF7A59),
                              icono: Icons.search,
                              onPressed: _abrirMapa,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // título publicaciones
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF20A39E),
                            size: 25,
                          ),

                          const SizedBox(width: 7),

                          const Expanded(
                            child: Text(
                              'Últimas publicaciones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF555555),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(width: 8),

                          const Text(
                            'Ver todas',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF20A39E),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // publicaciones
                    SizedBox(
                      height: 285,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        itemCount: _viewModel.publicaciones.length,
                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final publicacion =
                              _viewModel.publicaciones[index];

                          return _tarjetaMascota(
                            publicacion,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // navegación inferior
      bottomNavigationBar: _barraNavegacion(),
    );
  }

  // botón principal
  Widget _botonPrincipal({
    required String texto,
    required Color color,
    required IconData icono,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: color,
                size: 23,
              ),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
            ),

            const SizedBox(width: 2),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // tarjeta mascota
  Widget _tarjetaMascota(
    Map<String, String> publicacion,
  ) {
    final bool encontrada =
        publicacion['estado'] == 'Encontrada';

    return Container(
      width: 165,
      margin: const EdgeInsets.only(
        right: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // foto
            SizedBox(
              height: 125,
              width: double.infinity,
              child: Image.asset(
                publicacion['imagen']!,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(9),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // nombre
                  Text(
                    publicacion['nombre']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF555555),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // estado
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: encontrada
                          ? const Color(0xFF20A39E)
                          : const Color(0xFFFF7A59),
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                    child: Text(
                      publicacion['estado']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF20A39E),
                        size: 16,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          publicacion['ubicacion']!,
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF20A39E),
                        size: 16,
                      ),

                      const SizedBox(width: 4),

                      Expanded(
                        child: Text(
                          publicacion['tiempo']!,
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // barra de navegación
  Widget _barraNavegacion() {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Color(0xFF20A39E),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _itemNavegacion(
            icono: Icons.home,
            texto: 'Inicio',
            indice: 0,
          ),

          _itemNavegacion(
            icono: Icons.description,
            texto: 'Publicaciones',
            indice: 1,
          ),

          // botón central
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A59),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.black.withValues(alpha: 0.18),
                  blurRadius: 6,
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),

          _itemNavegacion(
            icono: Icons.favorite_border,
            texto: 'Favoritos',
            indice: 2,
          ),

          _itemNavegacion(
            icono: Icons.person_outline,
            texto: 'Perfil',
            indice: 3,
          ),
        ],
      ),
    );
  }

  // item de navegación
  Widget _itemNavegacion({
    required IconData icono,
    required String texto,
    required int indice,
  }) {
    final bool seleccionado =
        _opcionSeleccionada == indice;

    return GestureDetector(
      onTap: () {
        setState(() {
          _opcionSeleccionada = indice;
        });
      },
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            color: Colors.white,
            size: seleccionado ? 25 : 23,
          ),

          const SizedBox(height: 2),

          Text(
            texto,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: seleccionado
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}